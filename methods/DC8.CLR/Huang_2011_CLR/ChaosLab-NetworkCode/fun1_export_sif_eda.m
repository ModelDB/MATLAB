
function fun1_export_sif_eda(NetW,nodeNames,varargin)
progArgs1={'-NetSign',[],'-interType','->','-SimName','','-maskOut',[],...
    '-minCut',[],'-outTypes',{'sif','eda'}};
[~,~,NetSign,interType,SimName,maskOut,minCut,outTypes]=...
    fun1_process_arguments(varargin,progArgs1);
nNodes=length(NetW);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(maskOut)
    maskOut=~( isnan(NetW)|eye(nNodes)>0 );
    if ~isempty(minCut)
        maskOut=maskOut&NetW>minCut;
    end
end


if isnumeric(nodeNames)
    nodeNames = cellfun(@(x) sprintf('V%g',x), num2cell(1:nNodes), 'UniformOutput', false);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Vout=NetW(maskOut);
[Vout,idxSort]=sort(Vout,'descend');
[i1out,i2out]=find(maskOut);
i1out=i1out(idxSort);
i2out=i2out(idxSort);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isnumeric(NetSign)&&~isempty(NetSign)
    interType=NetSign(maskOut);
    interType=interType(idxSort);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ismember('sif',lower(outTypes))
    sifFile=[SimName,'.sif'];
    if isnumeric(interType)
        fun1_write_table_multiTypes({nodeNames(i1out),interType,nodeNames(i2out)},...
            sifFile,'-Format','%s\t%g\t%s\n');
    elseif ischar(interType)
        fun1_write_table_multiTypes({nodeNames(i1out),nodeNames(i2out)},...
            sifFile,'-Format',['%s\t',interType,'\t%s\n']);
    elseif iscell(interType)
        fun1_write_table_multiTypes({nodeNames(i1out),interType,nodeNames(i2out)},...
            sifFile,'-Format','%s\t%s\t%s\n');
    end
end
if ismember('eda',lower(outTypes))
    edaFile=[SimName,'.eda'];
    if isnumeric(interType)
        fun1_write_table_multiTypes({nodeNames(i1out),interType,nodeNames(i2out),Vout},...
            edaFile,'-Format','%s (%g) %s = %g\n','-firstLine','EdgeScore');
    elseif ischar(interType)
        fun1_write_table_multiTypes({nodeNames(i1out),nodeNames(i2out),Vout},...
            edaFile,'-Format',['%s (',interType,') %s = %g\n'],'-firstLine','EdgeScore');
    elseif iscell(interType)
        fun1_write_table_multiTypes({nodeNames(i1out),interType,nodeNames(i2out),Vout},...
            edaFile,'-Format','%s (%s) %s = %g\n','-firstLine','EdgeScore');
    end
end