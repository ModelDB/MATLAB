%% %%%%%%%%%%% write a matrix into a table file %%%%%%%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.

function fun1_write_delim(data,varargin)
% if data is a 3-D matrix, the numbers with the same Subscripts 
%    of the first 2 dimensions, will be written in the same cell, with the separator of sepInCell. 
% -numFormat:  the output format of each digit
% -sep:        separator between each column
progArgs1={'-dataFile','data_delim_test.txt','-colNames',{},'-rowNames',{},...
    '-numFormat','%g','-sep','\t','-Row1st',[],'-permission','w','-sepInCell',';','-firstCell',''};
[~,~,dataFile,colNames,rowNames,numFormat,Sep,Row1st,Permission,sepInCell,firstCell]...
    =fun1_process_arguments(varargin,progArgs1);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen(dataFile, Permission);
%%%%%%%%%%%%%%%%%%%%%
if ~isempty(Row1st)
    fprintf(fid,'%s\n',Row1st);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ndims(data)==2
    [Nrows,Ncols]=size(data);
elseif ndims(data)==3;
    [Nrows,Ncols,Nmems]=size(data);
    data=shiftdim(data,2);
else
    error('Wrong number of data dimensions!');
end

if ~isempty(colNames)
    if length(colNames)~=Ncols
       error('number of sample names mismatches number of samples!');
    end
    colNameT=fun1_join_strings(colNames,sprintf(Sep));
    if isempty(rowNames)
       fprintf(fid,'%s\n',colNameT);
    else
       fprintf(fid,'%s\t%s\n',firstCell,colNameT);
    end
end
%%%%%%%%%%%%%%%%%%
if ndims(data)==2
    Format=[fun1_join_strings(repmat({numFormat},[1,Ncols]),Sep),'\n'];
    if isempty(rowNames)
        fprintf(fid,Format,data');
    else
        Format=['%s',Sep,Format];
        for i=1:Nrows
            fprintf(fid,Format,rowNames{i},data(i,:));
        end
    end
elseif ndims(data)==3;
    Format=[fun1_join_strings(repmat({fun1_join_strings(repmat({numFormat},[1,Nmems]),sepInCell)},[1,Ncols]),Sep),'\n'];
    if isempty(rowNames)
        for i=1:Nrows
            fprintf(fid,Format,data(:,i,:));
        end
    else
        Format=['%s',Sep,Format];
        for i=1:Nrows
            fprintf(fid,Format,rowNames{i},data(:,i,:));
        end
    end
end
fclose(fid);
