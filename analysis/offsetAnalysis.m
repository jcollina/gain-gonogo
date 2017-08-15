function [rate,fa,dp,snr,offsets] = offsetAnalysis(fileList,dataDir,n)

addpath(genpath('~/chris-lab/code_general/'));
disp('Loading offset testing files...');
cnt = 1;
for i = 1:length(fileList)
    fn = [dataDir filesep fileList(i).name];
    if fileList(i).bytes > 1000
        t = parseLog(fn);
        if length(t) > n
            testingList{cnt} = fn;
            cnt = cnt + 1;
        end
    end
end

%% analyze each testing session
% 1. stats
% 2. fit all of them
% (trialtype: [signal/noise, offset, noisepatt])
figure(2)
disp('Analyzing offset testing session: ');
for i = 1:length(testingList)
    % load the data (and get the date and snr values used)
    [~, trialType, response, RT] = parseLog(testingList{i});
    tmp = strfind(testingList{i},'_');
    dateStr(i,:) = str2num(testingList{i}(tmp(1)+1:tmp(2)-1));
    disp(dateStr(i,:));
    load([testingList{i}(1:end-4) '.mat'],'params');
    snr(i,:) = params.targetDBShift;
    offsets(i,:) = params.noiseD - params.baseNoiseD;
    
    % get good trials
    [~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,trialType,1,7);
    RT = RT(goodIdx==1);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);
        
    % compute stats
    lvls = unique(trialType(:,1));
    offs = unique(trialType(:,2));
    for j = 1:length(lvls)
        for k = 1:length(offs)
            ind = trialType(:,1) == lvls(j) & ...
                  trialType(:,2) == offs(k);
            rate(j,k) = mean(response(ind));
        end
    end
    % split out fa and rate
    fa = rate(1,:);
    rate = rate(2:3,:);
    
    % dprime
    rate(rate>.999) = .999;
    rate(rate<.001) = .001;
    dp(1,:) = norminv(rate(1,:)) - norminv(fa);
    dp(2,:) = norminv(rate(2,:)) - norminv(fa);
    end
end

