function fscoreTest = svmCrossVal(dataFold)
load([dataFold filesep 'fixed_data.mat']);
timeLag =1:10;

%make sure things are the same length
if length(newRatio2(1,:)) > length(ethoHA)
    newRatio2 = newRatio2(:,1:length(ethoHA));
elseif length(newRatio2(1,:)) < length(ethoHA)
    ethoHA = ethoHA(1:length(newRatio2(1,:)));
end

nNeuron = length(newRatio2(:,1));
try
    for i = 1:nNeuron
        smoothNA(i,:) = smooth(newRatio2(i,startFrame:end), 1);
    end
    ethoHA = ethoHA(startFrame:end);
catch
    for i = 1:nNeuron
        smoothNA(i,:) = smooth(newRatio2(i,:), 1);
	end
end
ethoHA = round(ethoHA);

%% generate folds
%define when worm is turning vs not turning
realTurn = find(ethoHA ==2);            
turnReal = ones(size(ethoHA));
turnReal(realTurn) = 2;             %new etho with just 2 = turn, 1 = not turn
trans = diff(turnReal);
revStart = find(trans== 1);         %when turns start
revEnd = find(trans ==-1);          %when turns end
totTrans = length(revStart);        % # of turning events
halfTrans = ceil(totTrans/2);
moreTrans = floor(.8*totTrans);
cutPoint = revStart(moreTrans)-5;
notTurn = find(turnReal(1:cutPoint) == 1);
trainTrans = length(find(revStart < cutPoint));     %turning events for training



for k = 1:trainTrans
   turnNums = 1:trainTrans;
   validT = find(turnNums==k);      %pick the turn for validation
   
    fold(validT).valid =  revStart(validT):revEnd(validT);
    temp = randperm(length(notTurn));
    ntValid = notTurn(temp(1:length(fold(validT).valid)));   %not turning points for the fold
    for i = 1:length(ntValid)
                exclude(i,:) =  ntValid(i)-10:ntValid(i); 
    end
    
    fold(validT).valid = [fold(validT).valid'; ntValid';]; 
    
    turns = find(turnNums ~= k);
    trainTurn = [];
    for j = 1:length(turnNums)-1
        turn = turns(j);
      trainTurn= [trainTurn revStart(turn):revEnd(turn)];
      
    end
    
   toExclude = reshape(exclude, 1,numel(exclude));
   toTrain = setdiff(notTurn,toExclude);
    newTemp = randperm(length(toTrain));
    
    ntTrain = toTrain(newTemp(1:length(trainTurn)));
    fold(validT).train = [trainTurn';ntTrain'];
    
end

%% sparse svm


lambda =logspace(-1, 3,120);

lambda_B = lambda;
for t = 1:length(timeLag)
    %generate time lagged matrix of neural activity
        timeLagMatrix = smoothNA(:,1:end-timeLag(t));
    for i = 2:timeLag(t)
        startN = length(timeLagMatrix(:,1)) +1;
        timeLagMatrix(startN:startN+nNeuron-1, :) = smoothNA(:,i:end-timeLag(t)+i-1);
     
    end
parfor f = 1:length(fold)

    X = timeLagMatrix(:,fold(f).train);
    labels = [ones(.5*length(X(1,:)),1); -ones(.5*length(X(1,:)),1)];
    d = nNeuron*t;
       hinge = @(x) sum(max(0,1-x));
    linearF     = diag(labels)*[ X', -ones(length(labels),1) ];

  
    for la = 1:length(lambda_B)
        mu          = 4*t;     % smoothing parameter
        opts        = [];
        opts.tol    = 1e-4;

        prox        = { prox_hingeDual(1,1,-1), proj_linf(lambda_B(la)) };
        linearF2    = diag( [ones(d,1);0] );

        ak          = tfocs_SCD([],{linearF,[];linearF2,[]}, prox, mu,[],[],opts);
        cv(f).time(t).weights(:,la) = ak(1:nNeuron*t);
        cv(f).time(t).bias(la) = ak(end);
    end
end   
end
%% Validation
%find fscore for each fold in its validaiton role
for t = 1:length(timeLag)

        timeLagMatrix = smoothNA(:,1:end-timeLag(t));
    for i = 2:timeLag(t)
        startN = length(timeLagMatrix(:,1)) +1;
        timeLagMatrix(startN:startN+nNeuron-1, :) = smoothNA(:,i:end-timeLag(t)+i-1);
        
    end
for lam = 1:length(lambda_B)
    
for i = 1:length(cv)
    weights = cv(i).time(t).weights(:,lam);
    toZero = find(weights < .09);
    weightThresh = weights;
    weightThresh(toZero) = 0;
    bias = cv(i).time(t).bias(lam); 
    predCont = weightThresh'*timeLagMatrix(:,fold(i).valid);
    predTurn = find(predCont>= bias);
    ethoPred = ones(1,length(predCont));
    ethoPred(predTurn) = 2;
    fscore(i,lam) = svmEval(ethoPred,turnReal(fold(i).valid));
    
end

end

avgFscore = mean(fscore);
stFscore = std(fscore);
[bestLamVal bestLamIdx] = max(avgFscore);

x = find(avgFscore(bestLamIdx:end) < avgFscore(bestLamIdx)-  stFscore(bestLamIdx),1);
    if isempty(x) ==1
        lamIdx1SE(t) = length(lambda_B);
    else
        lamIdx1SE(t) = bestLamIdx+x;
        
    end
end

%% Testing

for t = 1:length(timeLag)
        timeLagMatrix = smoothNA(:,1:end-timeLag(t));
    for i = 2:timeLag(t)
        startN = length(timeLagMatrix(:,1)) +1;
        timeLagMatrix(startN:startN+nNeuron-1, :) = smoothNA(:,i:end-timeLag(t)+i-1);
    
    end

[bestFoldVal, bestFoldIdx] = max(fscore(:,lamIdx1SE(t)));
    weights = cv(bestFoldIdx).time(t).weights(:,lamIdx1SE(t));
        toZero = find(weights < .09);
    weightThresh = weights;
    weightThresh(toZero) = 0;
    bias = cv(bestFoldIdx).time(t).bias(1,lamIdx1SE(t));
    predCont = weightThresh'*timeLagMatrix(:,cutPoint:end);
    predTurn = find(smooth(predCont,'loess')>= bias);
    ethoPred = ones(1,length(turnReal(cutPoint:end)));
    ethoPred(predTurn) = 2;
    fscoreTest(t) = svmEval(ethoPred,turnReal(cutPoint:end));
end
save([dataFold filesep 'sparseSVM7.mat'], '-v7.3');
