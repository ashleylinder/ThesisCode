function [percTimeAct, percAct] = activityAnalysisImmob(dataFolder)
%%set up data, smooth and denan
load([dataFolder filesep 'betterHeat.mat']);
nNeuronStart = length(Ratio2(:,1));
recLength = length(Ratio2(1,startFrame:endFrame));
for i = 1:nNeuronStart
    bad(i) = length(find(isnan(Ratio2(i,startFrame:endFrame))));
    percBad(i) = bad(i)/recLength;
end
m = mean(percBad);
s = std(percBad);

goodN = find(percBad <=m+s);
cropRatio2 = Ratio2(goodN,startFrame:endFrame);

newRatio2 = denanRatio2(cropRatio2);
nNeuron = length(newRatio2(:,1));


smoothR2 = zeros(nNeuron, recLength);
gdRatio2 = zeros(nNeuron, recLength);
for i = 1:length(newRatio2(:,1));
    smoothR2(i,:) = smooth(newRatio2(i,:), 60);
end
%% Find statistics of activity
baseline = quantile(smoothR2(:,startFrame2:end)',.2,1);
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
        
    
    
    
    
    