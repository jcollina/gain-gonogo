function [rate,fa,dp,nresp,ntrials,threshold,fit,snr] = ...
    psychAnalysis(fileList,fileInd,faCut)

addpath(genpath('~/chris-lab/code_general/'));

%% analyze each testing session
% 1. stats
% 2. fit all of them
% (trialtype: [signal/noise, offset, noisepatt])
figure(2); clf;
disp('Analyzing testing session: ');
nresp = [];
ntrials = [];
rate = [];
dp = [];
fa = [];
for i = 1:length(fileList)
    % load the data (and get the date and snr values used)
    load(fileList{i})
    fn = [fileList{i}(1:end-4) '.txt'];
    [t,trialType,response] = parseLog(fn);
    snr(i,:) = params.targetDBShift;
    fprintf('\t%i\n',fileInd(i,3));
    offsets = params.noiseD - params.baseNoiseD;
    
    % compute averages and remove early end anding trials
    [~,~,~,~,goodIdx] = computePerformanceGoNoGo1(response,trialType,t,1,7);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);  
    
    % compute stats
    [nresp(i,:),ntrials(i,:),rate(i,:),dp(i,:),fa(i)] = ...
        psychometricPerformanceGoNoGo(trialType,response);
    fit(i) = psychometricFit(nresp(i,:),ntrials(i,:),snr(i,:));
    
    % plot psychometric curves
    subplot(1,length(fileList),i)
    plotPsychometricSession(snr(i,:),rate(i,:),fa(i),fit(i));
end


ind = fa < faCut;
rate = rate(ind,:);
fa = fa(ind);
dp = dp(ind,:);
nresp = nresp(ind,:);
ntrials = ntrials(ind,:);
fit = fit(ind);
snr = snr(ind,:);

% get threshold
threshold = mean([fit.thresh]);