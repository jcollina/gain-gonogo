function plotOffsetSession(trialType,response)

% for each snr
uSNR = unique(trialType(:,1));
uOff = unique(trialType(:,2));
for i = 1:length(uSNR)
    % for each delay
    for j = 1:length(uOff)
        % response rate
        ind = trialType(:,1) == i-1 & trialType(:,2) == j;
        r(i,j) = sum(response(ind)) / sum(ind);
    end
end

offsets = [.025 .05 .1 .25 .5 1];
hold on
plot(offsets,r(1,:),'Color',[.3 .3 .3222222],'LineWidth',2)
plot(offsets,r(2,:),'r','LineWidth',2)
plot(offsets,r(3,:),'k','LineWidth',2)
legend('FA','Thresh','HiSNR');
xlabel('Offset (s)');
ylabel('p(resp)');
set(gca, 'TickDir', 'out');
set(gca,'FontSize',16);
set(gca,'LineWidth',2);
ylim([0 1]);





