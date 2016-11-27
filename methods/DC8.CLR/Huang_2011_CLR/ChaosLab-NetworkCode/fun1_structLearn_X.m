%% %%%%%%%%%%%%% static network inference suit %%%%%%%%%%%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.

function Net=fun1_structLearn_X(Data,varargin)
% Data:     nNodes*nCases matrix, data for learning
% Net:      nNodes*nNodes matrix, scored network after inference
% Method:   string, the name of network inference method
% toolArgs: cell, containing additional arguments for the inference method
%%-------process input arguments---------%%
progArgs1={'-method','','-toolArgs',{}};
[iUs1,~,Method,toolArgs]=fun1_process_arguments(varargin,progArgs1);
varargin1=varargin(setdiff(1:length(varargin),iUs1));

%% %%%%%%%%%%%%%%%%%% learn network %%%%%%%%%%%%%%%%%%%%%%
if strcmpi(Method,'corr')||strcmpi(Method,'Pearson')||strcmpi(Method,'Spearman')
    [~,~,arg_tool]=fun1_process_arguments(toolArgs,{['-',Method],{}});
    [~,~,NegLogPVAL]=fun1_process_arguments(arg_tool,{'-NegLogPVAL',false});
    if strcmpi(Method,'Spearman')
        corrType='Spearman';
    else
        corrType='Pearson';
    end
    if NegLogPVAL
        if nnz(isnan(Data))
            [~,Net]=corr(Data','type',corrType,'rows','pairwise');
        else
            [~,Net]=corr(Data','type',corrType);
        end
        Net=-log(Net);
    else
        if nnz(isnan(Data))
            Net=abs(corr(Data','type',corrType,'rows','pairwise'));
        else
            Net=abs(corr(Data','type',corrType));
        end
    end
    Net=(Net+Net')/2;
elseif strcmpi(Method,'MIclr')
    Net = double(fun1_mi_CLR(Data, 10, 3));
elseif strcmpi(Method,'clr')
    [~,~,arg_tool]=fun1_process_arguments(toolArgs,{['-',Method],{}});
    [~,~,n_bin,k_spline,miType,idxTF,arg_bc]=fun1_process_arguments(arg_tool,{...
        '-n_bin',10,'-k_spline',3,'-miType','clr','-idxTF',[],'-arg_bc',{}});
    MI= fun1_mi_CLR(Data,n_bin,k_spline);
    MI=double(MI);
    Net = fun1_clr_bc(MI,arg_bc{:},'-idxTF',idxTF);
elseif strcmpi(Method,'AGBN')
    %  AGBN (Gaussian Bayesian Network Marginal Edge) algorithm for BN Learning
    [~,~,arg_tool]=fun1_process_arguments(toolArgs,{['-',Method],{}});
    Net=fun1_call_AGBN(Data,varargin1{:},arg_tool{:});
end

