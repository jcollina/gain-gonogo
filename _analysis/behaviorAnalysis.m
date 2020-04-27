function [dat, threshold] = behaviorAnalysis(ID,faCut)

disp(['ANALYZING MOUSE ' ID]);

baseDir = ['..' filesep '_data'];
dataDir = [baseDir filesep ID];

taskStr = {'LoHi','HiLo'};
lineColor = [1 0 0; 0 0 1];

% make a master file list
[fileList fileInd] = indexDataFiles(dataDir);



%% TRAINING ANALYSIS
f1 = figure(1); clf;
dat.training.date = [];
dat.training.dprime = [];
dat.training.hr = [];
dat.training.fa = [];
dat.training.contrast = [];
for i = 1:2
    % for lohi
    ind = fileInd(:,2) == 1 & fileInd(:,1) == i;
    if sum(ind)>1
        % plot performance with all lick times
        %trainingPlot(fileList(ind),fileInd(ind,:));
        
        [dprime,pcorrect,~,~,day,hr,fa] = ...
            trainingAnalysis(fileList(ind),fileInd(ind,:));
                
        % save out all data
        dat.training.date = [dat.training.date; day];
        dat.training.dprime = [dat.training.dprime; dprime'];
        dat.training.hr = [dat.training.hr; hr'];
        dat.training.fa = [dat.training.fa; fa'];
        dat.training.contrast = [dat.training.contrast; ...
                            ones(sum(ind),1)*i];
        
        % plot d' over time
        subplot(4,2,0+i)
        hold on
        plot(dprime,'k','LineWidth',1.5);
        axis tight
        ylabel('d-prime');
        xlabel('Training Session');
        title([ID ' - ' taskStr{i}])
        ylim([-1 7]);
        hold off
        plotPrefs
    end
end


%% PSYCHOMETRIC ANALYSIS
% for lohi

dat.psych.date = [];
dat.psych.nresp = [];
dat.psych.ntrials = [];
dat.psych.dprime = [];
dat.psych.hr = [];
dat.psych.fa = [];
dat.psych.thresh = [];
dat.psych.snr = [];
dat.psych.contrast = [];
for i = 1:2
    I = fileInd(:,2) == 2 & fileInd(:,1) == i;
    if sum(I)>1
        f2 = figure(2); clf;
        [rate,fa,dp,nresp,ntrials,threshold(i),f,snr] = ...
            psychAnalysis(fileList(I),fileInd(I,:));
        
        ind = fa < faCut & (sum(nresp,2) ./ sum(ntrials,2))' > .5;
        if sum(ind) == 0
            continue;
        end

        % save out all data
        dat.psych.date = [dat.psych.date; fileInd(I,3)];
        dat.psych.nresp = [dat.psych.nresp; nresp];
        dat.psych.ntrials = [dat.psych.ntrials; ntrials];
        dat.psych.dprime = [dat.psych.dprime; dp];
        dat.psych.hr = [dat.psych.hr; rate];
        dat.psych.fa = [dat.psych.fa; fa'];
        dat.psych.thresh = [dat.psych.thresh; [f.thresh]'];
        dat.psych.snr = [dat.psych.snr; snr];
        dat.psych.contrast = [dat.psych.contrast; ...
                            ones(sum(I),1)*i];
        
        % remove data above false alarm cutoff
        rate = rate(ind,:);
        fa = fa(ind);
        dp = dp(ind,:);
        nresp = nresp(ind,:);
        ntrials = ntrials(ind,:);
        f = f(ind);
        snr = snr(ind,:);
        
        % restructure to average over different SNRs
        [uSNR,~,iSNR] = unique(snr,'rows');
        for j = 1:size(uSNR,1)
            I = iSNR == j;
            nRESP(j,:,:) = sum(nresp(I,:),1);
            nTRIAL(j,:) = sum(ntrials(I,:),1);
        end
        
        % plot average psychometric performance
        figure(1);
        subplot(4,2,2+i)
        x = snr(:);
        y = nresp(:) ./ ntrials(:);
                
        % weighted fit
        [params,mdl,fthresh,sensitivity,FIT] = fitLogistic(x,y,[],[],[],ntrials(:));
        %f = psychometricFit(resp,trials,snr(1,:),mean(fa));
                           
        fx = linspace(min(x),max(x),100);
        fy = mdl(params,fx);
        [~,tind] = min(abs(fx-fthresh));
        tx = fx(tind);
        ty = fy(tind);
        hold on
        plot([tx tx], [0 ty],'k--','LineWidth',1.5);
        scatter(x,y,10,[0 0 0],'filled');
        plot(fx,fy,'Color',lineColor(i,:),'LineWidth',1.5)
        plot(min(x) - mean(diff(x)),mean(fa),'.','Color',[.5 .5 .5], ...
             'LineWidth',2,'MarkerSize',25);
        %set(gca,'XTick',[min(uSNR)-mean(diff(x)) x])
        %lbl = cell(1,7);
        %lbl(2:end) = strread(num2str(x),'%s');
        %lbl{1} = 'FA';
        %set(gca,'XTickLabels',lbl)       
        ylim([0 1]);
        ylabel('Hit Rate');
        xlabel('SNR (dB)');
        plotPrefs;
        hold off
                
        threshold(i) = fthresh;
        npsych{i} = ntrials(:);
        rpsych{i} = nresp(:);
        lvl{i} = snr(:);
                
        % save figure 2
        set(f2,'PaperPositionMode','auto');         
        set(f2,'PaperOrientation','landscape');
        set(f2,'PaperUnits','points');
        set(f2,'PaperSize',[2500 400]);
        set(f2,'Position',[0 0 2500 400]);
        print(f2,['_plots/' ID '-gumbalfits-' taskStr{i}],'-dpdf','-r300');
    end
end



%% OFFSET ANALYSIS
mdp = nan(2,6);
mdp1 = nan(2,6);
mrate = nan(2,6);
mfa = nan(2,6);

dat.offset.date = [];
dat.offset.dprime = [];
dat.offset.hr = [];
dat.offset.fa = [];
dat.offset.contrast = [];
dat.offset.snr = [];
for i = 1:2
    ind = fileInd(:,2) == 3 & fileInd(:,1) == i;
    if sum(ind) > 1
        clear rate;
        [rate,fa,dp,snr,offsets] = offsetAnalysis(fileList(ind), ...
                                                  fileInd(ind,:));
        
                                              
        % save out all data
        idx = find(ind);
        for j = 1:length(idx)
            dat.offset.date(end+1) = fileInd(idx(j),3);
            dat.offset.dprime(:,:,end+1) = dp(j,:,:);
            dat.offset.hr(:,:,end+1) = rate(j,:,:);
            dat.offset.fa(:,end+1) = fa(j,:);
            dat.offset.contrast(end+1) = i;
            dat.offset.snr(:,end+1) = snr(j,:);
        end                                             
                                              
        % remove bad data
        ind = nanmean(fa,2) < faCut;
        if sum(ind) == 0
            keyboard;
        end
        rate = rate(ind,:,:);
        fa = fa(ind,:);
        dp = dp(ind,:,:);
        snr = snr(ind,:);
        offsets = offsets(ind,:);
        
        
                                              
        
        % if none of the sessions are better than the current FA
        % cutoff, continue
        if isempty(offsets)
            fprintf('** NO GOOD SESSIONS FOUND ** \n');
            continue;
        end
        
        % plot pc
        figure(1)
        subplot(4,2,4+i)
        hold on
        x = nanmean(offsets,1);
        if size(rate,1) > 1
            if size(rate,3) ~= length(x)
                x = x(1:5);
            end
            errorbar(x,nanmean(squeeze(rate(:,1,:))), ...
                     nanstd(squeeze(rate(:,1,:)))./sqrt(size(rate,1)), ...
                     '-','LineWidth',1.5,'Markersize',25,'Color',lineColor(i,:));
            errorbar(x,nanmean(squeeze(rate(:,2,:))), ...
                     nanstd(squeeze(rate(:,2,:)))./sqrt(size(rate,1)), ...
                     'k-','LineWidth',1.5,'Markersize',25);
            errorbar(x,nanmean(fa),nanstd(fa)./sqrt(size(fa,1)), ...
                     '-','Color',[.4 .4 .4],'LineWidth',1.5);
        else
            plot(x,squeeze(rate(:,1,:)),'Color',lineColor(i,:),'LineWidth',2);
            plot(x,squeeze(rate(:,2,:)),'k','LineWidth',1.5);
            plot(x,fa,'-','Color',[.4 .4 .4],'LineWidth',1.5);
        end
        hold off
        ylabel('p(Response)')
        xlabel('Offset (s)');
        set(gca,'XTickLabelRotation',90);
        legend('Threshold','High SNR','FA','Location','ne');
        set(gca,'XTick',x(~isnan(x)));
        plotPrefs
        
        % plot dprime
        subplot(4,2,6+i)
        hold on
        if size(dp,1) > 1
            errorbar(x,nanmean(squeeze(dp(:,1,:))), ...
                     nanstd(squeeze(dp(:,1,:)))./sqrt(size(dp,1)), ...
                     '-','LineWidth',1.5,'Markersize',25,'Color',lineColor(i,:));
            errorbar(x,nanmean(squeeze(dp(:,2,:))), ...
                     nanstd(squeeze(rate(:,2,:)))./sqrt(size(dp,1)), ...
                     'k-','LineWidth',1.5,'Markersize',25,'LineWidth',1.5);
        else
            plot(x,squeeze(dp(:,1,:)),'Color',lineColor(i,:),'LineWidth',1.5);
            plot(x,squeeze(dp(:,2,:)),'k','LineWidth',1.5);
        end
        hold off
        ylabel('d-prime')
        xlabel('Offset (s)');
        set(gca,'XTickLabelRotation',90);
        legend('Threshold','High SNR','Location','ne');
        set(gca,'XTick',x(~isnan(x)));
        ylim([-1 5])
        plotPrefs
        
        % save out means
        mdp(i,:) = nanmean(squeeze(dp(:,1,:)));
        mdp1(i,:) = nanmean(squeeze(dp(:,2,:)));
        mrate(i,:) = nanmean(squeeze(rate(:,1,:)));
        mfa(i,:) = nanmean(fa);
    end
end



set(f1,'PaperPositionMode','auto');         
set(f1,'PaperOrientation','landscape');
set(f1,'PaperUnits','points');
set(f1,'PaperSize',[900 1200]);
set(f1,'Position',[0 0 900 1200]);
print(f1,['_plots/' ID '-summary'],'-dpdf','-r300');


















if 1 == 2
    clear yf xf
    % vectorize fits
    for j = 1:length(f)
        yf(j,:) = f(j).y;
        xf(j,:) = f(j).x;
    end
    
    % find xy value for threshold
    xfit = mean(xf);
    yfit = mean(yf);
    [~,tind] = min(abs(xfit-threshold(i)));
    tx = xfit(tind);
    ty = yfit(tind);
    
    % plot average psychometric performance
    figure(1);
    subplot(4,2,3+(i-1))
    hold on
    x = snr(1,:);
    errorbar(x,mean(rate),std(rate)./sqrt(size(rate,1)),'k.',...
             'Linewidth',2,'MarkerSize',25)
    errorbar(min(x)-mean(diff(x)),mean(fa),std(fa)./sqrt(length(fa)),'.',...
             'LineWidth',2,'MarkerSize',25,'Color',[.5 .5 .5])
    
    plot(mean(xf),mean(yf),'Color',lineColor(i,:),...
         'LineWidth',2);
    plot([tx tx],[0 ty],'k--','LineWidth',2);
    set(gca,'XTick',[min(x)-mean(diff(x)) x])
    lbl = cell(1,7);
    lbl(2:end) = strread(num2str(x),'%s');
    lbl{1} = 'FA';
    set(gca,'XTickLabels',lbl)       
    ylim([0 1]);
    ylabel('Hit Rate');
    xlabel('SNR (dB)');
    plotPrefs;
    hold off
end
