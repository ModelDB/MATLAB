%% %%%%%%% dynamic network learning by averaging groups of time series %%%%%%%
%
function NetMIsects=fun1_netInfer_groupSections_dyn(vects_explanat,vects_response,Lsects,varargin)
% vects_explanat:   explanatory vectors
% vects_response:   response vectors
% vects_response(iNode,j) is the next time piont of vects_explanat(iNode,j)
% Lsects:           1*nTimeseries vector, recording the number of data points in each section of vects_explanat and vects_response
% Ngroups:          number of groups in each partition
% Npartitons:       number of partitions
progArgs1={'-Ngroups',4,'-Npartitons',4,'-method','MIclr','-PossibleLinks',[]};
[~,~,Ngroups,Npartitons,Method,PossibleLinks]=fun1_process_arguments(varargin,progArgs1);
nNodes=size(vects_explanat,1);
if isempty(PossibleLinks)
    PossibleLinks=eye(nNodes)==0;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nseries=length(Lsects);
iS2=[0,cumsum(Lsects)];
iS2lo=iS2(1:end-1)+1;
iS2up=iS2(2:end);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CMperms=fun1_setPartition_harmo(Nseries,Ngroups,'-Npartitons',Npartitons);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NetMIsects=zeros(nNodes);
Nsect2=numel(CMperms);
for i=1:Nsect2
    idxSect=CMperms{i};
    idx2=[];
    for m=idxSect
        idx2=[idx2,iS2lo(m):iS2up(m)];
    end
    NetDyn=fun1_structLearn_XY(vects_explanat(:,idx2),vects_response(:,idx2),'-method',Method);
    NetDyn(PossibleLinks)=fun1_transform_to_quantile(NetDyn(PossibleLinks));
    NetMIsects=NetMIsects+NetDyn;
end
NetMIsects(PossibleLinks)=fun1_transform_to_quantile(NetMIsects(PossibleLinks));

