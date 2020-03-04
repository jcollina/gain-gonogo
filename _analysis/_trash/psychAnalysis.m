function [rate,fa,dp,nresp,ntrials,threshold,fit,ind,snr] = psychAnalysis(fileList,dataDir,n,faCut,hrCut)

addpath(genpath('~/chris-lab/code_general/'));
disp('Loading testing files...');
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
figure(2); clf;
disp('Analyzing testing session: ');
for i = 1:length(testingList)
    % load the data (and get the date and snr values used)
    [~, trialType, response, RT] = parseLog(testingList{i});
    tmp = strfind(testingList{i},'_');
    dateStr(i,:) = str2num(testingList{i}(tmp(1)+1:tmp(2)-1));
    disp(dateStr(i,:));
    load([testingList{i}(1:end-4) '.mat'],'params');
    snr(i,:) = params.targetDBShift;
    
    % get good trials
    [~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,trialType,1,7);
    RT = RT(goodIdx==1);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);
    
    % compute stats
    [nresp(i,:),ntrials(i,:),rate(i,:),dp(i,:),fa(i)] = ...
        psychometricPerformanceGoNoGo(trialType,response);
    fit(i) = psychometricFit(nresp(i,:),ntrials(i,:),snr(i,:));
    
    keyboard
    
    % plot psychometric curves
    subplot(1,length(testingList),i)
    plotPsychometricSession(snr(i,:),rate(i,:),fa(i),fit(i));
end

% get threshold for good sessions
ind = fa < faCut & max(rate,[],2)' > hrCut;
tmp = [fit.thresh];
threshold = tmp;