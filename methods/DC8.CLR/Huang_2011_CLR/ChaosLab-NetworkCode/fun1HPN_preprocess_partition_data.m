
function [Data1,matrCond1,idxStimu,Times1,nodeNames0,namesStimuli,...
    namesInhibitor,CellLine]=fun1HPN_preprocess_partition_data (Data0,colNames)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Func_replace_DV=@(x) regexprep(x,'DV:','');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CellLine=colNames{1};
CellLine=regexprep(CellLine,'TR:|:CellLine','');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_colTime=find(func_find_string_in_cellArray('DA:ALL',colNames));
% Ncond=i_colTime-2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Func_replace_TR=@(x) regexprep(x,'TR:','');
i_colInhibitor=func_find_string_in_cellArray_byPattern('Inhibitors',colNames);
namesInhibitor=colNames(i_colInhibitor);
namesInhibitor = cellfun(Func_replace_TR, namesInhibitor, 'UniformOutput', false);
namesInhibitor = cellfun(@(x) regexprep(x,':Inhibitors',''), namesInhibitor, 'UniformOutput', false);
namesInhibitor = cellfun(@(x) regexprep(x,'_','*'), namesInhibitor, 'UniformOutput', false);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_colStimuli=find(func_find_string_in_cellArray_byPattern('Stimuli',colNames));
namesStimuli=colNames(i_colStimuli);
namesStimuli = cellfun(Func_replace_TR, namesStimuli, 'UniformOutput', false);
namesStimuli = cellfun(@(x) regexprep(x,':Stimuli',''), namesStimuli, 'UniformOutput', false);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
matrCond1=Data0(:,2:i_colTime-1);
Times1=Data0(:,i_colTime);
Data1=Data0(:,i_colTime+1:end)';
nodeNames0=colNames(i_colTime+1:end);
nodeNames0 = cellfun(Func_replace_DV, nodeNames0, 'UniformOutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idxStimu=i_colStimuli-i_colStimuli(1)+1;
idxStimu=i_colStimuli-1;


function idx = func_find_string_in_cellArray(str, cellArray,varargin)
progArgs1={'-ignoreCase',false};
[iUs1,~,ignoreCase]=fun1_process_arguments(varargin,progArgs1);  % attention 
varargin1=varargin(setdiff(1:length(varargin),iUs1));

if ignoreCase, fn = @(c)strcmpi(c,str); else fn = @(c)strcmp(c,str); end
idx = cellfun(fn,cellArray,varargin1{:});


function idx=func_find_string_in_cellArray_byPattern(Pattern, cellArray,varargin)
progArgs1={'-ignoreCase',false};
[iUs1,~,ignoreCase]=fun1_process_arguments(varargin,progArgs1);  % attention 
varargin1=varargin(setdiff(1:length(varargin),iUs1));
if ignoreCase
    fn = @(c) ~isempty(regexp(c,Pattern, 'once')); 
else
    fn = @(c) ~isempty(regexpi(c,Pattern, 'once')); 
end
idx = cellfun(fn,cellArray,varargin1{:});
