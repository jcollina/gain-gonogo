function analyzeBehavior(ID,task)

disp(['ANALYZING MOUSE ' ID]);

baseDir = '~/gits/gain-gonogo/data';
dataDir = [baseDir filesep ID];

taskStr = {'LoHi','HiLo'};

%% analyze training
% load training files (only ones with n trials or more)
n = 150;
trainingFiles = dir([dataDir filesep '*_training.txt']);
[dprime,pcorrect,allRT,dpOffset,pcOffset,rtOffset,day] = ...
    trainingAnalysis(trainingFiles,dataDir,n);

if task == 1
    str = 'HiLo';
    lineColor = [0 0 1];
elseif task == 0
    lineColor = [1 0 0];
end

f1 = figure(1); clf;
% d'
subplot(3,3,1)
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
set(gca,'TickDir','out');
hold on
p = plot(dpOffset);
cols = repmat(linspace(.8,.2,4),3,1)';
for i = 1:length(p)
    p(i).Color = cols(i,:);
end
plot(dprime,'k','LineWidth',2);
axis tight
legend('.25','.5','.75','1.0','avg','Location','se');
ylabel('d-prime');
xlabel('Training Session');
title([ID ' - ' taskStr{task+1}])

% percent correct
subplot(3,3,4)
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
set(gca,'TickDir','out');
hold on
p = plot(pcOffset);
cols = repmat(linspace(.8,.2,4),3,1)';
for i = 1:length(p)
    p(i).Color = cols(i,:);
end
plot(pcorrect,'k','LineWidth',2);
axis tight
ylabel('Percent Correct');
xlabel('Training Session');

% RT
subplot(3,3,7)
set(gca,'FontSize',16)
set(gca,'LineWidth',2)
set(gca,'TickDir','out');
hold on
p = plot(rtOffset);
cols = repmat(linspace(.8,.2,4),3,1)';
for i = 1:length(p)
    p(i).Color = cols(i,:);
end
plot(mean(rtOffset,2),'k','LineWidth',2);
axis tight
ylabel('Median RT (s)');
xlabel('Training Session');

set(f1,'PaperPositionMode','auto');         
set(f1,'PaperOrientation','landscape');
set(f1,'PaperUnits','points');
set(f1,'PaperSize',[1300 1000]);
set(f1,'Position',[0 0 1300 1000]);
print(f1,[ID '-summary'],'-dpdf','-r300');





%% analyze testing
n = 150;
faCut = .3;
hrCut = .8;
testingFiles = dir([dataDir filesep '*_testing.txt']);
if ~isempty(testingFiles)
    f2 = figure(2);
    [rate,fa,dp,threshold,fit,ind,dbs] = psychAnalysis(testingFiles, ...
                                                      dataDir,n, ...
                                                      faCut,hrCut);
    
    keyboard
    display(['Threshold = ' num2str(threshold)]);

    % exclude initial dbs values
    if task == 0
        ind1 = dbs(:,1)' > 0;
    else
        ind1 = logical(ones(1,size(dbs,1)));
    end
    x = dbs(find(ind1>0,1,'first'),:);
                
    % plot dprime
    figure(1)
    subplot(3,3,2:3)
    if size(rate,1) > 1
        errorbar(x,mean(dp(ind1,:)),std(dp(ind1,:))./sqrt(sum(ind1)),...
                 'k','LineWidth',2);
    else
        plot(x,dp,'k','LineWidth',2)
    end
    xlabel('SNR (dB)');
    ylabel('d-prime');
    box off
    set(gca,'FontSize',16)
    set(gca,'LineWidth',2)
    set(gca,'TickDir','out');

    % plot psychometric performance
    subplot(3,3,5:6)
    fitx = fit(find(ind1>0,1,'first')).x;
    p = find(ind1&ind);
    fity = zeros(1,length(fitx));
    for i = 1:length(p)
        fity = fity + fit(p(i)).y;
    end
    fity = fity / length(p);
    [~,tind] = min(abs(fitx-threshold));
    tx = fitx(tind);
    ty = fity(tind);
    hold on
    plot([tx tx], [0 ty],'k--','LineWidth',2);
    plot(fitx,fity,'r','LineWidth',2)
    if size(rate(ind1&ind,:),1) > 1
        errorbar(x,mean(rate(ind1&ind,:),1), ...
                 std(rate(ind1&ind,:))./sqrt(sum(ind1&ind)), ...
                 'k.','LineWidth',2,'Markersize',25);
        errorbar(min(x) - mean(diff(x)), ...
                 mean(fa(ind&ind1)), ...
                 std(fa(ind&ind1))./sqrt(sum(ind&ind1)), ...
                 '.','Color',[.5 .5 .5], ...
                 'LineWidth',2,'MarkerSize',25);
    else
        plot(x,rate(ind1&ind,:),'k.','LineWidth',2,'Markersize',25);
        plot(min(x) - mean(diff(x)),fa(ind1&ind),'.','Color',[.5 .5 .5], ...
                 'LineWidth',2,'MarkerSize',25);
    end
    set(gca,'XTick',[min(x)-mean(diff(x)) x])
    lbl = cell(1,7);
    lbl(2:end) = strread(num2str(x),'%s');
    lbl{1} = 'FA';
    set(gca,'XTickLabels',lbl)
    set(gca,'FontSize',16)
    set(gca,'LineWidth',2)
    set(gca,'TickDir','out')         
    ylim([0 1]);
    ylabel('Hit Rate');
    xlabel('SNR (dB)');
    
    set(f1,'PaperPositionMode','auto');         
    set(f1,'PaperOrientation','landscape');
    set(f1,'PaperUnits','points');
    set(f1,'PaperSize',[1300 1000]);
    set(f1,'Position',[0 0 1300 1000]);
    print(f1,[ID '-summary'],'-dpdf','-r300');

    set(f2,'PaperPositionMode','auto');         
    set(f2,'PaperOrientation','landscape');
    set(f2,'PaperUnits','points');
    set(f2,'PaperSize',[2500 400]);
    set(f2,'Position',[0 0 2500 400]);
    print(f2,[ID '-gumbalfits'],'-dpdf','-r300');
end
    

%% analyze offset testing
n = 150;
offsetFiles = dir([dataDir filesep '*_offsetTesting.txt']);
if ~isempty(offsetFiles)
    [rate,fa,dp,snr,offsets] = offsetAnalysis(offsetFiles,dataDir, ...
                                              n);
    
    % plot rates
    figure(1)
    subplot(3,3,8)
    hold on
    x = offsets(1,:);
    if size(rate,1) > 1
        errorbar(x,mean(squeeze(rate(:,1,:))), ...
                 std(squeeze(rate(:,1,:)))./sqrt(size(rate,1)), ...
                 '-','LineWidth',2,'Markersize',25,'Color',lineColor);
        errorbar(x,mean(squeeze(rate(:,2,:))), ...
                 std(squeeze(rate(:,2,:)))./sqrt(size(rate,1)), ...
                 'k-','LineWidth',2,'Markersize',25);
        errorbar(x,mean(fa),std(fa)./sqrt(size(fa,1)), ...
                 '-','Color',[.4 .4 .4],'LineWidth',2);
    else
        plot(x,squeeze(rate(:,1,:)),'Color',lineColor,'LineWidth',2);
        plot(x,squeeze(rate(:,2,:)),'k','LineWidth',2);
        plot(x,fa,'-','Color',[.4 .4 .4],'LineWidth',2);
    end
    hold off
    ylabel('p(Response)')
    xlabel('Offset (s)');
    xtickangle(90);
    legend('Threshold','High SNR','FA','Location','East');
    set(gca,'XTick',x);
    set(gca,'FontSize',16);
    set(gca,'LineWidth',2);
    set(gca,'TickDir','out'); 

    
    subplot(3,3,9)
    hold on
    if size(dp,1) > 1
        errorbar(x,mean(squeeze(dp(:,1,:))), ...
                 std(squeeze(dp(:,1,:)))./sqrt(size(dp,1)), ...
                 '-','LineWidth',2,'Markersize',25,'Color',lineColor);
        errorbar(x,mean(squeeze(dp(:,2,:))), ...
                 std(squeeze(rate(:,2,:)))./sqrt(size(dp,1)), ...
                 'k-','LineWidth',2,'Markersize',25,'LineWidth',2);
    else
        plot(x,squeeze(dp(:,1,:)),'Color',lineColor,'LineWidth',2);
        plot(x,squeeze(dp(:,2,:)),'k','LineWidth',2);
    end
    hold off
    ylabel('d-prime')
    xlabel('Offset (s)');
    xtickangle(90);
    legend('Threshold','High SNR','Location','East');
    set(gca,'XTick',x);
    set(gca,'FontSize',16);
    set(gca,'LineWidth',2);
    set(gca,'TickDir','out');
    
    set(f1,'PaperPositionMode','auto');         
    set(f1,'PaperOrientation','landscape');
    set(f1,'PaperUnits','points');
    set(f1,'PaperSize',[1300 1000]);
    set(f1,'Position',[0 0 1300 1000]);
    print(f1,[ID '-summary'],'-dpdf','-r300');
end








    
    
    
    


