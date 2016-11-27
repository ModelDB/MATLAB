function IdxM = fun1_ind2subM(siz,ndx)

%% IdxM=ind2subM(siz,IND); [I1,I2,I3,...,In] =ind2sub(siz,IND);
% %  IdxM=[I1,I2,I3,...,In];
%% ==============================================================================

if ~isempty(ndx)
    siz = double(siz);
    nout=length(siz);

    siz = [siz(1:nout-1) prod(siz(nout:end))];
    n = length(siz);
    k = [1 cumprod(siz(1:end-1))];
    for i = n:-1:1,
        vi = rem(ndx-1, k(i)) + 1;
        vj = (ndx - vi)/k(i) + 1;
        IdxM(:,i) = vj;
        ndx = vi;
    end
else
    IdxM=[];
end
