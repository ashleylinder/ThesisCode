function  mobilePCA(dataFolder)
load([dataFolder filesep 'fixed_data.mat']);
%make sure time stamps and neural activity have the same number of points
%(this is mostly just important for plotting things)
if length(hasPointsTime) > length(newRatio2(1,:))
    hasPointsTime = hasPointsTime(1:length(newRatio2(1,:)));
elseif length(hasPointsTime) > length(newRatio2(1,:))
    newRatio2 = newRatio2(:,1:length(hasPointsTime));
end

%takes the derivative of neural activity by convolving with a gaussian derivative 
nNeuron = length(newRatio2(:,1));
recLength = length(newRatio2(1,:));
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

%%

PCidx = zeros(nNeuron,1);   %for ordering neuron #s by pca weights later
ratio = smoothR2;           %neural activity
%ratio = gdRatio2;          %derivative of neural activity
ratio = detrend(ratio)'; 

[coeff,score,latent,tsquared,explained,mu] = pca(ratio);
tempPC = coeff(:,1:5)'*ratio';

for k = 1:5
    tempPC(k,:) = smooth(tempPC(k,:),6);
end
neuID = 1:nNeuron;
[mode1sort mode1idx] = sort(coeff(:,1),'descend');
PCidx(1:20) = mode1idx(1:20);
PCidx(21:41) = flipud(mode1idx((end-20):end));
notmode1 = setdiff(neuID,PCidx(1:41));

[mode2sort mode2idx] = sort(coeff(notmode1,2),'descend');
PCidx(42:end) = notmode1(mode2idx);


modeIdx = flipud(PCidx);
    figure
    subplot(3,6,[1,2,3]);
   
   imagesc([hasPointsTime(500:end)], [1:nNeuron],smoothR2(flipud(modeIdx), :), [-.2 .8]);
  
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
    plot(tempPC(1,:), tempPC(2,:),'k','LineWidth', 2);
    xlabel('PC1');
    ylabel('PC2');
    subplot(3,6,[15,16])
    plot(tempPC(2,:), tempPC(3,:),'k','LineWidth', 2);
    xlabel('PC2');
    ylabel('PC3');
    subplot(3,6,[17, 18]);
    plot3(tempPC(1,:),tempPC(2,:), tempPC(3,:),'k','LineWidth', 2);
    xlabel('PC1');
    ylabel('PC2')
    zlabel('PC3')


