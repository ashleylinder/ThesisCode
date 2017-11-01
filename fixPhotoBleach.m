%% look at photobleach fit
%fits a sum of exponential to the red signal and plot the result 
%for checking how the fit looks on individual neurons

nCheck = 23;  %which neuron(s) to look at
for i = 1:length(nCheck)
    x = 1:length(Ratio2(1,:));
    y = rRaw(nCheck(i),:);
    idx = find(isnan(y)==0);
    f = fit(x(idx)',y(idx)','exp2');
    fitFun(nCheck(i),:) = f.a*exp(f.b*x) + f.c*exp(f.d*x);
   figure(i)
    plot(y);
    hold on;
    plot(fitFun(nCheck(i),:));
end


%% Make the double exponential fit

Fexponent=fittype('a*exp(b*x)+c*exp(d*x)','dependent',{'y'},'independent',...
    {'x'},'coefficients',{'a', 'b', 'c', 'd'});

fitOptions=fitoptions(Fexponent);
fitOptions.Lower=[0,-.2,0, -2];
fitOptions.Upper=[1000,0,10000,0];

minWindow=150;
min_quant=30;


%% PHOTOBLEACHING CORRECTION

% intialize photobleaching corrections
photoBleachingR=zeros(size(rRaw));
photoBleachingG=zeros(size(gRaw));


for i=1:size(rRaw,1)
    try
        %%
        %initialize x values for fitting y=f(x)
        xVals=(1:size(rRaw,2))';
        % only take values where bot R and G are present
        present=(~isnan(rRaw(i,:)+gRaw(i,:))') ;
        present=present & (rRaw(i,:)~=0)' & (gRaw(i,:) ~=0)';
        xVals=xVals(present);
        % get R and G traces
        rVals=rRaw(i,:)';
        gVals=gRaw(i,:)';
        gVals=gVals(present);
        rVals=rVals(present);
        % do ord filtering 
        gVals=ordfilt2(gVals,min_quant,true(minWindow,1));
        rVals=ordfilt2(rVals,min_quant,true(minWindow,1));
        
        %set up more fitting parameters for Red, and fit starting point
       fitOptions.StartPoint=[range(rVals(rVals~=0)),-.0006,range(rVals(rVals~=0)), -.0006];
        fitOptions.Weights=zeros(size(rVals));
        fitOptions.Weights(minWindow:end-minWindow)=1;
        
        %do exponential fitting
        [f,fout]=fit(xVals,rVals,Fexponent,fitOptions);
        
        %if fit is bad, try fit linear to loglinear plot
        if fout.rsquare<.9
            logVals=log(rVals);
            logVals=logVals(rVals~=0);
            logXvals=xVals(rVals~=0); %not actually logging xvals
            expFit=polyfit(logXvals,logVals,1);            
            f.a=exp(expFit(2));
            f.b=expFit(1);
        end
        
%         %do the same for the green
%         fitOptions.StartPoint=[range(gVals),-.001,min(gVals), -.001];
%         fitOptions.Weights=zeros(size(gVals));
%         fitOptions.Weights(minWindow:end-minWindow)=1;
% 
%         %green always has a strange bump in intensity at the start, fit the
%         %exponential starting after this by setting weights for the first
%         %part to zero.
%         [~,maxPos]=max(gVals(1:300));
%         fitOptions.Weights(1:maxPos)=0;
%         
%         [g,gout]=fit(xVals,gVals,Fexponent,fitOptions);
%         
%         if f(1)>(max(rRaw(i,:))+100)
%             f=fit(xVals,rVals,'poly1');
%             if f.p1>0
%                 f.p1=0;
%             end
%         end
%         if g(1)>(max(gRaw(i,:))+1000)
%             g=fit(xVals,gVals,'poly1');
%             if g.p1>0
%                 g.p1=0;
%             end
%         end
        %plot some of the results, turned off for now
        if 0
            subplot(2,1,1);
            plot(gRaw(i,:))
            hold on
            plot(g)
            ylim([0 g(0)+100])
            
            hold off
            subplot(2,1,2);
            plot(rRaw(i,:))
            hold on
            
            plot(f)
            ylim([0 f(0)+100]);
            hold off
            drawnow
            pause(.1)
        end
        
        limit=min(3000,size(rRaw,2));
        %calculating photobleaching correction from exponential fits
        photoBleachingR(i,:)=f((1:size(rRaw,2)))-f(limit);
       % photoBleachingG(i,:)=g((1:size(rRaw,2)))-g(limit);
    catch me
        me
    end
    
    
end
%%
%apply photobleaching correction, nan the values that are very bright or
%dark 
rPhotoCorr=rRaw-photoBleachingR ;
RvalstempZ=bsxfun(@minus,rPhotoCorr,nanmean(rPhotoCorr,2));
RvalstempZ=bsxfun(@rdivide,RvalstempZ,nanstd(RvalstempZ,[],2));
rPhotoCorr(RvalstempZ<-2|RvalstempZ>5|rPhotoCorr<40)=nan;


% gPhotoCorr=gRaw-photoBleachingG ;
% GvalstempZ=bsxfun(@minus,gPhotoCorr,nanmean(gPhotoCorr,2));
% GvalstempZ=bsxfun(@rdivide,GvalstempZ,nanstd(GvalstempZ,[],2));
% gPhotoCorr(GvalstempZ>5|gPhotoCorr<0)=nan;


%% apply smoothing and fold change over baseline calculation

%Process red and green signals, functions below. 
R2=processSignal(rPhotoCorr);
%G2=processSignal(gPhotoCorr);

%chop out flashes or other strange values
nanmapr=R2>4|isnan(R2);
%nanmapg=G2>4|isnan(G2);
%G2(nanmapg)=nan;
%gPhotoCorr(nanmapg)=nan;
rPhotoCorr(nanmapr)=nan;

%now, process the ratio
Ratio2=processRatio(rPhotoCorr,gPhotoCorr);