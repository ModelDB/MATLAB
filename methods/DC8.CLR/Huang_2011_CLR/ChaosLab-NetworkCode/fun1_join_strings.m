%% %%%%%%% Joins the separate strings into a single string with fields separated by the value of "Juncture" %%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.
% 
function S2=fun1_join_strings(Strs,Juncture)
if ~iscell(Strs)
    error('ArgChk: The first argument should be an cell array!');
end

N=length(Strs);
N1=size(Strs,2);
if N1~=N
    Strs=Strs';
end

if N==0;
    S2='';
else
    if 1  % method 1
        Format=['%s', repmat([Juncture,'%s'],[1,N-1])];
        S2=sprintf(Format,Strs{:});
    else  % method 2
        C = [Strs; [repmat({Juncture},[1,length(Strs)-1]),{''}]];
        C = C(:)';
        S2 = horzcat(C{:});
    end
end
