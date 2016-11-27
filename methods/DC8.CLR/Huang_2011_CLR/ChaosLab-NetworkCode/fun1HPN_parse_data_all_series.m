function [DataAll,SectsAll,nodeNames,DATAfactor1Set,CellLine]=fun1HPN_parse_data_all_series(InFile,varargin)
% DataAll:  nNodes*nTimepoints data matrix; 
% SectsAll: 1*nTimeseries vector, recording the number of data points in each timeserie
% nodeNames: 1*nNodes cell, recording the names of all the nodes

progArgs1={'-isExp',[],'-nodesExclude',{}};
[~,~,isExp,nodesExclude]=fun1_process_arguments(varargin,progArgs1);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[Data0,colNames]=fun1_read_delim(InFile,'-sep',',','-Row1st',true,'-Col1st',false);
[Data0,colNames]=fun1_read_delim(InFile,'-sep',',','-Row1st',false,'-Col1st',true);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Data1,matrCond1,idxStimu,Times1,nodeNames,namesStimuli,namesInhibitor,...
    CellLine]=fun1HPN_preprocess_partition_data (Data0,colNames);
idxINH=setdiff(1:size(matrCond1,2),idxStimu);

if isExp
    [StateTitle_Tags,IDsCond,subplotSize]=fun1HPN_generate_StateTitle_Tags(matrCond1,idxStimu,...
        namesStimuli,namesInhibitor,'-tagFactor1','Inh','-tagFactor2','Stimu');
else
    [StateTitle_Tags,IDsCond,subplotSize]=fun1HPN_generate_StateTitle_Tags(matrCond1,idxINH,...
        namesInhibitor,namesStimuli,'-tagFactor1','Stimu','-tagFactor2','Inh');
end


%% %%%%%%%%%% nodes to be excluded %%%%%%%%%%%
maskExclude=ismember(lower(nodeNames),lower(nodesExclude));
nodeNames=nodeNames(~maskExclude);
Data1=Data1(~maskExclude,:);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Npet=size(matrCond1,2);   % number of perturbations
Data1=Data1./repmat(max(Data1,[],2),[1,size(Data1,2)]);

%% %%%%%%%%% preprocess and store the data %%%%%%%%%%%%%%
DATAfactor1Set=fun1HPN_partition_data_by_factor1(Data1,StateTitle_Tags,IDsCond,Npet,Times1,...
    '-subplotSize',subplotSize,'-nodeNames',nodeNames,'-getTime0',isExp,'-args_fig',{'fontsize',8});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[DataAll,SectsAll,TimesStAll,NsetsSt]=fun1HPN_generate_static_data(DATAfactor1Set,'-getTime0',isExp);

