function behaviorAnalysis(ID)

disp(['ANALYZING MOUSE ' ID]);

baseDir = '~/gits/gain-gonogo/data';
dataDir = [baseDir filesep ID];

taskStr = {'LoHi','HiLo'};
lineColor = [1 0 0; 0 0 1];

% make a master file list
[fileList fileInd] = indexDataFiles(dataDir);

%% training analysis
f1 = figure(1); clf;
% for lohi
ind = fileInd(:,2) == 1 & fileInd(:,1) == 1;
if sum(ind)>0
    [dprime,pcorrect,dpOffset,pcOffset] = ...
        trainingAnalysis(fileList(ind),fileInd(ind,:));
    
    % plot d' over time
    subplot(3,2,1)
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
    subplot(3,2,2)
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

%% psychometric analysis
% for lohi
ind = fileInd(:,2) == 2 & fileInd(:,1) == 1;
if sum(ind)>0
    [rate,fa,dp,nresp,ntrials,threshold,fit,ind,snr] = ...
        psychAnalysis(fileList(ind),fileInd(ind,:));
end
















function plotPrefs

set(gca,'FontSize',16)
set(gca,'LineWidth',2)
set(gca,'TickDir','out');
