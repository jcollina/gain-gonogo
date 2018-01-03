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