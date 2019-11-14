function [rate,fa,dp,nresp,ntrials,threshold,f,snr] = ...
    psychAnalysis(fileList,fileInd,faCut)

addpath(genpath('~/chris-lab/code_general/'));
addpath(genpath('../'));

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
    [~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,trialType,1,7);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);  
    
    % compute stats
    [nresp(i,:),ntrials(i,:),rate(i,:),dp(i,:),fa(i)] = ...
        psychometricPerformanceGoNoGo(trialType,response);
    [f(i).params,f(i).func,f(i).thresh,f(i).sensitivity] = ...
        fitLogistic(snr(i,:),nresp(i,:)./ntrials(i,:));
    
    % plot psychometric curves
    subplot(1,length(fileList),i)
    plotPsychometricSession(snr(i,:),rate(i,:),fa(i),f(i));
end

% get threshold
threshold = mean([f.thresh]);