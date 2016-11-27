%% subM2ind(siz,[I1,I2,...,IN])=sub2ind(siz,I1,I2,...,IN)
function ndx = fun1_subM2ind(siz,IdxM)


%% ==============================================================================

siz = double(siz);
Class1=class(IdxM);

if length(siz)<2
    ndx=int32(IdxM);
else
    [m0,n0]=size(IdxM);
    %Adjust input
    if length(siz)<=(n0+1)-1
        %Adjust for trailing singleton dimensions
        siz = [siz ones(1,(n0+1)-length(siz)-1)];
    else
        %Adjust for linear indexing on last element
        siz = [siz(1:(n0+1)-2) prod(siz((n0+1)-1:end))];
    end

    %Compute linear indices
    k = cast([1 cumprod(siz(1:end-1))],Class1);
    ndx = cast(1,Class1);
    s = size(IdxM(:,1)); %For size comparison
    for i = 1:length(siz),
        v = IdxM(:,i);
        %%Input checking
        if ~isequal(s,size(v))
            %Verify sizes of subscripts
            error('MATLAB:sub2ind:SubscriptVectorSize',...
                'The subscripts vectors must all be of the same size.');
        end
        if (any(v(:) < 1)) || (any(v(:) > siz(i)))
            %Verify subscripts are within range
            error('MATLAB:sub2ind:IndexOutOfRange','Out of range subscript.');
        end
        ndx = ndx + (v-1)*k(i);
    end
end

