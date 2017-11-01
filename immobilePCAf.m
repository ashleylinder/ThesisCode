function immobilePCAf(dataFolder)
load([dataFolder filesep 'betterHeat.mat']);
%find neurons that are NaNs for more than one standard deviation over the
%mean and get rid of them, and deNaN the ones that are good
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
%%
%crops things 
endFrame = length(newRatio2(1,:));
recLength = length(newRatio2(1,startFrame:endFrame));
nNeuron = length(newRatio2(:,1));
%takes the derivative of neural activity by convolving with a gaussian derivative 
sigma = 9;
x = -99.5:99.5;
y = (x/(sqrt(2)*pi*sigma)).*exp(-(x.^2)/(2*sigma^2));
gaussDerivFilt = y/sum(abs(y));

%smooth the neural activity - either with a smoothing window for the neural activity or with the convolution for the derivative 

smoothR2 = zeros(nNeuron, recLength);
gdRatio2 = zeros(nNeuron, recLength);
for i = 1:length(newRatio2(:,1));
    smoothR2(i,:) = smooth(newRatio2(i,:), 10);
    gdRatio2(i,:) = conv(smoothR2(i,:),gaussDerivFilt, 'same');
end
hasPointsTime = hasPointsTime(startFrame:endFrame);

%%
PCidx = zeros(nNeuron,1);   %for ordering neuron #s by pca weights later
ratio = smoothR2;           %neural activity
%ratio = gdRatio2;          %derivative of neural activity
ratio = detrend(ratio)';

[coeff,score,latent,tsquared,explained,mu] = pca(ratio);
tempPC = coeff(:,1:5)'*ratio';

for k = 1:5
    tempPC(k,:) = smooth(tempPC(k,:),60);
end
neuID = 1:nNeuron;
[mode1sort mode1idx] = sort(coeff(:,1),'descend');
PCidx(1:20) = mode1idx(1:20);
PCidx(21:41) = flipud(mode1idx((end-20):end));
notmode1 = setdiff(neuID,PCidx(1:41));

[mode2sort mode2idx] = sort(coeff(notmode1,2),'descend');
PCidx(42:end) = notmode1(mode2idx);


modeIdx = flipud(PCidx);
    figure;
    subplot(3,6,[1,2,3]);
   
   imagesc([hasPointsTime(1:end)], [1:nNeuron],smoothR2(flipud(modeIdx), :), [-.2 .8]);
  
    subplot(3,6,4)
    barh(coeff(modeIdx,1))
    ylim([0 nNeuron])
    subplot(3,6,5)
    barh(coeff(modeIdx,2))
    ylim([0 nNeuron])
    subplot(3,6,6)
    barh(coeff(modeIdx,3))
    ylim([0 nNeuron])
    
    subplot(3,6,[7,8,9])
    plot(hasPointsTime(1:end), tempPC(1,:), 'k', 'LineWidth', 1);
    offset1 = min(tempPC(1,:)) -.1;
    xlim([hasPointsTime(1), hasPointsTime(end)]);
    hold on;
    subplot(3,6,[7,8,9])
    plot(hasPointsTime(1:end), tempPC(2,:)+ offset1, 'b', 'LineWidth', 1);
    offset2 = min(tempPC(2,:) + offset1) - .1;
    hold on;
    subplot(3,6,[7,8,9])
    plot(hasPointsTime(1:end), tempPC(3,:)+ offset2, 'r', 'LineWidth', 1);
    ylim([(min(tempPC(3,:)+ offset2) -.1), (max(tempPC(1,:)) +.05)])
    
    subplot(3,6,[10, 11, 12])
    plot(cumsum(explained(1:20)), '-ok', 'MarkerFaceColor', 'k');
    hold on;
    bar(explained(1:20))
    ylim([0 100]);
    xlim([1 20]);
    
    subplot(3,6,[13,14])
    z = zeros(size(tempPC(1,:)));
    col = linspace(1,length(tempPC(1,:)),length(tempPC(1,:)));
    surface([tempPC(1,:);tempPC(1,:)],[tempPC(2,:);tempPC(2,:)],[z;z],[col;col],'facecol','n','edgecol','interp','linew',2);
    
    xlabel('PC1');
    ylabel('PC2');
    
    
    
    subplot(3,6,[15,16])
   z = zeros(size(tempPC(2,:)));
   col = linspace(1,length(tempPC(1,:)),length(tempPC(1,:)));
    surface([tempPC(2,:);tempPC(2,:)],[tempPC(3,:);tempPC(3,:)],[z;z],[col;col],'facecol','n','edgecol','interp','linew',2);
    
    xlabel('PC2');
    ylabel('PC3');
    subplot(3,6,[17, 18]);
    
   mesh([tempPC(1,:);tempPC(1,:)],[tempPC(2,:);tempPC(2,:)],[tempPC(3,:);tempPC(3,:)],[col;col],'facecol','n','edgecol','interp','linew',2);
    xlabel('PC1');
    ylabel('PC2')
    zlabel('PC3')
    
