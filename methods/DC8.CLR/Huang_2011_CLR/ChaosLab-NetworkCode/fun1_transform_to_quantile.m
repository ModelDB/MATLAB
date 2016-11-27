% % clear
% % x0=[0,1,2,1,0,0,0,0,7,5,2,11,20,77,0,3];
% x0=[0,1,2,1;0,0,0,0;7,5,2,11;20,77,0,3];
% x0=[0,1,2,NaN;0,0,0,0;7,5,2,11;20,77,0,3];
% x0=[0,1,2,77;0,0,0,0;7,5,2,11;20,77,0,3];
% x0=[9,9,9,1,2,2,2,5,6,10];

% %%%%%%%%%%%%%%%%%%%%%
% matr=magic(6);
% matr=tril(matr,-1);
% % x=squareform(matr);
% ValueFind='Value>10';
% matr=[300,100,200;
%     100,300,400;
%     100,400,100;
%     ];
% idx0=find(matr>0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x=[11,22,33,44,55];x0=randsample(x,8,1);
% quantile(x0,fun1_transfMatrToRankRate_center(x0))-x0     % should be zeros

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% the bigger value is, the bigger rank rate is, e.g. the rank rate of the biggest one is 1;
%  if two value are same, their rank rate are the same
%% quantile(x0,YrankR)==x0  % try
function YrankR=fun1_transform_to_quantile(x0) 
%  equivalent to   fun1_transfMatrToRankRate_center(x0)==fun1_transfMatrToRank_center(x0)/nnz(~isnan(x0));
%  similar to ecdf(y,varargin)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx1=find(~isnan(x0));
% x0=matr(idx0);
[s1,s2]=size(x0);
[x,idxS]=sort(x0(idx1));
[~, ~, v] = unique(x);
clear('x')
v1=diff(v);
rv=find(v1==1);
clear('v1')

%%%%%%%%%%%%%%%%%%%%%
n=length(v);
v(1:rv(1))=rv(1)/2;
for i=2:length(rv)
    v(rv(i-1)+1:rv(i))=(rv(i)+rv(i-1))/2;
end
v(rv(end)+1:n)=(n+rv(end))/2;

%%%%%%%%%%%%%%%%%%%%%
YrankR=NaN(s1,s2);
YrankR(idx1(idxS))=v/n;

%% %%%%%%%%%%%%%%%%%%%%%
% idxS=idxS/n;
% %%%%%%%%%%%%%%%%%%%%%%%
% siz=size(matr);
% matr(idx0)=YrankR;
