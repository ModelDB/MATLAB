clear
tic 
sExpName = 'E04';
sFileName = [sExpName '.mat'];
if exist(sFileName,'file') 
    load(sFileName);
else
    oExperiment = MDBExperiment(sExpName); 
    save(sFileName, 'oExperiment');
end

sSevere = {'RMe','RFa'};
sMild = {'RIc','RSb'};
cName = horzcat(sSevere,sMild); 

for i = 1:2 
    for j = 1:8
        if strncmp(sSevere{i},oExperiment.Subject{j}.Name,3) == 1 
            mIdxMonkeys(i) = j;
        end
        if strncmp(sMild{i},oExperiment.Subject{j}.Name,3) == 1 
            mIdxMonkeys(i+2) = j;
        end
    end
end

sFileName = [sExpName 'CompleteData.mat'];
Idx = 1; 
if exist(sFileName,'file')
    load(sFileName) 
else 
    %%%%%%%%%% Get INNATE IMMUNE DATA%%%%%%%%%%%%%%%%%
    oExplorer = MDBAnalysis();
    n = 1;


    for i =1:length(mIdxMonkeys)
            x = oExperiment.Subject{mIdxMonkeys(i)};
            T = x.Data('INNATE_IMMUNE_MEASUREMENT').getTimeSeries({},n,[],[],[],'INNATE_IMMUNE_MEASUREMENT');
            oExplorer.Data{Idx} = T;
            Idx = Idx + 1; 
    end

    %%%%%%%%% Get Adaptive Immune Data%%%%%%%%%%%%%%


    for i =1:length(mIdxMonkeys)
            x = oExperiment.Subject{mIdxMonkeys(i)};
            T = x.Data('ADAPTIVE_IMMUNE_MEASUREMENT').getTimeSeries({},n,[],[],[],'ADAPTIVE_IMMUNE_MEASUREMENT');
            oExplorer.Data{Idx} = T; 
            Idx = Idx + 1; 

    end

    %%%%%%%%% Get Clinical Data %%%%%%%%%%%%%%%%%%%%%


    for i =1:length(mIdxMonkeys)
            x = oExperiment.Subject{mIdxMonkeys(i)};
            T = x.Data('CLINICAL_MEASUREMENT').getTimeSeries({},n,[],[],[],'CLINICAL_MEASUREMENT');
            oExplorer.Data{Idx} = T; 
            Idx = Idx + 1; 

    end
    %%%%%%%% Get Bone Marrow Functional Genomics%%%%%%%%%%%%%%%%
    cMetaData = oExperiment.Subject{mIdxMonkeys(i)}.Data('FXGN').DataAssociations;
    k(1) = find(strcmp(cMetaData(:,2),'libsize_normalized')); 
    k(2) = find(strcmp(cMetaData(:,2),'Lymphocytes')); 
    cMetaData = cMetaData(k,:); 

    for i =1:length(mIdxMonkeys)
            x = oExperiment.Subject{mIdxMonkeys(i)};
            T = x.Data('FXGN').getTimeSeries(cMetaData,n,[],[],[],'NAME');
            oExplorer.Data{Idx} = T; 
            Idx = Idx + 1; 

    end
    %%%%%%%% Get Whole Blood Functional Genomics%%%%%%%%%%%%%%%%
    n = 1; 
    cMetaData = oExperiment.Subject{mIdxMonkeys(i)}.Data('FXGN').DataAssociations;
    k(1) = find(strcmp(cMetaData(:,2),'libsize_normalized')); 
    k(2) = find(strcmp(cMetaData(:,2),'Whole blood')); 
    cMetaData = cMetaData(k,:); 

    for i =1:length(mIdxMonkeys)
            x = oExperiment.Subject{mIdxMonkeys(i)};
            T = x.Data('FXGN').getTimeSeries(cMetaData,n,[],[],[],'NAME');
            oExplorer.Data{Idx} = T; 
            Idx = Idx + 1; 

    end
    %%%%%%% Get Whole Blood Lipidomics 
    n = 1; 
    cMetaData = oExperiment.Subject{mIdxMonkeys(i)}.Data('LIPIDOMIC').DataAssociations;
    %k = find(strcmp(cMetaData(:,2),'Area_Ratio_QC_Normalized'));
    k = find(strcmp(cMetaData(:,2),'RAW')); 
    cMetaData = cMetaData(k,:);
    for i =1:length(mIdxMonkeys)
            x = oExperiment.Subject{mIdxMonkeys(i)};
            T = x.Data('LIPIDOMIC').getTimeSeries(cMetaData,n,[],[],[],'NAME');
            oExplorer.Data{Idx} = T; 
            Idx = Idx + 1; 

    end
    save(sFileName,'oExplorer');
end
%%%%%%%%%%%%Filter FXGN Data%%%%%%%%%%%%%%%%%%%%

mIdxFXGN = oExplorer.findDataType('FXGN'); 
oExplorer = oExplorer.filterTimeSeries(mIdxFXGN,2,0);
oExplorer = setMeanVarTimeSeries(oExplorer,[]);
 
%%%%%%%%%%%% Start Analysis By Generating New MDBObject that have the
%%%%%%%%%%%% aggregated time aligned data 
Idx = [1 5 9 13 17 21;2 6 10 14 18 22;3 7 11 15 19 23;4 8 12 16 20 24];


oExplorerAggregated = MDBAnalysis(); 

for i = 1:4 
    oExplorerAggregated.Data{i} = oExplorer.aggregateTimeSeries(Idx(i,[1 2 3 5]));
end

oExplorerAggregated = oExplorerAggregated.filterMissingData(); 
oExplorerAggregated = oExplorerAggregated.filterSharedVariables(); 

g1 = [1 2];
g2 = [3 4];
%%%%%%%%%%%% Run MPATS %%%%%%%%%%%%%%%%%%%%%%%

strucMPATS = oExplorerAggregated.MPATS(g1,g2,5000); 

%%%%%%%%%%%% Run Differential Correlation %%%%%%%%%%%%%

strucDiffCorr = oExplorerAggregated.DiffCorr(g1,g2,'spearman');
strucDiffCorr2 = oExplorerAggregated.DiffCorr(g1,g2,'pearson'); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oExplorerDiscretized = oExplorerAggregated.discretizeByGroup({[1 2],[3 4]},6);
%%%%%%%%%%%% Run FunChiSQ %%%%%%%%%%%%%%
strucChiSQ = oExplorerDiscretized.Chi2(g1,g2,'Pearson'); 
strucChiSQ2 = oExplorerDiscretized.Chi2(g1,g2,'funChiSQ');
%%%%%%%%%%%%%%Graph %%%%%%%%%%%%%%%%%%%%

sName = 'E04MildSevereAI_II_CLINICAL';

save('E04MildSevereAI_II_CLINICAL.mat'); 

cNames = {'MPATS','Spearman','Pearson','PTest','funChiSQ','Consensus'}; 

Consensus = zeros(1,length(strucMPATS.Pvalue));

 

cDistance = {(1 - strucMPATS.Pvalue),(1-strucDiffCorr.Pval),(1 - strucDiffCorr2.Pval),...
    strucChiSQ.AbsDiffEffectSize, strucChiSQ2.AbsDiffEffectSize/(max(strucChiSQ2.AbsDiffEffectSize))};

for i = 1:length(cDistance) 
    temp = cDistance{i}; 
    temp(isnan(temp)) = 0;
    cDistance{i} = temp; 
    Consensus = Consensus + cDistance{i}; 
end

Consensus = Consensus/5; 


for i = 1:5 
    mDiff(i) = mean(abs(Consensus - cDistance{i}));
end
bar(mDiff');
set(gca,'xticklabel', {'MPATS','Pearson','Spearman','TOI','FunChiSQ'});
title('Difference to Consensus'); 
ylabel('Average Difference to Consensus');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[aFDR q1] = mafdr(strucMPATS.Pvalue,'Method','polynomial'); 
[aFDR q2] = mafdr(strucDiffCorr.Pval,'Method','polynomial'); 
[aFDR q3] = mafdr(strucDiffCorr2.Pval,'Method','polynomial'); 


Consensus = zeros(1,length(strucMPATS.Pvalue));

 

cDistance = {(1 - q1),(1-q3),(1 - q2),...
    strucChiSQ.AbsDiffEffectSize, strucChiSQ2.AbsDiffEffectSize/(max(strucChiSQ2.AbsDiffEffectSize))};

for i = 1:length(cDistance) 
    temp = cDistance{i}; 
    temp(isnan(temp)) = 0;
    cDistance{i} = temp; 
    Consensus = Consensus + cDistance{i}; 
end

Consensus = Consensus/5; 


for i = 1:5 
    mDiff(i) = mean(abs(Consensus - cDistance{i}));
end

h = figure('units','normalized','outerposition',[0 0 1 1]);
bar(mDiff);
set(gca,'xticklabel', {'MPATS','Pearson','Spearman','PToI','FunChiSQ'});
title('Difference to Consensus','FontSize',36); 
ylabel('Average Difference to Consensus','FontSize',27);
set(gca,'FontSize',27);
funPrintImage(h,'C:\Users\yihen\Downloads\DistanceToConsensus');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = figure('units','normalized','outerposition',[0 0 1 1]);
hist(Consensus,100);
title('Distribution Of Confidence Score','FontSize',36); 
ylabel('Number of Pairwise Interaction');
xlabel('Confidence Score');
set(gca,'FontSize',27);
funPrintImage(h,'C:\Users\yihen\Downloads\ScoreDistribution');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp2 = temp >= 0.5; 
h = figure('units','normalized','outerposition',[0 0 1 1]);
hist(sum(temp2),100);
title('Per Entity High Confidence Distribution','FontSize',36); 
ylabel('Number of entity');
xlabel('Number of score > 0.5');
set(gca,'FontSize',27);
funPrintImage(h,'C:\Users\yihen\Downloads\EntityEdgeDistribution');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mConn = squareform(Consensus); 
mConnThreshold = mConn >= 0.65; 
[S, C] = graphconncomp(sparse(mConnThreshold));
idx = []; 
for i = 1:S
    temp = find(C == i);
    idx = [idx temp];
end
h = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(1,2,1)
colormap jet
imagesc(mConn(idx,idx));
colorbar();
set(gca,'FontSize',18);
title('Heat Map of Confidence Score','FontSize',24); 

pIdx = [3 4 7 8];


idx = find(strcmp('parasites',strucMPATS.Names));

mPara = mConn(idx,:); 
[a b] = sort(mPara,'descend'); 
idx = find(strcmp('parasites',oExplorerAggregated.Data{1}.DataPrimitive.VarNames));
sParasite = [oExplorerAggregated.Data{1}.DataPrimitive.Table(idx,:) oExplorerAggregated.Data{2}.DataPrimitive.Table(idx,:)]; 
mParasite = [oExplorerAggregated.Data{3}.DataPrimitive.Table(idx,:) oExplorerAggregated.Data{4}.DataPrimitive.Table(idx,:)];
for i = 2:5
    subplot(2,4,pIdx(i-1));
    idx2 = find(strcmp(strucMPATS.Names(b(i)),oExplorerAggregated.Data{1}.DataPrimitive.VarNames));
    severe = [oExplorerAggregated.Data{1}.DataPrimitive.Table(idx2,:) oExplorerAggregated.Data{2}.DataPrimitive.Table(idx2,:)]; 
    mild = [oExplorerAggregated.Data{3}.DataPrimitive.Table(idx2,:) oExplorerAggregated.Data{4}.DataPrimitive.Table(idx2,:)]; 
    plot(sParasite,severe,'rx','MarkerSize',10);
    hold on
    plot(mParasite,mild,'bo','MarkerSize',10);
    legend({'Severe','Mild'}); 
    xlabel('Parasitemia','FontSize',18);
    modifiedStr = strrep(strucMPATS.Names(b(i)), '_', ' ');

    ylabel(modifiedStr,'FontSize',18);
    title(['Concensus Score = ' num2str(a(i))],'FontSize',20);
    set(gca,'FontSize',18);

end

funPrintImage(h,'C:\Users\yihen\Downloads\HeatMap');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cNames = {'parasites','platelets','hgb','wbc','perc_monocytes','perc_reticulocytes'}; 
temp = squareform(Consensus); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = figure('units','normalized','outerposition',[0 0 1 1]);

for j = 1:6
    idx = find(strcmp(cNames{j},strucMPATS.Names));
    subplot(2,3,j);
    hist(temp(idx,:),100);
    title(num2str(sum(temp(idx,:)>0.5)));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:6
    
    fileName = [cNames{j} '.csv'];
    idx = find(strcmp(cNames{j},strucMPATS.Names));
    temp = mConn(idx,:); 
    idx2 = find(temp >= 0.5); 
    cTopGeneCellNames = strucMPATS.Names(idx2); 
    cTopGeneCellNames = vertcat(cNames{j},cTopGeneCellNames);
    mL = mConn([idx idx2],[idx idx2]); 
    mL2 = mL; 
    mL = mL >= 0.5; 
    fileID = fopen(fileName,'w');
    fprintf(fileID, ['Source\tTarget\tWeight\n']);
    
        for i = 1:size(mL,1)
            for k = i:size(mL,2) 
                if mL(i,k) ~= 0 
                    fprintf(fileID, [cTopGeneCellNames{i} '\t' cTopGeneCellNames{k} '\t' num2str(mL2(i,k)) '\n']);
                end
            end
        end
    fclose(fileID);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1:6
    
    fileName = [cNames{j} '.rnk'];
    idx = find(strcmp(cNames{j},strucMPATS.Names));
    temp = mConn(idx,:); 
    [a b] = sort(temp,'descend'); 

    fileID = fopen(fileName,'w');
    
        for i = 1:size(a,2)

           
                    fprintf(fileID, [strucMPATS.Names{b(i)} '\t' num2str(a(i)) '\n']);

 
        end
    fclose(fileID);

end

temp = mConn >= 0.5;
mConnSum = sum(mConn); 
 fileName = ['Consensus.rnk'];
    [a b] = sort(mConnSum,'descend'); 

    fileID = fopen(fileName,'w');
    
        for i = 1:size(a,2)

           
                    fprintf(fileID, [strucMPATS.Names{b(i)} '\t' num2str(a(i)) '\n']);

 
        end
    fclose(fileID);
toc