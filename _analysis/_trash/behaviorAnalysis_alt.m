% find psychometric functions
addpath(genpath('../Palamedes/'));
addpath(genpath('~/chris-lab/code_general'));

%% process all mice
if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049','CA051','CA052','CA055','CA061','CA070','CA072','CA073','CA074','CA075'};
end

%mouseList = {'CA070','CA072','CA073','CA074','CA075'};

for i = 1:length(mouseList)
    dat_w(i) = behaviorAnalysis_earlyLicks(mouseList{i}, ...
                                                  true);
    dat_wo(i) = behaviorAnalysis_earlyLicks(mouseList{i}, ...
                                                  false);
    
    dpwit(:,:,i) = dat_w(i).offset.meanDPthresh;
    dpwitout(:,:,i) = dat_wo(i).offset.meanDPthresh;
    
    thresh(1,i) = mean(dat_w(i).offset.snr(1,dat_w(i).offset.contrast ...
                                           == 1));
    thresh(2,i) = mean(dat_w(i).offset.snr(1,dat_w(i).offset.contrast ...
                                           == 2));
end

% replace missing data with nans
dpwit(dpwit == 0) = nan;
dpwitout(dpwitout == 0) = nan;

taskStr = {'LoHi','HiLo'};
lineColor = [0 0 1;1 0 0];


f1 = figure(1); clf; hold on;
e = errorbar(repmat(dat_w(1).offset.offset,2,1)',...
         flipud(nanmean(dpwit,3))',...
         flipud(nanstd(dpwit,0,3) ./ sqrt(length(dat_w)-1))',...
         '--');
e(1).Color = lineColor(1,:); e(2).Color = lineColor(2,:);
e = errorbar(repmat(dat_w(1).offset.offset,2,1)',...
         flipud(nanmean(dpwitout,3))',...
         flipud(nanstd(dpwitout,0,3) ./ sqrt(length(dat_w)-1))',...
         'LineWidth',1.5)
e(1).Color = lineColor(1,:); e(2).Color = lineColor(2,:);
xlim([0 1.05]);
legend('LC - licks','HC - licks','LC - nolicks','HC - nolicks',...
       'Location','nw')
set(gca,'XTick',dat_w(1).offset.offset);
xlabel('Time (s)')
ylabel('d''')
plotPrefs;

fn = './_dp_over_time_alt_analysis.pdf';
saveFigPDF(f1,[500 300],fn);

%% original analysis

offsets = dat_w(1).offset.offset;

% for each contrast
for i = 1:2
    % for the first two times
    for j = 1:2
        [~,p(i,j)] = ttest(squeeze(dpwit(i,1,:)),...
                           squeeze(dpwit(i,j+1,:)));
    end
end

f2 = figure(2); clf; hold on;
e = errorbar(repmat(dat_w(1).offset.offset,2,1)',...
         flipud(nanmean(dpwit,3))',...
         flipud(nanstd(dpwit,0,3) ./ sqrt(length(dat_w)-1))',...
         'LineWidth',1.5)
e(1).Color = lineColor(1,:); e(2).Color = lineColor(2,:);
xlim([0 1.05]);

set(gca,'XTick',offsets);
xlabel('Time (s)')
ylabel('d''')
plotPrefs;

yv = flipud([2.5 2.625; 2.75 2.875]);
lc = flipud(lineColor);
% for each contrast
for i = 1:2
    % for the first two times
    for j = 1:2
        [~,p(i,j)] = ttest(squeeze(dpwit(i,1,:)),...
                           squeeze(dpwit(i,j+1,:)));
        plot([offsets(1) offsets(j+1)]-.02,[yv(i,j) yv(i,j)],...
             'Color',lc(i,:),'LineWidth',3)
        if p(i,j) > .1
            str = 'NS';
        elseif p(i,j) > .05 & p(i,j) < .1
            str = sprintf('p = %04.3f',p(i,j));
        elseif p(i,j) < .05 & p(i,j) > .01
            str = '*';
        elseif p(i,j) < .01 & p(i,j) > .001
            str = '**';
        elseif p(i,j) < .001
            str = '***';
        end
        text(offsets(j+1),yv(i,j),str);
    end
end
legend(e,'High to Low','Low to High',...
       'Location','se')
title(sprintf('n = %d',size(dpwit,3)))

fn = './_dp_over_time_analysis.pdf';
saveFigPDF(f2,[500 300],fn);



f3 = figure(3); clf; hold on
barWithError(flipud(thresh)',{'High to Low','Low to High'},[0 0 1; 1 0 0]);
l = line([ones(1,length(thresh))*2; ones(1,length(thresh))*1], ...
         [thresh(1,:); thresh(2,:)],...
         'Color',[0 0 0],'Marker','o');
plotPrefs;
ylabel('Threshold (dB SNR)');
title(sprintf('n = %d',size(dpwit,3)))
fn = './_threshold_analysis.pdf';
saveFigPDF(f3,[300 300],fn);


function [dat] = behaviorAnalysis_earlyLicks(ID,includeEarlyLicks)

    % ID = 'CA070';
    disp(['ANALYZING MOUSE ' ID]);

    baseDir = ['..' filesep 'data'];
    dataDir = [baseDir filesep ID];

    taskStr = {'LoHi','HiLo'};
    lineColor = [1 0 0; 0 0 1];

    % make a master file list
    [fileList fileInd] = indexDataFiles_log(dataDir);

    %% OFFSET ANALYSIS


    cnt = 0;
    for i = 1:2
        ind = fileInd(:,2) == 3 & fileInd(:,1) == i;
        
        if sum(ind) > 1
            
            % analyze offset sessions
            clear rate fa dp snr offsets;
            [rate,fa,dp,snr,offsets] = offsetAnalysis_alt(fileList(ind), ...
                                                          fileInd(ind,:),...
                                                          includeEarlyLicks);
            
            % save out all data
            idx = find(ind);
            for j = 1:length(idx)
                cnt = cnt + 1;
                dat.offset.date(cnt) = fileInd(idx(j),3);
                dat.offset.dprime(:,:,cnt) = dp(j,:,:);
                dat.offset.hr(:,:,cnt) = rate(j,:,:);
                dat.offset.fa(:,cnt) = fa(j,:);
                dat.offset.contrast(cnt) = i;
                dat.offset.snr(:,cnt) = snr(j,:);
            end    
            
            % remove bad data
            ind = mean(fa,2) < .3;
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
                continue;
            end
            
            % save out means
            dat.offset.meanDPthresh(i,:) = squeeze(nanmean(dp(:,1,:),1))';
            dat.offset.meanDPeasy(i,:) = squeeze(nanmean(dp(:,2,:),1))';
            dat.offset.meanHRthresh(i,:) = squeeze(nanmean(rate(:,1,:),1))';
            dat.offset.meanHReasy(i,:) = squeeze(nanmean(rate(:,2,:),1))';
            dat.offset.meanFA(i,:) = nanmean(fa);
            dat.offset.offset = offsets(1,:);
            
            
        end
    end

end



