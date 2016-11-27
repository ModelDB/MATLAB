%% %%%%% process input arguments (Huang Xun) %%%%%%%

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear
% 
% A=11;edgeStyles_HX=22;edgeColors_HX=33;Labels=44;layout=55;
% userArgs={'-adjMat',A,'-edgeStyles_HX',edgeStyles_HX,'isWeighted',true,...
%     '-edgeColors_HX',edgeColors_HX,'-nodeLabels',Labels,'-layout',layout,'-splitLabels',true,...
%     '-nodeVertiAlign_HX','bottom','-nodeHorizAlign_HX','center','colorbar_loc','SouthOutside'};
% progArgs={'-adjmat',[],'isWeighted',false,'rgb_link',[],'colorbar_loc','SouthOutside','edgecolors_hx',[]};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [iUs,iPs,varargout]=fun_process_arguments(userArgs,progArgs)
%%% userArgs: argument values provided by user, which have higher priority
%%% progArgs: default argument values set by program
%%%---------------------------%%%
progArgNames=progArgs(1:2:end);
% userArgNames=userArgs(1:2:end);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nu=length(userArgs);
Np=length(progArgs);
iUs=[];   % index for identified user arguments and their values
iPs=[];   % index for identified program arguments and their values
for i=1:2:Nu
    id=find(func_findString_inCell(userArgs{i},progArgNames,true));  % attention, here should not use fun_find_string_in_cellArray, to aviod recursion
    if ~isempty(id)
        iUs([end+1,end+2])=[i,i+1];
        iPs([end+1,end+2])=[id(1)*2-1,id(1)*2];
    end
end

% argSh=userArgs(iUs);    % identified arguments which will use user values
% argPdA=progArgs(setdiff(1:Np,iPs));   % unidentified program arguments which will use default program values
% varoutsAdP=userArgs(setdiff(1:Nu,iUs));   % useless unidentified user arguments

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     varargout = {struct('argSh',{argSh},'argPdA',{argPdA},'iUs',{iUs},'iPs',{iPs})};
progArgs(iPs)=userArgs(iUs);
varargout = progArgs(2:2:Np);


function idx = func_findString_inCell(str, cellArray,ignoreCase)
% Returns a boolean matrix the same size as cellArray with true everywhere
% the corresponding cell holds the specified string, str. 
if nargin < 3, ignoreCase = false; end
if ignoreCase, fn = @(c)strcmpi(c,str); else fn = @(c)strcmp(c,str); end
idx = cellfun(fn,cellArray);
