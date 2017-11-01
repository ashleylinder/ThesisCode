function [newRatio2, behav] = denandata(bfTime,Ratio2, eig_proj, hasPointsTime)

%% Behavior
%Find first time point we have behavior for
start = find(bfTime>=0,1);

%Average the posture projections for neural activity point (average posture
%over a volume) - note that this can also be thought of as a filtering step
for i = 2:length(hasPointsTime)
   pts = find(bfTime <= hasPointsTime(i) & bfTime > hasPointsTime(i-1));
    behav(:,i) = mean(eig_proj(:,pts),2);
end


%% Get rid of NaNs
%Add an extra point to the beginning and the end of the neural activity.
%Set that extra point to have the same value as its closest point.  So if
%the first actual data point is a NaN, find the (temproally) closest data
%point and set that extra point to that. Then interpolate points that are NaN in the middle of the traces

%Adding extra points and filling in what we already have
newRatio2 = zeros(length(Ratio2(:,1)), length(Ratio2(1,:))+2);
newRatio2(:,2:end-1) = Ratio2;

%Finding the value for the first point
for i = 1:length(Ratio2(:,1))
    findnan = isnan(Ratio2(i,:));
    badidx = find(findnan == 1);
    chnge = diff(badidx);
    
    if numel(badidx) ==0
        newRatio2(i,1) = Ratio2(i,1);
    elseif badidx(1) == 1
       last = find(chnge > 1, 1);
       x = isempty(last);
        if x == 1
                newRatio2(i,1) = Ratio2(i,max(badidx)+1);
            else
                newRatio2(i,1) = Ratio2(i, last+1);
        end
    end
    
end

%Finding the value of the last point
for i =1:length(Ratio2(:,1))
     findnan = isnan(Ratio2(i,:));
    badidx = find(findnan == 1);
    chnge = diff(badidx);
    if numel(badidx) ==0
        newRatio2(i,end) =  Ratio2(i,end);
    elseif badidx(end) ==length(Ratio2(1,:))
       last = find(isnan(Ratio2(i,:))==0,1,'last');
        newRatio2(i,end) = Ratio2(i,last);
    else
        newRatio2(i,end) = Ratio2(i,end-1);
    end
end

%interpolate all the NaNs 
for i =1:length(Ratio2(:,1))
    newbadpts = find(isnan(newRatio2(i,:)) ==1);
    goodpts = find(isnan(newRatio2(i,:)) ==0);
    
    
    newRatio2(i,newbadpts) = interp1(goodpts, newRatio2(i,goodpts), newbadpts);
end

%get rid of those extra points - this is mostly for matching things up in
%time
newRatio2 = newRatio2(:,2:end-1);

[coeff,score,latent,tsquared,explained,mu] = pca(newRatio2');
