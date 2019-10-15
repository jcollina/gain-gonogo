function plotPsychometricSession(db,hr,fa,fit)

hold on
% plot performance
plot(db,hr,'k.','MarkerSize',25);
plot(min(db) - mean(diff(db)),fa,'.','Color',[.5 .5 .5],'MarkerSize',25);

% plot threshold and fit
x = fit.thresh;
y = fit.func(fit.params,fit.thresh);
xfine = db(1):.01:db(end);
plot([x x], [0 y],'--k','LineWidth',2);
plot(xfine,fit.func(fit.params,xfine),'r','LineWidth',2);

% options
hold off
set(gca,'XTick',[min(db)-mean(diff(db)) db])
lbl = cell(1,7);
lbl(2:end) = strread(num2str(db),'%s');
lbl{1} = 'FA';
set(gca,'XTickLabels',lbl)
set(gca, 'TickDir', 'out');
set(gca,'FontSize',16);
set(gca,'LineWidth',2);
ylim([0 1]);
ylabel('Hit Rate');
xlabel('SNR (dB)');


%  h = plot(repmat(db,size(hr,1),1)',hr','Color',[.7 .7 .7]);
%  plot(db,mean(hr),'k','LineWidth',2);
%  e = errorbar(db,mean(hr),std(hr)/size(hr,1),...
%                  'k.','LineWidth',2);