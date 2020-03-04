function plotPsychometricData(dat,faCutoff,lineColor)

% construct a big matrix of values for each session, indexed by mouse
cnt = 0;
for i = 1:length(dat)
    
    % get first day of training
    dt0 = datetime(num2str(min(dat(i).training.date)),...
                  'InputFormat','yyMMdd');
    
    for j = 1:length(dat(i).psych.date)
        cnt = cnt + 1;
        perfMat(cnt,:) = dat(i).psych.hr(j,:);
        faMat(cnt) = dat(i).psych.fa(j);
        snrMat(cnt,:) = dat(i).psych.snr(j,:);
        contrastI(cnt) = dat(i).psych.contrast(j);
        days(cnt) =  day(datetime(num2str(dat(i).psych.date(j)),'InputFormat','yyMMdd') ...
                         - dt0);
        [~,~,thresh(cnt),~] = fitLogistic(snrMat(cnt,:),perfMat(cnt,:));
        mouseI(cnt) = i;
    end
end










subplot(1,4,4); hold on
% remove outliers
I = thresh < 2*std(thresh) & thresh > 0; %& faMat < .3;
mn = min(days(I));
mx = max(days(I));
xfine = mn:1:mx;
for i = 1:2
    scatter(days(contrastI==i&I),thresh(contrastI==i&I),...
            10,lineColor(i,:));
    [b,bint,~,~,stats] = regress(thresh(contrastI==i&I)',...
                                 [ones(size(days(contrastI==i&I)')) ...
                        days(contrastI==i&I)'])
    plot(xfine,[ones(size(xfine)); xfine]' * b,...
         'Color',lineColor(i,:),'LineWidth',1)
    text(170,1+i,sprintf('p=%03.2f',stats(3)),'Color',lineColor(i,:))
end
xlabel('Task Exposure (days)');
ylabel('Threshold (dB SNR)');
plotPrefs;
    

subplot(1,4,1:2)
hold on
% for each mouse
cnt = 1;
for i = 1:length(unique(mouseI))
    
    % index sessions for this mouse
    ind = find(mouseI == i & faMat < faCutoff);
    
    % make an average for unique snr levels in this mouse
    [uSNR,~,uI] = unique(snrMat(ind,:),'rows');
    for j = 1:size(uSNR,1)
        mPerf(cnt,:) = mean(perfMat(ind(uI==j),:));
        snr(cnt,:) = uSNR(j,:);
        mouse(cnt) = i;
        contrast(cnt) = mean(contrastI(ind(uI==j)));
        cnt = cnt + 1;
    end
    
end

% remove the line where there is no effect... not sure what that is
I = find(all(diff(mPerf,[],2)==0,2));
mPerf(I,:) = [];
snr(I,:) = [];
mouse(I) = [];
contrast(I) = [];


for i = 1:2
    currSNR = snr(contrast==i,:)';
    currPerf = mPerf(contrast==i,:)';
    hold on
    p = plot(currSNR,currPerf,...
        'Color',lineColor(i,:),'LineWidth',.5); 
    for j = 1:length(p)
        p(j).Color(4) = .2;
    end
    meanPerf = grpstats(currPerf(:),currSNR(:));
    meanSNR = unique(currSNR);
    
    [p,mdl,threshold,sensitivity] = fitLogistic(meanSNR,meanPerf);
    xfine = meanSNR(1):.01:meanSNR(end);
    
    pl(1) = plot(meanSNR,meanPerf,'.','Color',lineColor(i,:),'MarkerSize',10);
    pl(2) = plot(xfine,mdl(p,xfine),'Color',lineColor(i,:),'LineWidth',1.5);
    pl(3) = plot([threshold threshold],[0 mdl(p,threshold)],'--',...
            'Color',lineColor(i,:),'LineWidth',1);
    
    mFA = mean(faMat(contrastI==i));
    stdFA = std(grpstats(faMat(contrastI==i),mouseI(contrastI==i)))./...
        sqrt(length(unique(mouseI(contrastI==i))));
    plot([20 20]+i-1,[mFA-stdFA mFA+stdFA],'Color',lineColor(i,:),'LineWidth',1.5);
    pl(4) = plot(20+i-1,mFA,'o','MarkerSize',5,'Color',lineColor(i,:));
end

xlabel('Target SNR (dB)');
ylabel('Response Rate');
legend(pl,'Hit Rate','Fit','Threshold','FA Rate','Location','nw');
plotPrefs;
