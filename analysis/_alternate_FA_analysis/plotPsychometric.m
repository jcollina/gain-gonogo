function plotPsychometric(db,hr,fa,fit);

hold on
% plot means
m = mean(hr);
s = std(hr) / sqrt(size(hr,1));
x = [db fliplr(db)];
y = [m+s fliplr(m-s)];
p1 = patch(x,y,1);
p1.FaceColor = [.7 .7 .7];
p1.EdgeColor = 'none';
plot(db,mean(hr),'k','LineWidth',2);
if exist('fa','var')
    f = errorbar(3,mean(fa),std(fa)/sqrt(length(fa)),...
                 'k.','LineWidth',2,'MarkerSize',25);
end

% plot threshold and fit
x = fit.thresh;
y = fit.func(fit.params,fit.thresh);
plot([x x], [0 y],'--k','LineWidth',2);
plot(fit.x,fit.y,'r','LineWidth',2);

% options
hold off
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


%  h = plot(repmat(db,size(hr,1),1)',hr','Color',[.7 .7 .7]);
%  plot(db,mean(hr),'k','LineWidth',2);
%  e = errorbar(db,mean(hr),std(hr)/size(hr,1),...
%                  'k.','LineWidth',2);