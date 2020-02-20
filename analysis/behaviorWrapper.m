
% find psychometric functions
addpath(genpath('../Palamedes/'));
addpath(genpath('~/chris-lab/code_general'));

%% process all mice
mouseList = {'CA046','CA047','CA048','CA049','CA051','CA052','CA055',...
             'CA061','CA070','CA072','CA073','CA074','CA075','CA102',...
             'CA104','CA106','CA107'};
%mouseList = {'CA102','CA104','CA106','CA107'};
faCutoff = 1;

for i = 1:length(mouseList)
    [dat(i) threshold(i,:)] = ...
        behaviorAnalysis(mouseList{i},faCutoff);
end

taskStr = {'LoHi','HiLo'};
lineColor = [1 0 0; 0 0 1];

% n mice
n = size(dat);


%% training figures
f1 = figure(1); clf;
plotTrainingData(dat);
saveFigPDF(f1,[1000 700],'_training_summary.pdf')


%% psychometric figures
f2 = figure(2); clf; hold on;
plotPsychometricData(dat,faCutoff,lineColor);


subplot(1,4,3)
plotThresholds;

saveFigPDF(f2,[1000 300],'_psychometricSummary.pdf');

%% plot offsets
f3 = figure(3); clf; hold on;
plotOffsets;

saveFigPDF(f3,[1000 500],'_offsetSummary.pdf');


keyboard

% hard stop for missing data
if any(isnan(threshold(:))) || size(threshold,1)==1
    keyboard
end


% save out thresholds
save('thresholds.mat','mouseList','threshold')








% %% changes in d' across conditions.. 250ms
% % compute averages over mice
% for i = 1:length(mouseList)
%     dpDiff(i,1) = dp(i,1,3) - dp(i,1,1);
%     dpDiff(i,2) = dp(i,2,3) - dp(i,2,1);
% end
% [h,p] = ttest(dpDiff(:,1),dpDiff(:,2)); % paired ttest
% 
% % plot them
% f4 = figure(4); clf
% cols = [1 .25 .25; .25 .25 1];
% hold on
% x = [1.25 1.75];
% for i = 1:2
%     bp(i) = bar(x(i),nanmean(dpDiff(:,i)))
%     bp(i).FaceColor = cols(i,:);
%     bp(i).BarWidth = .5;
%     %errorbar(x(i),nanmean(dpDiff(:,i)),...
% %     nanstd(dpDiff(:,i)) ./ sqrt(sum(~isnan(dpDiff(:,i)))),...
% %     '.k','LineWidth',2);
% end
% xlim([.9 2.1])
% plot(repmat(x,n,1)',dpDiff','-k');
% plot(repmat(x,n,1)',dpDiff','.',...
%      'MarkerSize',20,...
%      'Color',[.75 .75 .75]);
% plot(repmat(x,n,1)',dpDiff','ok',...
%      'MarkerSize',7);
% m = max(dpDiff(:)) * 1.1;
% plot(x,[m m],'k','LineWidth',2);
% text(1.4,m+.1,sprintf('p = %01.3f',p),...
%      'FontSize',16);
% ylabel('d''(250ms) - d''(50ms)');
% set(gca,'XTick',[]);
% set(gca,'XTickLabels',[]);
% set(gca,'TickDir','out');
% set(gca,'FontSize',16);
% set(gca,'LineWidth',2);
% legend(bp,'Low-to-High','High-to-Low','Location','southeast');
% hold off
% saveFigPDF(f4,[530 700],'_allMiceDPdiff-250.pdf');
% 
% %% changes in d' across conditions.. 1000ms
% % compute averages over mice
% for i = 1:length(mouseList)
%     dpDiff(i,1) = dp(i,1,5) - dp(i,1,1);
%     dpDiff(i,2) = dp(i,2,5) - dp(i,2,1);
% end
% [h,p] = ttest(dpDiff(:,1),dpDiff(:,2)); % paired ttest
% 
% % plot them
% f5 = figure(5); clf
% cols = [1 .25 .25; .25 .25 1];
% hold on
% x = [1.25 1.75];
% for i = 1:2
%     bp(i) = bar(x(i),nanmean(dpDiff(:,i)))
%     bp(i).FaceColor = cols(i,:);
%     bp(i).BarWidth = .5;
%     %errorbar(x(i),nanmean(dpDiff(:,i)),...
% %     nanstd(dpDiff(:,i)) ./ sqrt(sum(~isnan(dpDiff(:,i)))),...
% %     '.k','LineWidth',2);
% end
% xlim([.9 2.1])
% plot(repmat(x,n,1)',dpDiff','-k');
% plot(repmat(x,n,1)',dpDiff','.',...
%      'MarkerSize',20,...
%      'Color',[.75 .75 .75]);
% plot(repmat(x,n,1)',dpDiff','ok',...
%      'MarkerSize',7);
% m = max(dpDiff(:)) * 1.1;
% plot(x,[m m],'k','LineWidth',2);
% text(1.4,m+.1,sprintf('p = %01.3f',p),...
%      'FontSize',16);
% ylabel('d''(1000ms) - d''(50ms)');
% set(gca,'XTick',[]);
% set(gca,'XTickLabels',[]);
% set(gca,'TickDir','out');
% set(gca,'FontSize',16);
% set(gca,'LineWidth',2);
% legend(bp,'Low-to-High','High-to-Low','Location','southeast');
% hold off
% saveFigPDF(f5,[530 700],'_allMiceDPdiff-1000.pdf');




% % for CA070,73,74, compute thresholds from clusters of sessions
% list = [9 11 12];
% for i = 1:length(list)
%     for j = 1:2
%         
%         % split out dates for this contrast
%         ind = dat(list(i)).psych.contrast == j;
%         dates = dat(list(i)).psych.date(ind);
%         dt = datetime(num2str(dates),'InputFormat','yyMMdd');
%         %weeks = days(dt - dt(1))
%                 
%         % split dates biweekly
%         splits = find(days(diff(dt))>=14);
%         clust = ones(size(dates));
%         if length(splits) > 0
%             
%             start = 1;
%             last = splits(1);
%             for k = 1:length(splits)+1
%                 
%                 if k == 1
%                     clust(1:splits(k)) = k;
%                 elseif k < length(splits)+1
%                     clust(splits(k-1)+1:splits(k)) = k;
%                 elseif k == length(splits)+1
%                     clust(splits(k-1)+1:end) = k;
%                 end
%                 
%             end
%             
%         end
%     
%         % for each cluster of sessions, compute the threshold over
%         % the summed trials
%         
%         uClust = unique(clust);
%         clear f;
%         for k = 1:length(uClust)
%             
%             % index the cluster dates in the master data structure
%             clustDates = dates(clust == uClust(k));
%             I = ismember(dat(list(i)).psych.date,clustDates);
%             
%             % use the index to get the number of responses, trials
%             nresp = sum(dat(list(i)).psych.nresp(I,:),1);
%             ntrials = sum(dat(list(i)).psych.ntrials(I,:),1);
%             mfa = mean(dat(list(i)).psych.fa(I),1);
%             SNR = mode(dat(list(i)).psych.snr(I,:),1);
%             
%             % psychometric fit
%             f(k) = psychometricFit(nresp,ntrials,SNR,mfa);
%             
%             % plot 
%             subplot(1,length(uClust),k);
%             plot(SNR,nresp./ntrials,'k');
%             ylim([0 1]);
%             
%             
%         end
%         
%         threshB{i,j} = [f.thresh];
%         thresh70{i,j} = [f.thresh70];
%         thresh15d{i,j} = [f.thresh15d];
%             
%     end
% end
% 
% % save a threshold matrix for these mice, using the most recent
% % estimate
% if 1 == 2
%     clear threshold;
%     mouseList = mouseList(list);
%     for i = 1:length(mouseList1)
%         threshold(i,1) = thresh70{i,1}(end);
%         threshold(i,2) = thresh70{i,2}(end);
%     end
%     save('thresholds.mat','mouseList','threshold');
% end

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