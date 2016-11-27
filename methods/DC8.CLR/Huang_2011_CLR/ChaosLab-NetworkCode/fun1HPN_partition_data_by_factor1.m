function DATAfactor1Set=fun1HPN_partition_data_by_factor1(Data1,StateTitle_Tags,IDsCond,Npet,Times1,varargin)
scrsz=get(0,'screensize');     % screen size
progArgs1={'-showProfile',0,'-subplotSize',[],'-SimName','','-nodeNames',{},...
    '-getTime0',true,'-func_rep','mean','-args_fig',{},'-args_save',{},...
    '-positionFig',[scrsz(3)*0.01,scrsz(4)*0.07,scrsz(3)*0.8,scrsz(4)*0.8]};
[~,~,showProfile,subplotSize,SimName,nodeNames,getTime0,func_rep,args_fig,args_save,...
    positionFig]=fun1_process_arguments(varargin,progArgs1);

nNodes=size(Data1,1);
func_rep=str2func(func_rep);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_DATAstimuSet=size(StateTitle_Tags,1);
DATAfactor1Set=struct;
withClim=true;
for Fi=1:N_DATAstimuSet
    DataT=[];
    TimeT=[];
    Kt=1;
    Sections=[];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    StateTitle=StateTitle_Tags{Fi,1};
    nameFactor1=StateTitle_Tags{Fi,2};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if showProfile
        Hf1=figure('Position',positionFig,'Name',nameFactor1);
        sizSp=subplotSize{Fi};
    end
    ClimMax=max(Data1(:));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Cn=size(StateTitle,1);
    for Ci=1:Cn
        State=StateTitle{Ci,1};
        TitleCh=StateTitle{Ci,2};
        id_cond=fun1_subM2ind(2*ones(1,Npet),State);
        idx_cond=find(IDsCond==id_cond);
        Ts=Times1(idx_cond);
        Da=Data1(:,idx_cond);
        [Ts,idxSortT]=sort(Ts);
        Da=Da(:,idxSortT);
        if showProfile
            subplot(sizSp(1),sizSp(2),Ci)
            imagesc(Da);
            if withClim
                caxis([0,ClimMax]);
            else
                colorbar;
            end
            [Tu,iTu]=unique(Ts);
            set(gca,'yTick',1:nNodes,'yTickLabel',nodeNames,'xTick',...
                iTu,'xTickLabel',Tu,args_fig{:});
            title(TitleCh);
            xlabel('Time');
        end
        %%%%%% average the replicates %%%%%%
        uTs=unique(Ts);
        Nse=length(uTs);
        Da2=NaN(nNodes,Nse);
        Kt=Kt+Nse;
        for j=1:Nse
            maskT=Ts==uTs(j);
            Da2(:,j)=func_rep(Da(:,maskT),2);
        end
        if Fi==1&&getTime0
            DataT=[DataT,Da];
            TimeT=[TimeT,Ts(:)'];
            Sections=[Sections,length(Ts)];
        elseif Fi~=1&&getTime0
            DataT=[DataT,DATAfactor1Set(1).data(:,Ci),Da2];
            TimeT=[TimeT,0,uTs(:)'];            
            Nse=Nse+1;
            Sections=[Sections,Nse];
        else
            DataT=[DataT,Da2];
            TimeT=[TimeT,uTs(:)'];
            Sections=[Sections,Nse];
        end
    end
    if showProfile
        fun1_tightMargin_all_subplots_adv(Hf1,'sizSp',sizSp);
        set(Hf1,'color',[1,1,1]); % set the background color as white
        fun1_saveas_whatYouSee(Hf1,['Profile_',SimName,'_',nameFactor1,'.png'],args_save{:});
    end
    DATAfactor1Set(Fi).data=DataT;
    DATAfactor1Set(Fi).sets=Sections;
    DATAfactor1Set(Fi).time=TimeT;
    DATAfactor1Set(Fi).nameFactor1=nameFactor1;
    DATAfactor1Set(Fi).namesFactor2=StateTitle(:,2);
    
end

