classdef MDBAnalysis
    properties
        Data % Cell array of tables where each element maps MBDData.Data
    end
    
    methods
        function out = plotTimeSeries(o,cGroups,cVariables)
            numVar = length(cVariables); 
            for i = 1:length(o.Data)
                mIDs(i) = o.Data{i}.ID; 
            end 
            figure(1);
            for i = 1:length(cVariables) 
                
                subplot(1,numVar,i) 
                hold on 
                for j = 1:length(cGroups) 
    
                    for k = 1:length(cGroups{j})
                        x = [];
                        y = [];
                        idx = find(mIDs == cGroups{j}(k));
                        
                        idx2 = find(strcmp(o.Data{idx}.Table.RowNames,cVariables{i})); 
                        for m = 1:length(o.Data{idx}.Table.ColNames)
                            x = [x datenum(o.Data{idx}.Table.ColNames(m))];
                        end
                        y = table2array(o.Data{idx}.Table.Data(idx2,2:end));
                        [a b] = sort(x); 
                        
                        plot(x(b),y(b),'o-');
                    end
                end
                title(cVariables{i})
                hold off 
            end
        end
        function o = filterTimeSeries(o,mIdx,fThreshold,nOccurence)
            if isempty(mIdx) == 1
                for i = 1:length(o.Data)
                    temp = sum(o.Data{i}.Table.Data <= fThreshold,2);
                    idx = temp <= nOccurence; 
                    o.Data{i}.DataPrimitive.Table = o.Data{i}.DataPrimitive.Table(idx,:);
                    o.Data{i}.DataPrimitive.VarNames = o.Data{i}.DataPrimitive.VarNames(idx,:);
                end
            else 
                for i = 1:length(mIdx)
                    temp = sum(o.Data{mIdx(i)}.DataPrimitive.Table <= fThreshold,2);
                    idx = temp <= nOccurence; 
                    o.Data{mIdx(i)}.DataPrimitive.Table = o.Data{mIdx(i)}.DataPrimitive.Table(idx,:);
                    o.Data{mIdx(i)}.DataPrimitive.VarNames = o.Data{mIdx(i)}.DataPrimitive.VarNames(idx,:);
                end
            end
        end
        function o = filterMissingData(o)

            for i = 1:length(o.Data) 
                temp = sum(isnan(o.Data{i}.DataPrimitive.Table),2); 
                ia = temp == 0;
                o.Data{i}.DataPrimitive.Table = o.Data{i}.DataPrimitive.Table(ia,:); 
                o.Data{i}.DataPrimitive.VarNames = o.Data{i}.DataPrimitive.VarNames(ia,:);
            end
        end
        function o = setMeanVarTimeSeries(o,mIdx)
            if isempty(mIdx) == 1
                for i = 1:length(o.Data)
                    for j = 1:size(o.Data{i}.DataPrimitive.Table,1)
                        temp1 = mean(o.Data{i}.DataPrimitive.Table(j,:)); 
                        temp2 = std(o.Data{i}.DataPrimitive.Table(j,:));
                        o.Data{i}.DataPrimitive.Table(j,:) = o.Data{i}.DataPrimitive.Table(j,:) - temp1; 
                        o.Data{i}.DataPrimitive.Table(j,:) = o.Data{i}.DataPrimitive.Table(j,:)/temp2;
                    end
                end
            else
                for i = 1:length(mIdx)
                    for j = 1:size(o.Data{mIdx(i)}.DataPrimitive.Table,1)
                        temp1 = mean(o.Data{mIdx(i)}.DataPrimitive.Table(j,:)); 
                        temp2 = std(o.Data{mIdx(i)}.DataPrimitive.Table(j,:));
                        o.Data{mIdx(i)}.DataPrimitive.Table(j,:) = o.Data{mIdx(i)}.DataPrimitive.Table(j,:) - temp1; 
                        o.Data{mIdx(i)}.DataPrimitive.Table(j,:) = o.Data{mIdx(i)}.DataPrimitive.Table(j,:)/temp2;
                    end
                end
            end
            
        end
        function Idx = findDataType(o,sDataType)
            Idx = [];
            for i = 1:length(o.Data)
               if strcmp(o.Data{i}.DataType{2},sDataType) == 1
                   Idx = [Idx i];
               end
            end
        end
        function p = aggregateTimeSeries(o,mIdx)
            p = o.Data{mIdx(1)}; 
            for i = 2:length(mIdx)
                p2 = o.Data{mIdx(i)}; 
                p.DataType = vertcat(p.DataType,p2.DataType); 
                p.VarNames = vertcat(p.VarNames,p2.VarNames);
                p.DataAssociations = []; 
                p.Metadata = vertcat(p.Metadata,p2.Metadata); 
                T1 = p.DataPrimitive.Time;
                T2 = p2.DataPrimitive.Time; 
                [T ia ib] = intersect(T1,T2);  
                M1 = p.DataPrimitive.Table(:,ia);
                M2 = p2.DataPrimitive.Table(:,ib); 
                V1 = p.DataPrimitive.VarNames; 
                V2 = p2.DataPrimitive.VarNames; 
                p.DataPrimitive =  MDBTimeSeries(T,vertcat(V1,V2),[M1;M2]);
            end
        end
        function o = filterSharedVariables(o)
            cVar = o.Data{1}.DataPrimitive.VarNames; 
            for i = 2:length(o.Data) 
                cVar = intersect(o.Data{i}.DataPrimitive.VarNames,cVar); 
            end 
            for i = 1:length(o.Data) 
                [temp ia ib] = intersect(o.Data{i}.DataPrimitive.VarNames,cVar); 
                o.Data{i}.DataPrimitive.Table = o.Data{i}.DataPrimitive.Table(ia,:); 
                o.Data{i}.DataPrimitive.VarNames = o.Data{i}.DataPrimitive.VarNames(ia,:);
            end
        end
        function o = discretizeByGroup(o,cG,nMaxDiscrete)
            for l = 1:length(cG)
                mG1 = cG{l};
                M1 = []; 
                mLabel = [];
                for i = 1:length(mG1)

                    M1 = [M1 o.Data{mG1(i)}.DataPrimitive.Table];
                    
                    mLabel2 = [];
                    
                    mLabel2(1:size( o.Data{mG1(i)}.DataPrimitive.Table,2)) = mG1(i);

                    mLabel = [mLabel mLabel2];

                end

                %%%%%%%%%%%Discretization %%%%%%%%%%%%%%%
                n1 = size(M1,1); 

                display(['Discretizing Group ' num2str(l)]);
                M1n = MDBAnalysis.EstimateN(M1,nMaxDiscrete);


                for i = 1:size(M1,1)
                    if M1n(i) == 1 
                        M1n(i) = 3;
                    end
                    temp = kmeans(M1(i,:)',M1n(i)); 
                    M1(i,:) = temp';
                end

                for i = 1:length(mG1)
                    o.Data{mG1(i)}.DataPrimitive.Table = M1(:,mLabel == mG1(i));
                end
            end 
        end
        function strucMPATS = MPATS(o,mG1,mG2,nEpsilon)
            N1 = length(mG1); 
            N2 = length(mG2); 
            nSG1 = length(mG1);
            
            TemporalRelation = [];
            
            for i = 1:nSG1
                dist1 = pdist(o.Data{mG1(i)}.DataPrimitive.Table,'cityblock') + nEpsilon; 
                TemporalRelation(i,:) = dist1';
            end
            
            for i = 1:length(mG2)
                dist1 = pdist(o.Data{mG2(i)}.DataPrimitive.Table,'cityblock') + nEpsilon;
                TemporalRelation(i+nSG1,:) = dist1';
            end
            
            Pvalue = zeros(1,size(TemporalRelation,2));
            FoldChange = Pvalue;
            
            for i = 1:size(TemporalRelation,2)
                   [h p ci stats] = ttest2(TemporalRelation(1:nSG1,i),TemporalRelation(nSG1+1:end,i));
                   Pvalue(i) = p;
                   TStats(i) = stats.tstat; 
            end
            
            strucMPATS.Pvalue = Pvalue;
            strucMPATS.TStats = TStats;
            strucMPATS.Names = o.Data{1}.DataPrimitive.VarNames;
            
        end
        function strucDiffCorr = DiffCorr(o,mG1,mG2,sCorrType) 
            M1 = o.Data{mG1(1)}.DataPrimitive.Table; 
            M2 = o.Data{mG2(1)}.DataPrimitive.Table;
            for i = 1:length(mG1)
                M1 = [M1 o.Data{mG1(i)}.DataPrimitive.Table];
            end
            for i = 1:length(mG2)
                M2 = [M2 o.Data{mG2(i)}.DataPrimitive.Table];
            end
            CorrM1 = corr(M1','type',sCorrType);
            j = size(CorrM1,1);
            CorrM1(1:j+1:j*j) = 0; 
            mDiffCorr(1,:) = squareform(CorrM1); 
            
            CorrM2 = corr(M2','type',sCorrType);
            j = size(CorrM2,1);
            CorrM2(1:j+1:j*j) = 0; 
            mDiffCorr(2,:) = squareform(CorrM2);
            
            zTransform = @(x) 0.5*(log((1+x)/(1-x)));
            mZ = arrayfun(@(x) zTransform(x),mDiffCorr);
            a = size(M1,2); 
            b = size(M2,2); 

            for i = 1:size(mDiffCorr,2)
                out(i) = (mZ(1,i) - mZ(2,i))/sqrt(1/(a-3)+1/(b-3));
                absDiff(i) = mDiffCorr(1,i) - mDiffCorr(2,i); 
            end

            pVal = 2*normcdf(-abs(out));
            strucDiffCorr.Pval = pVal; 
            strucDiffCorr.Names = o.Data{mG1(1)}.DataPrimitive.VarNames; 
            strucDiffCorr.absDiff = absDiff; 
            strucDiffCorr.zStats = out; 
            strucDiffCorr.Type = sCorrType; 
        end
        function strucChi2 = Chi2(o,mG1,mG2,sChi2Type)
            
            M1 = []; 
            M2 = [];
            for i = 1:length(mG1)
                M1 = [M1 o.Data{mG1(i)}.DataPrimitive.Table];
            end
            for i = 1:length(mG2)
                M2 = [M2 o.Data{mG2(i)}.DataPrimitive.Table];
            end
            
                n1 = size(M1,1); 
                n2 = size(M2,1); 

            M1PVal = zeros(n1,n1);
            M2PVal = zeros(n2,n2);
            M1EffectSize = M1PVal; 
            M2EffectSize = M2PVal; 
            display('Start Analysis');
            switch sChi2Type 
                case 'funChiSQ'
                    display('Start G1 Analysis'); 
                     for i = 1:n1
                        display(['Entity ' num2str(i) '/' num2str(n1-1)]);
                        tic 
                        for j = 1:n1
                            if j~= i
                            %display(['Column ' num2str(j)]);
                            %tic;
                            temp1 = M1(i,:); 
                            temp2 = M1(j,:); 
                            cTable = MDBAnalysis.ContigencyTable(temp1,temp2); 
                            %tic
                            [pval V] = MDBAnalysis.funChi2(cTable); 
                            %toc
                            M1PVal(i,j) = pval; 
                            M1EffectSize(i,j) = V; 
                            %toc;
                            end
                        end
                        toc
                    end


                    display('Start G2 Analysis'); 

                    for i = 1:n2
                         display(['Entity ' num2str(i) '/' num2str(n2-1)]);
                        tic
                        for j = 1:n2
                            if j~= i
                            temp1 = M2(i,:); 
                            temp2 = M2(j,:); 
                            cTable = MDBAnalysis.ContigencyTable(temp1,temp2); 
                            [pval V] = MDBAnalysis.funChi2(cTable); 
                            M2PVal(i,j) = pval; 
                            M2EffectSize(i,j) = V; 
                            end
                        end
                        toc
                    end
 

                case 'Pearson'
                    for i = 1:(n1-1)
                        display(['Entity ' num2str(i) '/' num2str(n1-1)]);

                        for j = i+1:n1 
                            temp1 = M1(i,:); 
                            temp2 = M1(j,:); 
                            cTable = MDBAnalysis.ContigencyTable(temp1,temp2); 
                            [pval V] = MDBAnalysis.funPearsonChi2(cTable); 
                            M1PVal(i,j) = pval; 
                            M1EffectSize(i,j) = V; 
                        end
                    end
                    M1PVal = M1PVal + M1PVal'; 
                    M1EffectSize = M1EffectSize + M1EffectSize';
                    for i = 1:(n2-1)
                        display(['Entity ' num2str(i) '/' num2str(n1-1)]);

                        for j = i+1:n2 
                            temp1 = M2(i,:); 
                            temp2 = M2(j,:); 
                            cTable = MDBAnalysis.ContigencyTable(temp1,temp2); 
                            [pval V] = MDBAnalysis.funPearsonChi2(cTable); 
                            M2PVal(i,j) = pval; 
                            M2EffectSize(i,j) = V; 
                        end
                    end
                    M2PVal = M2PVal + M2PVal'; 
                    M2EffectSize = M2EffectSize + M2EffectSize';
                otherwise
                    display('Wrong Input'); 
            end
            strucChi2.G1Pval = squareform(M1PVal); 
            strucChi2.G1EffectSize = squareform(M1EffectSize); 
            strucChi2.G2Pval = squareform(M2PVal); 
            strucChi2.G2EffectSize = squareform(M2EffectSize);
            strucChi2.AbsDiffEffectSize = abs(squareform(M1EffectSize) - squareform(M2EffectSize)); 
            strucChi2.VarNames = o.Data{mG1(1)}.DataPrimitive.VarNames; 
            strucChi2.Type = sChi2Type; 
            
        end
        
        
    end
    
    methods(Static)
        function n = EstimateN(M1,nMaxDiscrete) 
                k = 1:nMaxDiscrete;
                nK = numel(k);
                RegularizationValue = 0.01;
                options = statset('MaxIter',10000);
                gm = cell(1,nK);
                aic = zeros(1,nK);
                bic = zeros(1,nK);

            n = [];
            for l = 1:size(M1,1) 
                X = M1(l,:); 
            
                % Preallocation

                % Fit all models

                        for i = 1:nK
                            gm{i} = fitgmdist(X',k(i),...
                                'RegularizationValue',RegularizationValue,...
                                'CovarianceType','full',...
                                'SharedCovariance',true,...
                                'Options',options);
                            aic(i) = gm{i}.AIC;
                            bic(i) = gm{i}.BIC;
                        end
                    


  
                nAIC = find(aic == min(aic));

                nBIC = find(bic == min(bic));

                n(l) = min([nAIC nBIC]); 
            end
            
        end
        function [pval V]= funPearsonChi2(X) 
            df = (size(X,1)-1)*(size(X,2)-1);
            if df == 0
                df = 1; 
            end
            Total = sum(sum(X));
            for j = 1:size(X,2)
                for i = 1:size(X,1)
                    temp = (sum(X(:,j))*sum(X(i,:)))/Total;
                    chi2 = (X(i,j) - temp)^2;
                    chi2 = chi2/temp;
                    X2(i,j) = chi2; 
                end
            end
            X2 = sum(sum(X2));
            pval = 1 - chi2cdf(X2,df);
            V = sqrt(X2/(Total*df));
        end
        function ConTable = ContigencyTable(A,B)
             a = unique(A); 
             b = unique(B); 
             ConTable = zeros(length(a),length(b)); 
             for i = 1:length(a)
                  for j = 1:length(b)
         
                          ConTable(i,j) = sum(A == i & B == j);                   
                  end
             end
        end
        function [pVal X2]= funChi2(X) 

            r = size(X,1); 
            s = size(X,2); 
            n = sum(sum(X));
            df = (r-1)*(s-1);
            tempSum = sum(X,2)/s;
             
            A = zeros(r,s);
            for i = 1:r
                for j = 1:s
                    A(i,j) = ((X(i,j) - tempSum(i))^2)/tempSum(i);
                end
            end
            
            A = sum(sum(A));
            B = zeros(1,s);
            tempSum = sum(X);
            holder = n/s; 
            
            for j = 1:s 
                 
                B(j) = ((tempSum(j) - holder)^2)/holder; 
            end
            B = sum(B); 

            X2 = A - B; 
            pVal = 1 - chi2cdf(X2,df);
            V = sqrt(X2/(n*df));
        end
    end
end

