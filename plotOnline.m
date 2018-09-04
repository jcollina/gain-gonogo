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
    for i = 1:length(meanCorrect)
        if tt(i) == 1
            if resp(i) == 1
                h(1) = scatter(i,meanCorrect(i),'o','g','LineWidth',2);
            else
                h(2) = scatter(i,meanCorrect(i),'x','r','LineWidth',2);
            end
        else
            if resp(i) == 1
                h(3) = scatter(i,meanCorrect(i),'*','m','LineWidth',2);
            else
                h(4) = scatter(i,meanCorrect(i),'^','c','LineWidth',2);
            end
        end
    end
    
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
    pause(0.05);
end
        
    
    