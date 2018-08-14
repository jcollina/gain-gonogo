function behaviorWrapper(mouseList)

% find psychometric functions
addpath(genpath('../Palamedes/'));

if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049','CA051','CA052','CA055','CA061','CA072'};
end

for i = 1:length(mouseList)
    [rpsych(i,:,:) npsych(i,:,:) lvl(i,:,:) threshold(i,:) dp(i,:,:) dp1(i,:,:) rate(i,:,:) fa(i,:,:)] = ...
        behaviorAnalysis(mouseList{i});
end

% keyboard

% cols = [0 0 1; 1 0 0];
% for i = 1:2
%     resp = squeeze(sum(rpsych(:,i,:),1));
%     trials = squeeze(sum(npsych(:,i,:),1));
%     x(i,:) = squeeze(lvl(1,i,:));
%     fit(i) = psychometricFit(resp,trials,x(i,:));
%     hold on
%     plot(x(i,:),resp./trials,'.k');
%     plot(fit(i).x,fit(i).y,...
%          'Color',cols(i,:),'LineWidth',2)
%     hold off
% end
    


% hard stop for missing data
if any(isnan(threshold(:))) || size(threshold,1)==1
    keyboard
end

figure
hold on
plot(squeeze(lvl(1,1,:)),squeeze(mean(psych(:,1,2:end))),'b.')
plot(squeeze(lvl(1,2,:)),squeeze(mean(psych(:,2,2:end))),'r.')
hold off


% save out thresholds
save('thresholds.mat','mouseList','threshold')

% n mice
n = size(dp,1);

%% changes in thresholds across conditions
[hthresh,pthresh] = ttest(threshold(:,1),threshold(:,2));

% plot them
f3 = figure(3); clf
cols = [1 .25 .25; .25 .25 1];
hold on
x = [1.25 1.75];
for i = 1:2
    bp(i) = bar(x(i),nanmean(threshold(:,i)))
    bp(i).FaceColor = cols(i,:);
    bp(i).BarWidth = .5;
    %errorbar(x(i),nanmean(dpDiff(:,i)),...
%     nanstd(dpDiff(:,i)) ./ sqrt(sum(~isnan(dpDiff(:,i)))),...
%     '.k','LineWidth',2);
end
xlim([.9 2.1])
plot(repmat(x,n,1)',threshold','-k');
plot(repmat(x,n,1)',threshold','.',...
     'MarkerSize',20,...
     'Color',[.75 .75 .75]);
plot(repmat(x,n,1)',threshold','ok',...
     'MarkerSize',7);
m = max(threshold(:)) * 1.1;
plot(x,[m m],'k','LineWidth',2);
text(1.4,m+.5,sprintf('p = %01.3f',pthresh),...
     'FontSize',16);
ylabel('Threshold SNR (dB)');
set(gca,'XTick',[]);
set(gca,'XTickLabels',[]);
set(gca,'TickDir','out');
set(gca,'FontSize',16);
set(gca,'LineWidth',2);
legend(bp,'Low-to-High','High-to-Low','Location','southeast');
hold off
saveFigPDF(f3,[530 700],'_allMiceThresh.pdf');



%% changes in d' across conditions.. 250ms
% compute averages over mice
for i = 1:length(mouseList)
    dpDiff(i,1) = dp(i,1,3) - dp(i,1,1);
    dpDiff(i,2) = dp(i,2,3) - dp(i,2,1);
end
[h,p] = ttest(dpDiff(:,1),dpDiff(:,2)); % paired ttest

% plot them
f4 = figure(4); clf
cols = [1 .25 .25; .25 .25 1];
hold on
x = [1.25 1.75];
for i = 1:2
    bp(i) = bar(x(i),nanmean(dpDiff(:,i)))
    bp(i).FaceColor = cols(i,:);
    bp(i).BarWidth = .5;
    %errorbar(x(i),nanmean(dpDiff(:,i)),...
%     nanstd(dpDiff(:,i)) ./ sqrt(sum(~isnan(dpDiff(:,i)))),...
%     '.k','LineWidth',2);
end
xlim([.9 2.1])
plot(repmat(x,n,1)',dpDiff','-k');
plot(repmat(x,n,1)',dpDiff','.',...
     'MarkerSize',20,...
     'Color',[.75 .75 .75]);
plot(repmat(x,n,1)',dpDiff','ok',...
     'MarkerSize',7);
m = max(dpDiff(:)) * 1.1;
plot(x,[m m],'k','LineWidth',2);
text(1.4,m+.1,sprintf('p = %01.3f',p),...
     'FontSize',16);
ylabel('d''(250ms) - d''(50ms)');
set(gca,'XTick',[]);
set(gca,'XTickLabels',[]);
set(gca,'TickDir','out');
set(gca,'FontSize',16);
set(gca,'LineWidth',2);
legend(bp,'Low-to-High','High-to-Low','Location','southeast');
hold off
saveFigPDF(f4,[530 700],'_allMiceDPdiff-250.pdf');

%% changes in d' across conditions.. 1000ms
% compute averages over mice
for i = 1:length(mouseList)
    dpDiff(i,1) = dp(i,1,5) - dp(i,1,1);
    dpDiff(i,2) = dp(i,2,5) - dp(i,2,1);
end
[h,p] = ttest(dpDiff(:,1),dpDiff(:,2)); % paired ttest

% plot them
f5 = figure(5); clf
cols = [1 .25 .25; .25 .25 1];
hold on
x = [1.25 1.75];
for i = 1:2
    bp(i) = bar(x(i),nanmean(dpDiff(:,i)))
    bp(i).FaceColor = cols(i,:);
    bp(i).BarWidth = .5;
    %errorbar(x(i),nanmean(dpDiff(:,i)),...
%     nanstd(dpDiff(:,i)) ./ sqrt(sum(~isnan(dpDiff(:,i)))),...
%     '.k','LineWidth',2);
end
xlim([.9 2.1])
plot(repmat(x,n,1)',dpDiff','-k');
plot(repmat(x,n,1)',dpDiff','.',...
     'MarkerSize',20,...
     'Color',[.75 .75 .75]);
plot(repmat(x,n,1)',dpDiff','ok',...
     'MarkerSize',7);
m = max(dpDiff(:)) * 1.1;
plot(x,[m m],'k','LineWidth',2);
text(1.4,m+.1,sprintf('p = %01.3f',p),...
     'FontSize',16);
ylabel('d''(1000ms) - d''(50ms)');
set(gca,'XTick',[]);
set(gca,'XTickLabels',[]);
set(gca,'TickDir','out');
set(gca,'FontSize',16);
set(gca,'LineWidth',2);
legend(bp,'Low-to-High','High-to-Low','Location','southeast');
hold off
saveFigPDF(f5,[530 700],'_allMiceDPdiff-1000.pdf');

% mouse averaged dprime
t = [.05 .1 .25 .5 1];
nLoHi = mode(sum(~isnan(dp(:,1,:))),3);
mLoHi = nanmean(dp(:,1,:));
sLoHi = nanstd(dp(:,1,:)) ./ sqrt(nLoHi);
nHiLo = mode(sum(~isnan(dp(:,2,:))),3);
mHiLo = nanmean(dp(:,2,:));
sHiLo = nanstd(dp(:,2,:)) ./ sqrt(nHiLo);

f6 = figure(6); clf;
hold on
errorbar(t,squeeze(mLoHi),squeeze(sLoHi),'r','LineWidth',2);
errorbar(t,squeeze(mHiLo),squeeze(sHiLo),'b','LineWidth',2);
xlim([0 1.05]);
set(gca,'XTick',t);
xtickangle(90);
title(sprintf('n = %d',min([nLoHi nHiLo])));
xlabel('Time (s)');
ylabel('d''');
legend('Low-to-High','High-to-Low','location','southeast');
plotPrefs;
hold off
saveFigPDF(f6,[600 300],'_allMiceDP.pdf');

% mouse averaged dprime at highest level
t = [.05 .1 .25 .5 1];
nLoHi = mode(sum(~isnan(dp1(:,1,:))),3);
mLoHi = nanmean(dp1(:,1,:));
sLoHi = nanstd(dp1(:,1,:)) ./ sqrt(nLoHi);
nHiLo = mode(sum(~isnan(dp1(:,2,:))),3);
mHiLo = nanmean(dp1(:,2,:));
sHiLo = nanstd(dp1(:,2,:)) ./ sqrt(nHiLo);

f7 = figure(7); clf;
hold on
errorbar(t,squeeze(mLoHi),squeeze(sLoHi),'r','LineWidth',2);
errorbar(t,squeeze(mHiLo),squeeze(sHiLo),'b','LineWidth',2);
xlim([0 1.05]);
set(gca,'XTick',t);
xtickangle(90);
title(sprintf('n = %d',min([nLoHi nHiLo])));
xlabel('Time (s)');
ylabel('d''');
legend('Low-to-High','High-to-Low','location','southeast');
plotPrefs;
hold off
saveFigPDF(f7,[600 300],'_allMiceDPhigh.pdf');


keyboard