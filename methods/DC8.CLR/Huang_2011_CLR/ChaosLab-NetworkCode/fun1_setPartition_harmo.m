% clear;
% N=19;
% Nparts=3;
% Nsets=2;

function Sets=fun1_setPartition_harmo(N,Ngroups,varargin)
progArgs1={'-Npartitons',1,'-doPerm',false,'-Type','reshape','-KsetT',[]};
[~,~,Npartitons,doPerm,Type,KsetT]=fun1_process_arguments(varargin,progArgs1);

if strcmpi(Type(1),'s')
    if isempty(KsetT)
        KsetT=Npartitons*Ngroups;
    end
    Lset=round(N/Ngroups);
    iStart=round(linspace(1,N-Lset+1,KsetT))-1;
    for i=1:KsetT
        Sets{i}=iStart(i)+(1:Lset);
    end
else
    Sets=cell(Npartitons,Ngroups);
    iS=round(linspace(0,N,Ngroups+1));
    for k=1:Npartitons
        if doPerm
            Vk=randperm(N);
        else
            Vk1=1:k*ceil(N/k);
            Vk1=reshape(reshape(Vk1,[k,ceil(N/k)])',[1,length(Vk1)]);
            Vk=Vk1(Vk1<=N);
        end
        for i=1:Ngroups
            Sets{k,i}=sort(Vk(iS(i)+1:iS(i+1)));
        end
    end
end





