function [rate,fa,dp,snr,offsets] = offsetAnalysis_alt(fileList,fileInd,includeEarlyLicks)


disp('Analyzing offset testing session: ');
for i = 1:length(fileList)
    

    
    % load the mat file
    load([fileList{i}(1:end-4) '.mat']);
    snr(i,:) = params.targetDBShift;
    offsets(i,:) = params.noiseD - params.baseNoiseD;
    fprintf('\t%i... ',fileInd(i,3));
    

    
    if ~includeEarlyLicks;
        
        % load the data from the log
        t = parseLog(fileList{i});
        
        mn = min([length(resp) length(tt) length(t)]);
        
        clear stimOn targOn cond lickTimes earlyLick;
        for j = 1:mn
            
            % get trial info
            stimOn(j) = t(j).stimTimes / 1e6;
            targOn(j) = t(j).respWin(1) / 1e6;
            cond(j)   = offsets(i,tt(j,2));
            lickTimes{j} = (t(j).lickTimes / 1e6) - stimOn(j);
            
            % check if there were any licks after the switch, up to
            % 50ms into the response window (which is theoretically
            % faster than a "real" response latency)
            earlyLick(j) = any(lickTimes{j} > 3 & ...
                   lickTimes{j} < cond(j) + 3 + .05);
%targTime = targOn(j) - stimOn(j);
%earlyLick(j) = any(lickTimes{j} > targTime - 1 & ...
%                   lickTimes{j} < targTime + .05);
            
        end
        fprintf('%d/%d early licks...',sum(earlyLick),mn);
        
        % check presentation error
        pErr = (cond - (targOn - stimOn - 3))';
        fprintf('timing error = %3.2fms\n',median(pErr)*1e3);
        
        if abs(median(pErr)*1e3) > 30
            disp('HIGH ERROR DETECTED');
            keyboard
        end
        
    else includeEarlyLicks;
        
        mn = min([length(resp) length(tt)]);
        earlyLick = zeros(1,mn);
        fprintf('\n');
        
    end
    
    
    %% continue analysis as normal
    % remove aborted trials
    response = resp(1:mn)';
    trialType = tt(1:mn,:);
    earlyLicks = earlyLick(1:mn)';
    
    % get good trials
    [~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,trialType,[],[],.25);
    response = response(goodIdx==1 & ~earlyLick');
    trialType = trialType(goodIdx==1 & ~earlyLick',:);
    
    % compute stats
    lvls = unique(trialType(:,1));
    offs = unique(trialType(:,2));
    for j = 1:length(lvls)
        for k = 1:length(offs)
            ind = trialType(:,1) == lvls(j) & ...
                  trialType(:,2) == offs(k);
            r(j,k) = mean(response(ind));
        end
    end
    % split out fa and rate
    fa(i,:) = r(1,:);
    rate(i,1,:) = r(2,:);
    rate(i,2,:) = r(3,:);
    
    % dprime
    rate(rate>.999) = .999;
    rate(rate<.001) = .001;
    fa(fa>.999) = .999;
    fa(fa<.001) = .001;
    dp(i,1,:) = norminv(squeeze(rate(i,1,:))') - norminv(fa(i,:));
    dp(i,2,:) = norminv(squeeze(rate(i,2,:))') - norminv(fa(i,:));
    
end