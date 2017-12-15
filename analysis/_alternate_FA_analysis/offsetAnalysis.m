function [rate,fa,dp,snr,offsets] = offsetAnalysis(fileList,fileInd,faCut)

%% analyze each testing session
% 1. stats
% 2. fit all of them
% (trialtype: [signal/noise, offset, noisepatt])
    disp('Analyzing offset testing session: ');
    for i = 1:length(fileList)
        % load the data (and get the date and snr values used)
        load(fileList{i})
        fn = [fileList{i}(1:end-4) '.txt'];
        [t,trialType,response] = parseLog(fn);
        snr(i,:) = params.targetDBShift;
        offsets(i,:) = params.noiseD - params.baseNoiseD;
        fprintf('\t%i\n',fileInd(i,3));
        
        % remove trials where mouse gave up
        [response,trialType,goodIdx] = getGoodTrials(response, ...
                                                     trialType,20,7);
        t = t(logical(goodIdx));
        
        % find window means
        windows = [offsets; offsets + params.respD];
        winMeans = mean(windows);
        
        % find trials with early licks
        earlyLicks = [t.RT]' < 0;
        firstLick = [t.firstLick]';
                
        % assign each lick time a probability of falling in each window
        x = 0:.001:2;
        clear plick;
        for j = 1:length(windows)
            m = offsets(j);
            sd = mean(diff(offsets));
            plick(:,j) = normpdf(firstLick(earlyLicks),m,sd);
            %hold on
            %plot(x,normpdf(x,m,sd));
        end
        [~,lickWindow] = max(plick');
        
        % adjust responses so trials with early licks are a response:
        response(earlyLicks) = 1;
        
        % are noise trials:
        trialType(earlyLicks,1) = false;
        
        % and reassign the lick bin accordingly:
        trialType(earlyLicks,2) = lickWindow;
        
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
    
    %ind = ~any(fa > faCut,2);
    ind = ~(mean(fa,2) > faCut)
    if sum(ind) == 0
        keyboard;
    end
    rate = rate(ind,:,:);
    fa = fa(ind,:);
    dp = dp(ind,:,:);
    snr = snr(ind,:);
    offsets = offsets(ind,:);