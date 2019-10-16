
[hthresh,pthresh] = ttest(threshold(:,1),threshold(:,2));
cols = [1 .25 .25; .25 .25 1];
hold on
x = [1.25 1.75];
for i = 1:2
    bp(i) = bar(x(i),nanmean(threshold(:,i)));
    bp(i).FaceColor = cols(i,:);
    bp(i).BarWidth = .5;
    %errorbar(x(i),nanmean(dpDiff(:,i)),...
%     nanstd(dpDiff(:,i)) ./ sqrt(sum(~isnan(dpDiff(:,i)))),...
%     '.k','LineWidth',2);
end
xlim([.9 2.1])
plot(repmat(x,length(threshold),1)',threshold','-k');
plot(repmat(x,length(threshold),1)',threshold','k.',...
     'MarkerSize',10);
m = max(threshold(:)) * 1.1;
plot(x,[m m],'k','LineWidth',1);
text(1.4,m+.5,sprintf('p = %01.3f',pthresh),...
     'FontSize',8);
ylabel('Threshold SNR (dB)');
set(gca,'XTick',[]);
set(gca,'XTickLabels',[]);
legend(bp,'Low-to-High','High-to-Low','Location','southeast');
hold off