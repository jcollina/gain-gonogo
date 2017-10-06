function [rate,fa,dp,nresp,ntrials,threshold,fit,ind,snr] = ...
    psychAnalysis(fileList,fileInd)

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
    snr(i,:) = params.targetDBShift;
    fprintf('\t%i\n',fileInd(i,3));
    
    % remove erroneous trials
    [mn mi] = min([length(tt) length(resp)]);
    response = resp(1:mn)';
    trialType = tt(1:mn,:);
    
    % compute averages and remove early end anding trials
    [~,~,dp,pc,goodIdx] = computePerformanceGoNoGo(response,trialType,20,7);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);  
    
    % compute stats
    [nresp(i,:),ntrials(i,:),rate(i,:),dp(i,:),fa(i)] = ...
        psychometricPerformanceGoNoGo(trialType,response);
    fit(i) = psychometricFit(nresp(i,:),ntrials(i,:),snr(i,:));
    
    % plot psychometric curves
    subplot(1,length(testingList),i)
    plotPsychometricSession(snr(i,:),rate(i,:),fa(i),fit(i));
end

% get threshold for good sessions
ind = fa < faCut & max(rate,[],2)' > hrCut;
tmp = [fit.thresh];
threshold = tmp;