clear;

%% %%%%%%%%%%%%%% files input %%%%%%%%%%%%%%%
InFiles={
    '/home/brg/Documents/Elizabeth.Trippe/05_methodFor8970/experimental/CSV/MCF7_main.csv'
    %'/home/brg/Documents/Elizabeth.Trippe/05_methodFor8970/experimental/CSV/BT20_main.csv'
    %'/home/brg/Documents/Elizabeth.Trippe/05_methodFor8970/experimental/CSV/BT549_main.csv'
    %'/home/brg/Documents/Elizabeth.Trippe/05_methodFor8970/experimental/CSV/UACC812_main.csv'
};

%%%%%%%%%%%%%%%%%%%%%
nodesExclude={'TAZ_pS89','FOXO3a_pS318_S321'}; % nodes to be excluded
TeamName='ChaosLab';

%%%%%%%%%%% parameters in network inference %%%%%%%%%%%
r_Part_vs_Whole=0.2;   % the weight of the link score inferred by the data in each stimulus
Ngroups=4;      % number of groups in each partition (for dynamic learning with average mutual information in groups of time series)
Npartitons=4;   % number of partitions  (for dynamic learning with average mutual information in groups of time series)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Fi=1:length(InFiles)
    InFile=InFiles{Fi};
    %InFile=InFiles{1};
    %% %%%%% obtain formated data, and related information %%%%
    % DataAll:   nNodes*nTimepoints data matrix;
    % LsectsAll: 1*nTimeseries vector, recording the number of data points in each timeserie
    % nodeNames: 1*nNodes cell, recording the names of all the nodes
    [DataAll,LsectsAll,nodeNames,DATAfactor1Set,CellLine]=fun1HPN_parse_data_all_series(InFile,...
        '-isExp',true,'-nodesExclude',nodesExclude);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nNodes=length(nodeNames);    
        
    %% %%%%% transform data into explanatory vectors and response vectors, suitable for dynamic learning %%%%%%
    % vects_explanat:   explanatory vectors
    % vects_response:   response vectors
    % vects_response(iNode,j) is the next time piont of vects_explanat(iNode,j)
    % LsectsDyn: 1*nTimeseries vector, recording the number of data points in each section of vects_explanat and vects_response
    [vects_explanat,vects_response,LsectsDyn]=fun1_generate_explanatory_response_vectors(DataAll,'-Lsections',LsectsAll);

    %%%%%%%% mask for all possible links (exclude self-links) %%%%%%%%
    MaskEyeNon=eye(nNodes)==0;
    
    %% %%%%%%%%%%% dynamic network learning for draft network %%%%%%%%%%%%%
    Net_tlCLR=fun1_structLearn_XY(vects_explanat,vects_response,'-method','CLR'); % dynamic learning with CLR (context likelihood relatedness)
    %%% dynamic learning by averaging mutual information in groups of time series
    Net_tlMIg=fun1_netInfer_groupSections_dyn(vects_explanat,vects_response,LsectsDyn,'-Ngroups',Ngroups,... 
        '-Npartitons',Npartitons,'-method','MIclr','-PossibleLinks',MaskEyeNon);
    
    %% %%% transform the inferred link scores to their quantiles %%%
    %%% The strongest link has the score of 1, the weakest link has the score of 0.
    Net_tlCLR(MaskEyeNon)=fun1_transform_to_quantile(Net_tlCLR(MaskEyeNon));
    Net_tlMIg(MaskEyeNon)=fun1_transform_to_quantile(Net_tlMIg(MaskEyeNon));

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Net_draft=max(Net_tlCLR,Net_tlMIg);
    
    %% %%%%%%%%%%% score matrix of draft network %%%%%%%%%%%%
    Net_draft(MaskEyeNon)=fun1_transform_to_quantile(Net_draft(MaskEyeNon));

    %% %%%%%%%%%% obtain the sign for each link %%%%%%%%%%
    NetSign=sign(corr(DataAll'));

    %% %%%%%%%%%%% export sif and eda file %%%%%%%%%%%%%%
    N_DATAstimuSet=length(DATAfactor1Set);
    for k=2:N_DATAstimuSet
        Stimulus=DATAfactor1Set(k).nameFactor1;
        Sections=DATAfactor1Set(k).sets;
        DataT=DATAfactor1Set(k).data;
        %%%%%%%% retrieve data for each stimulus %%%%%%%%%
        Nsects=length(Sections);
        iSects=[0,cumsum(Sections)];
        idxSelect=[];
        for i=1:Nsects
            idxSelect=[idxSelect,iSects(i)+1,iSects(i)+2:iSects(i+1)];
        end
        Data_Stimu=DataT(:,idxSelect);
        %%%%%%%%%%%%%% static net inference %%%%%%%%%%%%%%
        Net_stimu_stMI=fun1_structLearn_X(Data_Stimu,'-method','MIclr');
        Net_stimu_stMI(MaskEyeNon)=fun1_transform_to_quantile(Net_stimu_stMI(MaskEyeNon));
        %%%%%%% combine draft net and stimulus net %%%%%%%
        Net_final=(Net_draft+r_Part_vs_Whole*Net_stimu_stMI)/(1+r_Part_vs_Whole);
        %%%%%%%%%%%%% export sif and eda file %%%%%%%%%%%%
        SimNameOut=[TeamName,'-',CellLine,'-',Stimulus,'-Network'];
        fun1_export_sif_eda(Net_final,nodeNames,'-NetSign',NetSign,...
            '-SimName',SimNameOut);
    end
end


