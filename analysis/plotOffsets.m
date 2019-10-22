% mouse averaged dprime
t = [.05 .1 .25 .5 1];
nLoHi = mode(sum(~isnan(dp(:,1,:))),3);
mLoHi = nanmean(dp(:,1,:));
sLoHi = nanstd(dp(:,1,:)) ./ sqrt(nLoHi);
nHiLo = mode(sum(~isnan(dp(:,2,:))),3);
mHiLo = nanmean(dp(:,2,:));
sHiLo = nanstd(dp(:,2,:)) ./ sqrt(nHiLo);

clear p;
subplot(2,2,1)
hold on
p(1) = errorbar(t,squeeze(mLoHi),squeeze(sLoHi),'r','LineWidth',1);
plot(t,squeeze(mLoHi),'.r','MarkerSize',10)
p(2) = errorbar(t,squeeze(mHiLo),squeeze(sHiLo),'b','LineWidth',1);
plot(t,squeeze(mHiLo),'.b','MarkerSize',10)
plot([0 0],ylim,'k--');
xlim([-0.05 1.05]);
set(gca,'XTick',[0 t]);
title(sprintf('Threshold SNR (n = %d)',min([nLoHi nHiLo])));
xlabel('Time (s)');
ylabel('d''');
legend(p,'Low-to-High','High-to-Low','location','southeast');
plotPrefs;
hold off

% mouse averaged dprime at highest level
t = [.05 .1 .25 .5 1];
nLoHi = mode(sum(~isnan(dp1(:,1,:))),3);
mLoHi = nanmean(dp1(:,1,:));
sLoHi = nanstd(dp1(:,1,:)) ./ sqrt(nLoHi);
nHiLo = mode(sum(~isnan(dp1(:,2,:))),3);
mHiLo = nanmean(dp1(:,2,:));
sHiLo = nanstd(dp1(:,2,:)) ./ sqrt(nHiLo);

subplot(2,2,2)
hold on
p(1) = errorbar(t,squeeze(mLoHi),squeeze(sLoHi),'r','LineWidth',1);
plot(t,squeeze(mLoHi),'.r','MarkerSize',10)
p(2) = errorbar(t,squeeze(mHiLo),squeeze(sHiLo),'b','LineWidth',1);
plot(t,squeeze(mHiLo),'.b','MarkerSize',10)
plot([0 0],ylim,'k--');
xlim([-0.05 1.05]);
set(gca,'XTick',[0 t]);
title('High SNR');
xlabel('Time (s)');
ylabel('d''');
legend(p,'Low-to-High','High-to-Low','location','southeast');
plotPrefs;
hold off

% mouse averaged hit rate at threshold
t = [.05 .1 .25 .5 1];
nLoHi = mode(sum(~isnan(rate(:,1,:))),3);
mLoHi = nanmean(rate(:,1,:));
sLoHi = nanstd(rate(:,1,:)) ./ sqrt(nLoHi);
nHiLo = mode(sum(~isnan(rate(:,2,:))),3);
mHiLo = nanmean(rate(:,2,:));
sHiLo = nanstd(rate(:,2,:)) ./ sqrt(nHiLo);

nfaLoHi = mode(sum(~isnan(fa(:,1,:))),3);
mfaLoHi = nanmean(fa(:,1,:));
sfaLoHi = nanstd(fa(:,1,:)) ./ sqrt(nfaLoHi);
nfaHiLo = mode(sum(~isnan(fa(:,2,:))),3);
mfaHiLo = nanmean(fa(:,2,:));
sfaHiLo = nanstd(fa(:,2,:)) ./ sqrt(nfaHiLo);

subplot(2,2,3)
hold on
p(1) = errorbar(t,squeeze(mLoHi),squeeze(sLoHi),'r','LineWidth',1);
plot(t,squeeze(mLoHi),'.r','MarkerSize',10)
p(2) = errorbar(t,squeeze(mHiLo),squeeze(sHiLo),'b','LineWidth',1);
plot(t,squeeze(mHiLo),'.b','MarkerSize',10)
p(3) = errorbar(t,squeeze(mfaHiLo),squeeze(sfaHiLo),'--b','LineWidth',1);
plot(t,squeeze(mfaHiLo),'ob')
p(4) = errorbar(t,squeeze(mfaLoHi),squeeze(sfaLoHi),'--r','LineWidth',1);
plot(t,squeeze(mfaLoHi),'or')
plot([0 0],ylim,'k--');
xlim([-0.05 1.05]);
set(gca,'XTick',[0 t]);
title(sprintf('Threshold SNR (n = %d)',min([nLoHi nHiLo])));
xlabel('Time (s)');
ylabel('Response Rate');
legend(p,'High HR','Low HR','High FA','Low FA','location','southeast');
plotPrefs;
hold off

