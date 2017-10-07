function behaviorAnalysis(ID)

disp(['ANALYZING MOUSE ' ID]);

baseDir = '~/gits/gain-gonogo/data';
dataDir = [baseDir filesep ID];

taskStr = {'LoHi','HiLo'};
lineColor = [1 0 0; 0 0 1];

% make a master file list
[fileList fileInd] = indexDataFiles(dataDir);



%% TRAINING ANALYSIS
f1 = figure(1); clf;
% for lohi
ind = fileInd(:,2) == 1 & fileInd(:,1) == 1;
if sum(ind)>0
    [dprime,pcorrect,dpOffset,pcOffset] = ...
        trainingAnalysis(fileList(ind),fileInd(ind,:));
    
    % plot d' over time
    subplot(4,2,1)
    hold on
    p = plot(dpOffset);
    cols = repmat(linspace(.8,.2,4),3,1)';
    for i = 1:length(p)
        p(i).Color = cols(i,:);
    end
    plot(dprime,'Color',lineColor(1,:),'LineWidth',2);
    axis tight
    legend('.25','.5','.75','1.0','avg','Location','se');
    ylabel('d-prime');
    xlabel('Training Session');
    title([ID ' - ' taskStr{1}])
    ylim([-1 7]);
    hold off
    plotPrefs
end


% for hilo
ind = fileInd(:,2) == 1 & fileInd(:,1) == 2;
if sum(ind) > 0
    [dprime,pcorrect,dpOffset,pcOffset] = ...
        trainingAnalysis(fileList(ind),fileInd(ind,:));
    
    % plot d' over time
    subplot(4,2,2)
    hold on
    p = plot(dpOffset);
    cols = repmat(linspace(.8,.2,4),3,1)';
    for i = 1:length(p)
        p(i).Color = cols(i,:);
    end
    plot(dprime,'Color',lineColor(2,:),'LineWidth',2);
    axis tight
    legend('.25','.5','.75','1.0','avg','Location','se');
    ylabel('d-prime');
    xlabel('Training Session');
    title([ID ' - ' taskStr{2}])
    ylim([-1 7]);
    plotPrefs
end



%% PSYCHOMETRIC ANALYSIS
% for lohi
ind = fileInd(:,2) == 2 & fileInd(:,1) == 1;
if sum(ind)>0
    [rate,fa,dp,nresp,ntrials,threshold,fit,snr] = ...
        psychAnalysis(fileList(ind),fileInd(ind,:));
    
    % plot average psychometric performance
    figure(1);
    subplot(4,2,3)
    resp = sum(nresp);
    trials = sum(ntrials);
    fit = psychometricFit(resp,trials,snr(1,:));
    x = snr(1,:);
    
    [~,tind] = min(abs(fit.x-fit.thresh));
    tx = fit.x(tind);
    ty = fit.y(tind);
    hold on
    plot([tx tx], [0 ty],'k--','LineWidth',2);
    plot(fit.x,fit.y,'Color',lineColor(1,:),'LineWidth',2)
    plot(x,resp./trials,'k.','LineWidth',2,'Markersize',25);
    plot(min(x) - mean(diff(x)),mean(fa),'.','Color',[.5 .5 .5], ...
         'LineWidth',2,'MarkerSize',25);
    set(gca,'XTick',[min(x)-mean(diff(x)) x])
    lbl = cell(1,7);
    lbl(2:end) = strread(num2str(x),'%s');
    lbl{1} = 'FA';
    set(gca,'XTickLabels',lbl)       
    ylim([0 1]);
    ylabel('Hit Rate');
    xlabel('SNR (dB)');
    plotPrefs;
end

% for hilo
ind = fileInd(:,2) == 2 & fileInd(:,1) == 2;
if sum(ind)>0
    [rate,fa,dp,nresp,ntrials,threshold,fit,snr] = ...
        psychAnalysis(fileList(ind),fileInd(ind,:));
    
    % plot average psychometric performance
    figure(1);
    subplot(4,2,4)
    resp = sum(nresp);
    trials = sum(ntrials);
    fit = psychometricFit(resp,trials,snr(1,:));
    x = snr(1,:);
    
    [~,tind] = min(abs(fit.x-fit.thresh));
    tx = fit.x(tind);
    ty = fit.y(tind);
    hold on
    plot([tx tx], [0 ty],'k--','LineWidth',2);
    plot(fit.x,fit.y,'Color',lineColor(2,:),'LineWidth',2)
    plot(x,resp./trials,'k.','LineWidth',2,'Markersize',25);
    plot(min(x) - mean(diff(x)),mean(fa),'.','Color',[.5 .5 .5], ...
         'LineWidth',2,'MarkerSize',25);
    set(gca,'XTick',[min(x)-mean(diff(x)) x])
    lbl = cell(1,7);
    lbl(2:end) = strread(num2str(x),'%s');
    lbl{1} = 'FA';
    set(gca,'XTickLabels',lbl)       
    ylim([0 1]);
    ylabel('Hit Rate');
    xlabel('SNR (dB)');
    plotPrefs;
end



%% OFFSET ANALYSIS
ind = fileInd(:,2) == 3 & fileInd(:,1) == 1;
if sum(ind) > 0
    [rate,fa,dp,snr,offsets] = offsetAnalysis(fileList(ind), ...
                                              fileInd(ind,:));
    
    % plot pc
    figure(1)
    subplot(4,2,5)
    hold on
    x = offsets(1,:);
    if size(rate,1) > 1
        errorbar(x,mean(squeeze(rate(:,1,:))), ...
                 std(squeeze(rate(:,1,:)))./sqrt(size(rate,1)), ...
                 '-','LineWidth',2,'Markersize',25,'Color',lineColor(1,:));
        errorbar(x,mean(squeeze(rate(:,2,:))), ...
                 std(squeeze(rate(:,2,:)))./sqrt(size(rate,1)), ...
                 'k-','LineWidth',2,'Markersize',25);
        errorbar(x,mean(fa),std(fa)./sqrt(size(fa,1)), ...
                 '-','Color',[.4 .4 .4],'LineWidth',2);
    else
        plot(x,squeeze(rate(:,1,:)),'Color',lineColor(1,:),'LineWidth',2);
        plot(x,squeeze(rate(:,2,:)),'k','LineWidth',2);
        plot(x,fa,'-','Color',[.4 .4 .4],'LineWidth',2);
    end
    hold off
    ylabel('p(Response)')
    xlabel('Offset (s)');
    xtickangle(90);
    legend('Threshold','High SNR','FA','Location','East');
    set(gca,'XTick',x);
    plotPrefs
    
    % plot dprime
    subplot(4,2,7)
    hold on
    if size(dp,1) > 1
        errorbar(x,mean(squeeze(dp(:,1,:))), ...
                 std(squeeze(dp(:,1,:)))./sqrt(size(dp,1)), ...
                 '-','LineWidth',2,'Markersize',25,'Color',lineColor(1,:));
        errorbar(x,mean(squeeze(dp(:,2,:))), ...
                 std(squeeze(rate(:,2,:)))./sqrt(size(dp,1)), ...
                 'k-','LineWidth',2,'Markersize',25,'LineWidth',2);
    else
        plot(x,squeeze(dp(:,1,:)),'Color',lineColor(1,:),'LineWidth',2);
        plot(x,squeeze(dp(:,2,:)),'k','LineWidth',2);
    end
    hold off
    ylabel('d-prime')
    xlabel('Offset (s)');
    xtickangle(90);
    legend('Threshold','High SNR','Location','East');
    set(gca,'XTick',x);
    plotPrefs
end

ind = fileInd(:,2) == 3 & fileInd(:,1) == 2;
if sum(ind) > 0
    [rate,fa,dp,snr,offsets] = offsetAnalysis(fileList(ind), ...
                                              fileInd(ind,:));
    
    % plot pc
    figure(1)
    subplot(4,2,6)
    hold on
    x = offsets(1,:);
    if size(rate,1) > 1
        errorbar(x,mean(squeeze(rate(:,1,:))), ...
                 std(squeeze(rate(:,1,:)))./sqrt(size(rate,1)), ...
                 '-','LineWidth',2,'Markersize',25,'Color',lineColor(2,:));
        errorbar(x,mean(squeeze(rate(:,2,:))), ...
                 std(squeeze(rate(:,2,:)))./sqrt(size(rate,1)), ...
                 'k-','LineWidth',2,'Markersize',25);
        errorbar(x,mean(fa),std(fa)./sqrt(size(fa,1)), ...
                 '-','Color',[.4 .4 .4],'LineWidth',2);
    else
        plot(x,squeeze(rate(:,1,:)),'Color',lineColor(2,:),'LineWidth',2);
        plot(x,squeeze(rate(:,2,:)),'k','LineWidth',2);
        plot(x,fa,'-','Color',[.4 .4 .4],'LineWidth',2);
    end
    hold off
    ylabel('p(Response)')
    xlabel('Offset (s)');
    xtickangle(90);
    legend('Threshold','High SNR','FA','Location','East');
    set(gca,'XTick',x);
    plotPrefs
    
    % plot dprime
    subplot(4,2,8)
    hold on
    if size(dp,1) > 1
        errorbar(x,mean(squeeze(dp(:,1,:))), ...
                 std(squeeze(dp(:,1,:)))./sqrt(size(dp,1)), ...
                 '-','LineWidth',2,'Markersize',25,'Color',lineColor(2,:));
        errorbar(x,mean(squeeze(dp(:,2,:))), ...
                 std(squeeze(rate(:,2,:)))./sqrt(size(dp,1)), ...
                 'k-','LineWidth',2,'Markersize',25,'LineWidth',2);
    else
        plot(x,squeeze(dp(:,1,:)),'Color',lineColor(2,:),'LineWidth',2);
        plot(x,squeeze(dp(:,2,:)),'k','LineWidth',2);
    end
    hold off
    ylabel('d-prime')
    xlabel('Offset (s)');
    xtickangle(90);
    legend('Threshold','High SNR','Location','East');
    set(gca,'XTick',x);
    plotPrefs
end

set(f1,'PaperPositionMode','auto');         
set(f1,'PaperOrientation','landscape');
set(f1,'PaperUnits','points');
set(f1,'PaperSize',[900 1200]);
set(f1,'Position',[0 0 900 1200]);
print(f1,[ID '-summary'],'-dpdf','-r300');

















function plotPrefs

set(gca,'FontSize',16)
set(gca,'LineWidth',2)
set(gca,'TickDir','out');
