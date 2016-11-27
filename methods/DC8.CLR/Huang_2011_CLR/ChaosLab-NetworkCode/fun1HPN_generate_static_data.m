function [DataStAll,SectionsAll,TimesAll,Nsets]=fun1HPN_generate_static_data(DATAstimuSet,varargin)
progArgs1={'-NlastPoints',Inf,'-getTime0',1,'-withSection0',1};
[~,~,NlastPoints,getTime0,withSection0]=fun1_process_arguments(varargin,progArgs1);

nNodes=size(DATAstimuSet(2).data,1);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N_DATAstimuSet=length(DATAstimuSet);
DataStAll=[];
SectionsAll=[];
TimesAll=[];
if getTime0
    i1=2;
    Nsets(1)=length(DATAstimuSet(1).sets);
else
    i1=1;
end

for Fi=i1:N_DATAstimuSet
    Stimulus=DATAstimuSet(Fi).nameFactor1;
    Sections=DATAstimuSet(Fi).sets;
    DataT=DATAstimuSet(Fi).data;
    TimeT=DATAstimuSet(Fi).time;
    Nsets(Fi)=length(Sections);
    %%%%%%%%%%%%% learn static network %%%%%%%%%%%%%
    Nsects=length(Sections);
    iSects=[0,cumsum(Sections)];
    idxSelect=[];
    Sects2=[];
    if withSection0
        i1=1;
    else
        i1=2;
    end
    for i=i1:Nsects
        idx=[iSects(i)+1,max(iSects(i)+2,iSects(i+1)-NlastPoints+1):iSects(i+1)];
        idxSelect=[idxSelect,idx];
        Sects2=[Sects2,length(idx)];
    end
%     DataSt=DataT(:,idxSelect);
    DataStAll=[DataStAll,DataT(:,idxSelect)];
    SectionsAll=[SectionsAll,Sects2];
    TimesAll=[TimesAll,TimeT(idxSelect)];
end

if ~withSection0
    Nsets=Nsets-1;
end
