function behaviorWrapper(mouseList)

if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049'};
end

for i = 1:length(mouseList)
    [threshold(i,:) dp(i,:,:) rate(i,:,:) fa(i,:,:)] = ...
        behaviorAnalysis(mouseList{i});

end

% compute averages over mice
for i = 1:length(mouseList)
    dpDiff(i,1) = dp(i,1,3) - dp(i,1,1);
    dpDiff(i,2) = dp(i,2,3) - dp(i,2,1);
end
[h,p] = ttest(dpDiff(:,1),dpDiff(:,2)); % paired ttest

% plot them
f3 = figure(3); clf
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
plot(repmat(x,4,1)',dpDiff','-k');
plot(repmat(x,4,1)',dpDiff','.',...
     'MarkerSize',20,...
     'Color',[.75 .75 .75]);
plot(repmat(x,4,1)',dpDiff','ok',...
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
saveFigPDF(f3,[530 700],'_allMiceDPdiff.pdf');


if length(threshold) == 4
    save('thresholds.mat','mouseList','threshold')
end

keyboard