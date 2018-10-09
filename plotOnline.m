function plotOnline(tt,resp,avg,tstr)

tt = tt(:,1)'>0;

if length(tt) > avg + 1
    correct = tt == resp;
    meanCorrect = movmean(correct,[avg 0]);
    
    clf
    hold on
    set(gca,'Color',[.8 .8 .8],...
        'LineWidth',2,...
        'TickDir','out',...
        'FontSize',15);
    plot([0 length(tt)],[.5 .5],'k--','LineWidth',1);
    plot(1:length(meanCorrect),meanCorrect,'Color',[0 0 0],'LineWidth',2);
    
    % plot hits
    hInd = find(tt == 1 & resp == 1);
    h(1) = scatter(hInd,meanCorrect(hInd),'o','g','LineWidth',2);
    
    % plot CRs
    cInd = find(tt == 0 & resp == 0);
    h(2) = scatter(cInd,meanCorrect(cInd),'^','c','LineWidth',2);
    
    % plot misses
    mInd = find(tt == 1 & resp == 0);
    h(3) = scatter(mInd,meanCorrect(mInd),'x','r','LineWidth',2);
    
    % plot FAs
    fInd = find(tt == 0 & resp == 1);
    h(4) = scatter(fInd,meanCorrect(fInd),'*','m','LineWidth',2);
    
    % initialize legend entries
    h(1) = scatter(1,2,'o','g','LineWidth',2);
    h(2) = scatter(1,2,'x','r','LineWidth',2);
    h(3) = scatter(1,2,'*','m','LineWidth',2);
    h(4) = scatter(1,2,'^','c','LineWidth',2);
    ylim([0 1])
    xlabel('Trial');
    ylabel('% Correct');
    legend(h,'Hit','Miss','FA','CR','Location','southeast');
    legend boxoff
    title(tstr)
    hold off
    grid on
    
    drawnow
end
        
    
    