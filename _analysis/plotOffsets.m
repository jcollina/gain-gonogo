dp = [];
dp1 = [];
rate = [];
fa = [];
for i = 1:length(dat)
    
    % first entry is all zeros... remove
    tmp = dat(i).offset.dprime(:,:,2:end); 
    
    dp(i,1,:) = nanmean(squeeze(tmp(1,:,dat(i).offset.contrast==1)),2);
    dp(i,2,:) = nanmean(squeeze(tmp(1,:,dat(i).offset.contrast==2)),2);
    dp1(i,1,:) = nanmean(squeeze(tmp(2,:,dat(i).offset.contrast==1)),2);
    dp1(i,2,:) = nanmean(squeeze(tmp(2,:,dat(i).offset.contrast==2)),2);
    
    % hit rate
    tmp = dat(i).offset.hr(:,:,2:end); 
    rate(i,1,:) = nanmean(squeeze(tmp(1,:,dat(i).offset.contrast==1)),2);
    rate(i,2,:) = nanmean(squeeze(tmp(1,:,dat(i).offset.contrast==2)),2);
    
     % fa
    tmp = dat(i).offset.fa; 
    fa(i,1,:) = nanmean(squeeze(tmp(:,dat(i).offset.contrast==1)),2);
    fa(i,2,:) = nanmean(squeeze(tmp(:,dat(i).offset.contrast==2)),2);
    
end


% mouse averaged dprime
t = [.025 .05 .1 .25 .5 1];
nLoHi = max(sum(~isnan(dp(:,1,:))));
mLoHi = nanmean(dp(:,1,:));
sLoHi = nanstd(dp(:,1,:)) ./ sqrt(nLoHi);
nHiLo = max(sum(~isnan(dp(:,2,:))));
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
t = [.025 .05 .1 .25 .5 1];
nLoHi = max(sum(~isnan(dp1(:,1,:))));
mLoHi = nanmean(dp1(:,1,:));
sLoHi = nanstd(dp1(:,1,:)) ./ sqrt(nLoHi);
nHiLo = max(sum(~isnan(dp1(:,2,:))));
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
t = [.025 .05 .1 .25 .5 1];
nLoHi = max(sum(~isnan(rate(:,1,:))));
mLoHi = nanmean(rate(:,1,:));
sLoHi = nanstd(rate(:,1,:)) ./ sqrt(nLoHi);
nHiLo = max(sum(~isnan(rate(:,2,:))));
mHiLo = nanmean(rate(:,2,:));
sHiLo = nanstd(rate(:,2,:)) ./ sqrt(nHiLo);

nfaLoHi = max(sum(~isnan(fa(:,1,:))));
mfaLoHi = nanmean(fa(:,1,:));
sfaLoHi = nanstd(fa(:,1,:)) ./ sqrt(nfaLoHi);
nfaHiLo = max(sum(~isnan(fa(:,2,:))));
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
title(sprintf('Threshold SNR (n = %d)',min([mode(nLoHi) mode(nHiLo)])));
xlabel('Time (s)');
ylabel('Response Rate');
legend(p,'High HR','Low HR','High FA','Low FA','location','southeast');
plotPrefs;
hold off

