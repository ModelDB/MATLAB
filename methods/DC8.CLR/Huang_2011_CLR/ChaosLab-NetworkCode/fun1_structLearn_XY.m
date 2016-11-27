%% %%%%%%%%%%%%% dynamic network inference suit %%%%%%%%%%%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.

function NetW=fun1_structLearn_XY(vects_explanat,vects_response,varargin)
% vects_explanat:   nNodes*nCases matrix, each row is a explanatory vector
% vects_response:   nNodes*nCases matrix, each row is a response vector
% NetW:             nNodes*nNodes matrix, recording the link scores after inference
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
progArgs1={'-method',[],'-toolArgs',{},'-possibleLinks',[]};
[~,~,Method1,toolArgs,possibleLinks]=fun1_process_arguments(varargin,progArgs1);

[nNodes0,nCases0]=size(vects_explanat);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
possibleLinks1=false(2*nNodes0);
if isempty(possibleLinks)
    possibleLinks1(1:nNodes0,nNodes0+1:end)=~eye(nNodes0);
else
    possibleLinks1(1:nNodes0,nNodes0+1:end)=possibleLinks;
end
XY=[vects_explanat;vects_response];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(Method1,'clr')
    [~,~,arg_tool]=fun1_process_arguments(toolArgs,{['-',Method1],{}});
    [~,~,n_bin,k_spline,keepDirection,rDirection,arg_bc]=...
        fun1_process_arguments(arg_tool,{'-n_bin',10,'-k_spline',3,...
        '-keepDirection',1,'-rDirection',1,'-arg_bc',{}});
    NetTmp=fun1_mi_CLR(XY,n_bin,k_spline);
    NetW1=double(NetTmp(1:nNodes0,nNodes0+1:end));
    NetW =fun1_clr_bc(NetW1,arg_bc{:});     % background correction
    if keepDirection
        Mask=eye(nNodes0)==0;
        NetW1(Mask)=fun1_transform_to_quantile(NetW1(Mask));
        NetW(Mask)=fun1_transform_to_quantile(NetW(Mask));
        NetW1=NetW1-NetW1';
        NetW1(NetW1>0)=0;
        NetW=NetW+NetW1*rDirection;
    end
elseif strcmpi(Method1,'MIclr')
    [~,~,arg_tool]=fun1_process_arguments(toolArgs,{['-',Method1],{}});
    [~,~,n_bin,k_spline]=fun1_process_arguments(arg_tool,{'-n_bin',10,'-k_spline',3});
    NetTmp = fun1_mi_CLR(XY, n_bin, k_spline);
elseif strcmpi(Method1,'AGBN')  %  AGBN (Gaussian Bayesian Network) based linear regression algorithm 
    [~,~,arg_tool]=fun1_process_arguments(toolArgs,{['-',Method1],{}});
    NetTmp=fun1_call_AGBN(XY,arg_tool{:},'-possibleLinks',possibleLinks1);
else
    NetW=[];
    return;
end

if ~exist('NetW','var')
    if exist('NetTmp','var')
        NetW=NetTmp(1:nNodes0,nNodes0+1:end);
    end
end

