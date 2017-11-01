%%
dataFolder2(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170609\112038';
dataFolder2(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170609\114840';
dataFolder2(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170609\131918';
dataFolder2(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\Immobilized\111207';
dataFolder2(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\Immobilized\132100';

percActTotI = [];
for ds = 1:length(dataFolder2)
   [percTimeActI,percActI(ds)] = activityAnalysisImmob(dataFolder2(ds).Name);
   percActTotI = [percActTotI percTimeActI];
end


%%
dataFold(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\133747';
dataFold(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\171906';
dataFold(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\115421';
dataFold(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\145517';
dataFold(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\164157';
dataFold(6).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\101637';
dataFold(7).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\105620';
dataFold(8).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\113409';

percActTotM = [];
for ds = 1:length(dataFold)
   [percTimeActM,percActM(ds)] = activityAnalysisMove(dataFold(ds).Name);
   percActTotM = [percActTotM percTimeActM];
end

%%

mNI = mean(percActI);
mNM = mean(percActM);
sNI = std(percActI)/sqrt(5);
sNM = std(percActM)/sqrt(8);

mTI = mean(percTimeActI);
sTI = std(percTimeActI)/length(percTimeActI);
mTM = mean(percTimeActM);
sTM = std(percTimeActM)/length(percTimeActM);

figure(1);
hM = histogram(percActTotM,20,'Normalization','probability');
hold on;
hI = histogram(percActTotI,20,'Normalization','probability');




