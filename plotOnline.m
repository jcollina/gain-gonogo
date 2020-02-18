function plotOnline(tt,resp,abort,avg,tstr)

tt = tt(:,1)'>0;
if length(tt) > 1
        
    % set averaging window depending on current trial count
    if length(tt) < avg + 1
        win = length(tt);
    else
        win = avg;
    end
    
    correct = tt == resp;
    correct = double(correct);
    correct(isnan(abort)) = nan;
    meanCorrect = movmean(correct,[win 0],'omitnan');
    
    lw = 1;
    
    clf
    subplot(3,1,1:2)
    hold on
    set(gca,'Color',[.8 .8 .8],...
        'LineWidth',lw,...
        'TickDir','out',...
        'FontSize',12);
    plot([0 length(tt)],[.5 .5],'--','Color',[.3 .3 .3],'LineWidth',lw);
    plot(1:length(meanCorrect),meanCorrect,'Color',[0 0 0],'LineWidth',lw);
    
    % plot hits
    hInd = find(tt == 1 & resp == 1);
    h(1) = scatter(hInd,meanCorrect(hInd),'o','g','Filled','LineWidth',lw);
    
    % plot CRs
    cInd = find(tt == 0 & resp == 0);
    h(2) = scatter(cInd,meanCorrect(cInd),'^','c','Filled','LineWidth',lw);
    
    % plot misses
    mInd = find(tt == 1 & resp == 0);
    h(3) = scatter(mInd,meanCorrect(mInd),'x','r','LineWidth',lw);
    
    % plot FAs
    fInd = find(tt == 0 & resp == 1);
    h(4) = scatter(fInd,meanCorrect(fInd),'*','m','LineWidth',lw);
    
    % plot aborted trials
    aInd = find(abort);
    h(5) = scatter(aInd,meanCorrect(aInd),100,[.75 0 0],'.');
    
    % initialize legend entries
    h(1) = scatter(1,2,'o','g','filled','LineWidth',lw);
    h(2) = scatter(1,2,'x','r','LineWidth',lw);
    h(3) = scatter(1,2,'*','m','LineWidth',lw);
    h(4) = scatter(1,2,'^','c','filled','LineWidth',lw);
    h(5) = scatter(1,2,100,[.75 0 0],'o','filled');
    ylim([0 1])
    set(gca,'xticklabels',[]);
    ylabel('p(Correct)');
    legend(h,'Hit','Miss','FA','CR','abort','Location','southeast');
    legend boxoff
    title(tstr)
    hold off
    grid on
    
    subplot(3,1,3)
    hold on
    set(gca,'Color',[.8 .8 .8],...
        'LineWidth',lw,...
        'TickDir','out',...
        'FontSize',12);
    pabort = movmean(abort,[win 0]);
    plot(1:length(abort),pabort,'k','LineWidth',lw);
    ylabel('p(Abort)');
    xlabel('Trial')
    ylim([0 l]);
    grid on
    
    drawnow
end
        
    
    