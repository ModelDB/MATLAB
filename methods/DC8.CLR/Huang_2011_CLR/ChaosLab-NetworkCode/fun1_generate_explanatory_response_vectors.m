%% %%%%%% generate explanatory vectors and response vectors from time series %%%%%%
%  written by Huang Xun (bioxun@gmail.com)
%  BIOSS Centre for Biological Signalling Studies, University of Freiburg, 79104, Freiburg, Germany.

function [vects_explanat,vects_response,LsectionsT] = fun1_generate_explanatory_response_vectors(Data, varargin)
% Data:             nNodes*nCases matrix, 
% vects_explanat:   nNodes*(nCases-nLags*length(Sections)) matrix, explanatory vectors
% vects_response:   nNodes*(nCases-nLags*length(Sections)) matrix, response vectors
% Lags:             number of time points which response vectors lagged behind explanatory vectors 
%                   (If it is an array, all these lags will be considered.)
% Lsections:        1*n_timeseries vector, recording length of each timeseries
% LsectionsT:       1*n_timeseries vector, recording length of each section after transformation
[nNodes,nCases] = size(Data);
progArgs1={'-Lags',1,'-Lsections',nCases};
[~,~,Lags,Lsections]=fun1_process_arguments(varargin,progArgs1);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nsect=length(Lsections);
iSects=[0,cumsum(Lsections)];
NlagsDbn=length(Lags);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LsectionsT=NaN(1,Nsect);
for i=1:Nsect
    SectDbns1=max(0,Lsections(i)-Lags);
    LsectionsT(i)=sum(SectDbns1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vects_explanat=NaN(nNodes,sum(LsectionsT));
vects_response=NaN(nNodes,sum(LsectionsT));
i1P=1;
for j=1:Nsect
    for iLag=1:NlagsDbn
        Lag=Lags(iLag);
        i2P=i1P+Lsections(j)-Lag-1;
        vects_explanat(:,i1P:i2P)=Data(:,(iSects(j)+1):(iSects(j)+Lsections(j)-Lag));
        vects_response(:,i1P:i2P)=Data(:,(iSects(j)+1+Lag):(iSects(j)+Lsections(j)));
        i1P=i2P+1;
    end
    i2P=i1P-1;
    i1P=i2P+1;
end

