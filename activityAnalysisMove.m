function [percTimeAct, percAct] = activityAnalysisMove(dataFolder)
%% Set up data - smooth, deNaN
load([dataFolder filesep 'fixed_data.mat']);


if length(hasPointsTime) > length(newRatio2(1,:))
    hasPointsTime = hasPointsTime(1:length(newRatio2(1,:)));
elseif length(hasPointsTime) > length(newRatio2(1,:))
    newRatio2 = newRatio2(:,1:length(hasPointsTime));
end


smoothR2 = zeros(nNeuron, recLength);

for i = 1:length(newRatio2(:,1));
    smoothR2(i,:) = smooth(newRatio2(i,1:recLength), 30);
end
%% Find activity stats
baseline = quantile(smoothR2(:,100:end)',.2,1);
act = zeros(1,nNeuron);
for i = 1:nNeuron
    se(i) = std(smoothR2(i,:));
        if isempty(find(smoothR2(i,:) > baseline(i) +1.5*se(i))) ==1
            neuStat(i).active = NaN;
        else
        neuStat(i).active = find(smoothR2(i,:) > baseline(i)+1*se(i));
        end
     percTimeAct(i) = length(neuStat(i).active)/recLength;
   if length(neuStat(i).active) > .25*recLength
     act(i) = 1; 
  end
   percAct = sum(act)/nNeuron;  
        
end
     