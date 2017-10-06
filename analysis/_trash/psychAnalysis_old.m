function [db hr fa fit] = psychAnalysis(d,files)

% preload all files and remove ones with too few trials
for i = 1:length(files)
    a = load([d filesep files(i).name]);
    if length(a.ts) < 100
        files(i) = [];
    end
end

% for each file
for i = 1:length(files)
    load([d filesep files(i).name]);
    
    % set x axis from SNRs
    db = fliplr(params.dB) - params.mu;
    
    if length(db) == 7
        continue;
    end
    
    
    % extract responses and trial type
    for j = 1:length(ts)
        resp(j) = any(ts(j).lick < ts(j).respend & ...
                      ts(j).lick > ts(j).respstart);
    end
    ind = removeBadTrials(resp);
    resp = resp(ind(1):ind(2));
    tt = trialType(ind(1):ind(2),:);
    
    % get performance at each level
    lvls = unique(tt(:,1));
    for j = 1:length(lvls)
        ntrials(j) = sum(tt(:,1) == lvls(j));
        nresps(j) = sum(resp(tt(:,1)== lvls(j)));
        rate(j) = nresps(j) / ntrials(j);
    end
    fa(i) = rate(1);
    hr(i,:) = fliplr(rate(2:end));
    nr(i,:) = fliplr(nresps(2:end));
    nt(i,:) = fliplr(ntrials(2:end));
    
    % compute individual psychometric fits
    fiti(i) = psychometricFit(nr(i,:),nt(i,:),fa(i),db);
    
    figure;
    hold on
    plot(db,hr(i,:),'.k','MarkerSize',30)
    plot(fiti(i).x,fiti(i).y,'r-','LineWidth',3);
    plot(3,fa(i),'.k','MarkerSize',30)
    x = fiti(i).thresh;
    y = fiti(i).func(fiti(i).params,fiti(i).thresh);
    plot([x x], [0 y],'--k','LineWidth',2);
    set(gca,'XTick',[3 db])
    lbl = cell(1,7);
    lbl(2:end) = strread(num2str(db),'%s');
    lbl{1} = 'FA';
    set(gca,'XTickLabels',lbl)
    set(gca, 'TickDir', 'out');
    set(gca,'FontSize',20);
    set(gca,'LineWidth',2);
    xlim([2 max(db)+1]);
    ylim([0 1]);
    ylabel('Hit Rate');
    xlabel('SNR (dB)');
    hold off
    
    keyboard
end

% fit psychometric function
nresps = sum(nr);
ntrials = sum(nt);
fit = psychometricFit(nresps,ntrials,mean(fa),db);

    
    
    
    
    
    
