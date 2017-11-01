dataFold(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\133747';
dataFold(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\171906';
dataFold(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\115421';
dataFold(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\145517';
dataFold(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\164157';
dataFold(6).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\101637';
dataFold(7).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\105620';
dataFold(8).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\113409';

for i =1:8
  [loRan(i),loReal(i)]= weightCompare(dataFold(i).Name,i);
    
end

mRealGC = mean(loReal);
sRealGC = std(loReal)/sqrt(8);

%%
dataFold2(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\094538';
dataFold2(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\101609';
dataFold2(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\103508';
dataFold2(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160506\155051';
dataFold2(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160506\160928';

for i = 1:length(dataFold2)
    [loRanGFP(i),loRealGFP(i)]= weightCompare(dataFold(i).Name,i);
end
mRealGFP = mean(loRealGFP);
sRealGFP = std(loReal)/sqrt(5);

%%
% errorbar(1,mRealGC,sRealGC,'ok')
% hold on;
% errorbar(2,mRealGFP,sRealGC,'or')
% %%
% for i = 1:8
%     plot([1 2], [loReal(i),loRan(i)], '-ok', 'MarkerFaceColor','k','LineWidth', 2);
%     hold on;
% end