function plotPsychometricData(dat,faCutoff,lineColor)

% construct a big matrix of values for each session, indexed by mouse
cnt = 0;
for i = 1:length(dat)
    for j = 1:length(dat(i).psych.date)
        cnt = cnt + 1;
        perfMat(cnt,:) = dat(i).psych.hr(j,:);
        faMat(cnt) = dat(i).psych.fa(j);
        snrMat(cnt,:) = dat(i).psych.snr(j,:);
        contrastI(cnt) = dat(i).psych.contrast(j);
        mouseI(cnt) = i;
    end
end

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
    
    plot(meanSNR,meanPerf,'.','Color',lineColor(i,:),'MarkerSize',10);
    plot(xfine,mdl(p,xfine),'Color',lineColor(i,:),'LineWidth',1.5);
    plot([threshold threshold],[0 mdl(p,threshold)],'--',...
        'Color',lineColor(i,:),'LineWidth',1)
    
    mFA = mean(faMat(contrastI==i));
    stdFA = std(grpstats(faMat(contrastI==i),mouseI(contrastI==i)))./...
        sqrt(length(unique(mouseI(contrastI==i))));
    plot([20 20]+i-1,[mFA-stdFA mFA+stdFA],'Color',lineColor(i,:),'LineWidth',1.5)
    plot(20+i-1,mFA,'o','MarkerSize',5,'Color',lineColor(i,:))
end

xlabel('Target SNR (dB)');
ylabel('Response Rate');
plotPrefs;
