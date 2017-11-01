%%
dataFold(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\133747';
dataFold(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\171906';
dataFold(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\115421';
dataFold(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\145517';
dataFold(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\164157';
dataFold(6).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\101637';
dataFold(7).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\105620';
dataFold(8).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\113409';

for i =1:8
   [testMSEgc(i,:),valMSEgc(i,:)] = lassoAnalysis(dataFold(i).Name,3);
    
end

%%
dataFold2(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\094538';
dataFold2(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\101609';
dataFold2(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\103508';
dataFold2(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160506\155051';
dataFold2(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160506\160928';

for i =1:5
   [testMSEgfp(i,:),valMSEgfp(i,:)] = lassoAnalysis(dataFold2(i).Name,3);
    
end

%%
mGC = mean(testMSEgc);
mGFP = mean(testMSEgfp);
sGC = std(testMSEgc)/sqrt(8);
sGFP = std(testMSEgfp)/sqrt(5);
figure(1)
errorbar(mGC,sGC,'ok')
hold on;
errorbar(mGFP,sGFP,'or')
figure(2)
errorbar(1,mGC(1),sGC(1),'ok')
hold on;
errorbar(2,mGFP(1),sGFP(1),'or')
% 
% VmGC = mean(valMSEgc);
% VmGFP = mean(valMSEgfp);
% VsGC = std(valMSEgc)/sqrt(8);
% VsGFP = std(valMSEgfp)/sqrt(5);
% figure(34)
% errorbar(VmGC,VsGC,'k')
% hold on;
% errorbar(VmGFP,VsGFP,'r')

figure(4)
VmGC = mean(valMSEgc);
VsGC = std(valMSEgc)/sqrt(8);
errorbar([1:10]./6,VmGC,VsGC,'ok')
%%



