 function [testMAE,valMAE] = lassoAnalysis(dataFold,alpha)
 load([dataFold filesep 'fixed_data.mat']);
 load([dataFold filesep 'lassoOutput2.mat']);
nNeuron = length(newRatio2(:,1));
recLength = length(newRatio2(1,:));
for i =1:nNeuron
   smoothNA(i,:) = smooth(newRatio2(i,:),10); 
end

cutPoint = floor(.6*length(eigAngleFilt));
endTrain = cutPoint;
x = linspace(0,7,100);
lambda = exp(x);
lambda = lambda/400;
%% Validation
endVal = cutPoint;
foldNum = 10;

for f = 1:foldNum
    percTest = .2;
    valNum = ceil(percTest*length(smoothNA(1,:)));
    valFrames = endTrain-100:endTrain-100+valNum;
    
    for dt =1:10
        dataMat = fold(f).alph(alpha).regress(dt).DataMat;
        totLam = length(fold(f).alph(alpha).regress(dt).WeightsdTheta(1,:));
        
        for lam = 1:length(fold(f).alph(alpha).regress(dt).WeightsdTheta(1,:))
            lassoWeights = fold(f).alph(alpha).regress(dt).WeightsdTheta(:,lam);
            int = fold(f).alph(alpha).regress(dt).FitdTheta.Intercept(lam);
            behavPred = lassoWeights'*dataMat+ int;
            x = -100:100;
            sigma =10;
            y = (1/(sigma*sqrt(2)*pi)).*exp((-x.^2)/(2*sigma^2));
            ybet = y/sum(y);
            behavPredFilt = conv(behavPred,ybet, 'same');
            trial(f).valMSE(dt,lam) = (sum((eigAngleFilt(valFrames)' - behavPredFilt(valFrames)).^2))/length(behavPredFilt(valFrames));
            trial(f).valMAE(dt,lam) = sum(abs(eigAngleFilt(valFrames)' - behavPredFilt(valFrames)))/length(behavPredFilt(valFrames));
        end
    end  
end
%%

for dt = 1:10
    %lambda
    for f = 1:foldNum
        trial(f).valMSE(trial(f).valMSE==0) = NaN;
        MSE(f,1:length(trial(f).valMSE(dt,:))) = trial(f).valMSE(dt,:);
        trial(f).valMAE(trial(f).valMAE==0) = NaN;
        MAE(f,1:length(trial(f).valMAE(dt,:))) = trial(f).valMAE(dt,:);
    end


    avgMSE = nanmean(MSE);
    stdMSE = nanstd(MSE);
    [maxMSE, maxMSEidx] = max(avgMSE);
    maxMSEidx = length(avgMSE);
    [minMSE(dt), minMSEidx] = min(avgMSE);

    x = find(avgMSE(minMSEidx:end) > minMSE(dt) + stdMSE(minMSEidx),1);
    if isempty(x) ==1
        bestLamIdx(dt) = 100;
    else
        bestLamIdx(dt) = minMSEidx+x-1;
        %bestLamIdx(dt) = minMSEidx+5;
    end
  % bestLamIdx(dt) = min(LamIdx)+ minMSEidx-1;
    %bestLamIdx(dt) = minMSEidx;
    bestLamVal(dt) = avgMSE(bestLamIdx(dt));

    
    avgMAE = nanmean(MAE);
    stdMAE = nanstd(MAE);
    [maxMAE, maxMAEidx] = max(avgMAE);
    maxMAEidx = length(avgMAE);
    [minMAE(dt), minMAEidx] = min(avgMAE);

    LamIdxMAE = find(avgMAE(minMAEidx:end) > minMAE(dt) + stdMAE(minMAEidx));
  % bestLamIdx(dt) = min(LamIdx)+ minMSEidx-1;
    bestLamIdxMAE(dt) = minMAEidx;
    bestLamValMAE(dt) = avgMAE(bestLamIdxMAE(dt));



    %find best fold
    for i = 1:foldNum
        minMSEfold(i) = trial(i).valMSE(dt,bestLamIdx(dt));
        minMAEfold(i) = trial(i).valMAE(dt,bestLamIdxMAE(dt));
    end
    [bestFoldVal(dt),bestFoldIdx(dt)] = min(minMSEfold);
    [bestFoldValMAE(dt),bestFoldIdxMAE(dt)] = min(minMAEfold);
    
end

%%

for dt = 1:10
    dataMat = fold(bestFoldIdx(dt)).alph(alpha).regress(dt).DataMat;
    weights = fold(bestFoldIdx(dt)).alph(alpha).regress(dt).WeightsdTheta(:,bestLamIdx(dt));
    int = fold(bestFoldIdx(dt)).alph(alpha).regress(dt).FitdTheta.Intercept(bestLamIdx(dt));
    behavPredT = weights'*dataMat+ int;
            x = -100:100;
            sigma =10;
            y = (1/(sigma*sqrt(2)*pi)).*exp((-x.^2)/(2*sigma^2));
            ybet = y/sum(y);
            behavPredFilt = conv(behavPredT,ybet, 'same');
           
            if length(eigAngleFilt) >= length(behavPredFilt)
                testFrames = [(valFrames(end)+1):length(behavPredFilt)];
            else
                testFrames = [(valFrames(end)+1):length(eigAngleFilt)];
            end
    testMSE(dt) = (sum((eigAngleFilt(testFrames)' - behavPredFilt(testFrames)).^2))/length(testFrames);
    valMSE(dt) = (sum((eigAngleFilt(valFrames)' - behavPredFilt(valFrames)).^2))/length(valFrames);
    testMAE(dt) = sum(abs(eigAngleFilt(testFrames)' - behavPredFilt(testFrames)))/length(testFrames);
    valMAE(dt) = sum(abs(eigAngleFilt(valFrames)' - behavPredFilt(valFrames)))/length(valFrames);
    
end

