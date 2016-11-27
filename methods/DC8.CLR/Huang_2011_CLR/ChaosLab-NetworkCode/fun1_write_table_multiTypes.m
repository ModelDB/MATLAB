%% %%%%%%%%%%% write cell data into a table file %%%%%%%%%%%
% % in order that each cell data will be a column in the table file 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.

function fun1_write_table_multiTypes(Vcolumns,FileName,varargin)
progArgs1={'-Format',[],'-firstLine',[],'-sep','\t','-permission','w'};
[~,~,Format,firstLine,Sep,Permission]=fun1_process_arguments(varargin,progArgs1);
fid = fopen(FileName,Permission);
if ischar(firstLine)
    fprintf(fid,'%s\n',firstLine);
end
Nrows=length(Vcolumns{1});
StrEval='fprintf(fid,Format';
Ncols=length(Vcolumns);
Formats=cell(1,Ncols);
for i=1:length(Vcolumns)
    if iscell(Vcolumns{i})
       StrEval=sprintf('%s,Vcolumns{%d}{i}',StrEval,i);
       Formats{i}='%s';
    elseif isnumeric(Vcolumns{i})||islogical(Vcolumns{i})
       StrEval=sprintf('%s,Vcolumns{%d}(i)',StrEval,i);
       Formats{i}='%g';
    end
end
if isempty(Format)
    Format=[fun1_join_strings(Formats,Sep),'\n'];
end
StrEval=[StrEval,');'];
for i=1:Nrows
    eval(StrEval);
end
fclose(fid);

