function fscore= svmEval(ethoPred,turnReal)    


    predVal = ethoPred;
    realTurn = find(turnReal ==2);
    predTurn = find(ethoPred==2);
    
    realFor = find(turnReal == 1);
    predFor = find(ethoPred== 1);
    
    truePos =0;
    truePos2 = 0;
    falsePos =0;
    falsePos2 =0;
    falseNeg = 0;
    falseNeg2 = 0;
    trueNeg = 0;
    trueNeg2 = 0;

    % looking at turns and predicted turns (positives)
    
    
    %for when real turns happen, true positives = predicted turn, false
    %negative = real turn, but not one predicted
    for i = 1:length(realTurn)
        if predVal(realTurn(i)) == 2
            truePos = truePos+1;
        elseif predVal(realTurn(i)) == 1
            falseNeg = falseNeg+1;
        end
    end
    
    
    %double check true positives, find false positives
    for i = 1:length(predTurn)
        if turnReal(predTurn(i)) == 2
            truePos2 = truePos2 +1;
        elseif turnReal(predTurn(i)) ==1
            falsePos = falsePos+1;
        end
    end
    
    
    % looking at forward and predicted forward (negatives)
    
    for i = 1:length(realFor)
        if predVal(realFor(i)) ==1
            trueNeg = trueNeg+1;
        elseif predVal(realFor(i)) == 2
            falsePos2 = falsePos2+1;
        end
    end
    
    for i = 1:length(predFor)
        if turnReal(predFor(i)) == 1
            trueNeg2 = trueNeg2 +1;
        elseif turnReal(predFor(i)) == 2
            falseNeg2 = falseNeg2+1;
        end
        
    end
    beta = 1;
    fscore = (1+beta^2)*truePos/((1+beta^2)*truePos+beta*falseNeg+falsePos);
    MCC = (truePos*trueNeg - falsePos*falseNeg)/sqrt((truePos+falseNeg)*(truePos+falseNeg)*(trueNeg+falsePos)*(trueNeg+falseNeg));