%% %%%%%%%%%%% read data from a table file %%%%%%%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.
% 
function [data,colNames,rowNames]=fun1_read_delim(InFile,varargin)
% % further reading, please refer to read.delim in R
progArgs1={'-sep','\t','-comment','#','-Row1st',false,'-Col1st',false,...
    '-dataFormat','%f','-bufSize',100000};
[~,~,Sep,Comment,Row1st,Col1st,dataFormat,bufSize]=fun1_process_arguments(varargin,progArgs1);

%% %% parse file head %%%%%%%%%%%
P=1;Ncol=0;
fid=fopen(InFile);
while P
    Offset=ftell(fid);
    tline_tmp = fgetl(fid);
    if ischar(tline_tmp)
        c_tmp=textscan(tline_tmp, '%s', 'delimiter', Sep);
        if isempty(regexp(c_tmp{1}{1},['^ *',Comment], 'once'))
            Ncol=length(c_tmp{1});
            if Row1st
                if Col1st
                    colNames=c_tmp{1}(2:end);
                else
                    colNames=c_tmp{1};
                end
            else
                colNames={};
            end
            P=0;
        end
    else
        P=0;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~Row1st
    fseek(fid, Offset, 'bof');
end
if Col1st
    Format=fun1_join_strings(['%s',repmat({dataFormat},[1,Ncol-1])],Sep);
else
    Format=fun1_join_strings(repmat({dataFormat},[1,Ncol]),Sep);
end
%C = textscan(fid, Format,'whitespace',Sep,'bufSize',bufSize);   % set whitespace parameter to avoid stop at whitespace; if a line is too long bufSize should be increased
C = textscan(fid, Format,'whitespace',Sep);%,'bufSize',bufSize);   % set whitespace parameter to avoid stop at whitespace; if a line is too long bufSize should be increased
%C = textscan(fid, Format,'delimiter',Sep)
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Col1st
    rowNames=C{1};
    data=cell2mat(C(2:end));
else
    rowNames={};
    colNames=tdfread('/home/brg/Documents/Elizabeth.Trippe/05_methodFor8970/experimental/CSV/colNames.csv',',');
    colNames = colNames.Name
    
    %data=cell2mat(C);
    data = csvread(InFile) ;
end

