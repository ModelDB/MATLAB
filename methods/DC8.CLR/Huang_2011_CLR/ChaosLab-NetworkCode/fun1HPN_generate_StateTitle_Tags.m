
function  [StateTitle_Tags,IDsCond,subplotSize]=...
    fun1HPN_generate_StateTitle_Tags(matrCond1,idxFactor1,namesFactor1,namesFactor2,varargin)
progArgs1={'-tagFactor1','Factor1','-tagFactor2','Factor2'};
[~,~,tagFactor1,tagFactor2]=fun1_process_arguments(varargin,progArgs1);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Npet=size(matrCond1,2);     % number of perturbations
IDsCond=fun1_subM2ind(2*ones(1,Npet),matrCond1+1);
uIDsCond=unique(IDsCond);
matrCondU=fun1_ind2subM(2*ones(1,Npet),uIDsCond);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NFactor1=length(idxFactor1);
matrFactor1=matrCondU(:,idxFactor1);
idxFactor2=setdiff(1:Npet,idxFactor1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IDsFactor1=fun1_subM2ind(2*ones(1,Npet),matrFactor1);
uIDsFactor1=unique(IDsFactor1);
matrFactor1U=fun1_ind2subM(2*ones(1,NFactor1),uIDsFactor1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NconFactor1=length(uIDsFactor1);
StateDataset=cell(1,NconFactor1);
StateTitle_Tags=cell(NconFactor1,2);
subplotSize=cell(1,NconFactor1);
for i=1:NconFactor1
    mask=IDsFactor1==uIDsFactor1(i);
    StateDataset{i}=matrCondU(mask,:);
    iFactor1=find(matrFactor1U(i,:)==2);
    if ~isempty(iFactor1)
        StateTitle_Tags{i,2}=fun1_join_strings(namesFactor1(iFactor1),'_');
    else
        StateTitle_Tags{i,2}=['non',tagFactor1];
    end
    matrCondUset=matrCondU(mask,:);
    Nset=nnz(mask);
    subplotSize{i}=[2,ceil(Nset/2)];
    for j=1:Nset
        Factor2=matrCondUset(j,idxFactor2);
        iFactor2=find(Factor2==2);
        if ~isempty(iFactor2)
            StateTitle_Tags{i,1}{j,2}=fun1_join_strings(namesFactor2(iFactor2),'+');
        else
            StateTitle_Tags{i,1}{j,2}=['non',tagFactor2];
        end
        StateTitle_Tags{i,1}{j,1}=matrCondUset(j,:);
    end
end

