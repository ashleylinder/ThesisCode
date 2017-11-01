dataFold(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\133747';
dataFold(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160413\171906';
dataFold(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\115421';
dataFold(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\145517';
dataFold(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160505\164157';
dataFold(6).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\101637';
dataFold(7).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\105620';
dataFold(8).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170424\113409';

for i = 1:length(x)
   fscoreGCamp(i,:) = svmCrossVal(dataFold(i).Name); 
end


%%
dataFold2(1).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\094538';
dataFold2(2).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\101609';
dataFold2(3).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20170421\103508';
dataFold2(4).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160506\155051';
dataFold2(5).Name = 'C:\Users\linder\workspace\ashleyNeuroBehavior\Data sets\20160506\160928';

for i = 1:length(dataFold2)
  fscoreGFP(i,:) = svmCrossVal(dataFold2(i).Name); 
end