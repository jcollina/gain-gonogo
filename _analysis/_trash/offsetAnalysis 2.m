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
     
        % get good trials
        [response,trialType,goodIdx] = getGoodTrials(response,trialType,1,7);
        response = response(goodIdx==1);
        trialType = trialType(goodIdx==1,:);
        
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