function behaviorWrapper(mouseList)

% find psychometric functions
addpath(genpath('../Palamedes/'));

if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049','CA051','CA052'};
end

for i = 1:length(mouseList)
    [threshold(i,:) dp(i,:,:) rate(i,:,:) fa(i,:,:)] = ...
        behaviorAnalysis(mouseList{i});

end

% hard stop for missing data
if any(isnan(threshold(:)))
    keyboard
end

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

keyboard