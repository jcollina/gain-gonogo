function [rate,fa,dp,snr,offsets] = offsetAnalysis(fileList,fileInd,faCut)

%% analyze each testing session
% 1. stats
% 2. fit all of them
% (trialtype: [signal/noise, offset, noisepatt])
    offI = [0.025 0.05 0.1 0.25 0.5 1.0];
    offsets = nan(length(fileList),length(offI));
    fa = nan(length(fileList),length(offI));
    rate = nan(length(fileList),2,length(offI));
    dp = nan(length(fileList),2,length(offI));
    disp('Analyzing offset testing session: ');
    for i = 1:length(fileList)
        % load the data (and get the date and snr values used)
        abort = [];
        load(fileList{i})
        snr(i,:) = params.targetDBShift;
        
         % index which set of target times was used
        [~,I] = ismember(round(params.noiseD - params.baseNoiseD,3),offI);
        offsets(i,I) = params.noiseD - params.baseNoiseD;
        fprintf('\t%i\n',fileInd(i,3));
        
        % make empty abort variable if there is none
        if isempty(abort)
            abort = zeros(size(resp));
        end
        
        % remove erroneous trials
        [mn mi] = min([length(tt) length(resp) length(abort)]);
        response = resp(1:mn)';
        trialType = tt(1:mn,:);
        abort = abort(1:mn)';
     
        % get good trials
        [~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,trialType,[],[],.25);
        response = response(goodIdx==1&~abort);
        trialType = trialType(goodIdx==1&~abort,:);
                
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
        fa(i,I) = r(1,:);
        rate(i,1,I) = r(2,:);
        rate(i,2,I) = r(3,:);
        
        % dprime
        rate(rate>.999) = .999;
        rate(rate<.001) = .001;
        fa(fa>.999) = .999;
        fa(fa<.001) = .001;
        dp(i,1,I) = norminv(squeeze(rate(i,1,I))') - norminv(fa(i,I));
        dp(i,2,I) = norminv(squeeze(rate(i,2,I))') - norminv(fa(i,I));
    end
           
