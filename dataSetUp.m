%% Set up neural data
%Get rid of empty data points in the beginning
%bfTime = bfAll.frameTime;
behavTime = find(bfTime >=0,1);
neuTime = find(hasPointsTime >= bfTime(behavTime),1);

Ratio2 = Ratio2(:,neuTime+1:end);
centerlines = centerlines(:,:,neuTime+1:end);

%Get rid of NaNs in neural activity
newRatio2 = denanRatio2(Ratio2);

%% Set up behavior data
load('C:\Users\linder\AppData\Roaming\Microsoft\Windows\Recent\eig_basis.mat');
%worm center, project into posture space, fix it
wormcentered = FindWormCentered(centerlines);
eigProj = eig_basis(2:end-1,:)'*wormcentered;
for i = 1:3
    toReplace = find(isnan(eigProj(i,:))==1);
    eigProj(i,toReplace) = 0;
end
[projections, behaviorZ] = PCA_FIX(eigProj); %Rotate eigenprojection
eigAngle = unwrap(atan2(projections(:,2),projections(:,1)));  %get angle in 1st two modes
projections = projections';
behaviorZ = behaviorZ';
%get derivative of angle in posture space
sigma = 15;
x = -99.5:99.5;
y = (x/(sqrt(2)*pi*sigma)).*exp(-(x.^2)/(2*sigma^2));
gaussDerivFilt = y/sum(abs(y));

eigAngleFilt = conv(eigAngle, -gaussDerivFilt, 'same');
eigAngleFilt = eigAngleFilt(100:end-100);
save('fixed_data.mat', 'newRatio2', 'eigAngleFilt', 'projections', 'hasPointsTime','behaviorZ', 'neuTime', 'gaussDerivFilt');
 

