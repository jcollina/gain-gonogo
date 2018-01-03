function [dprime,pcorrect,dpOffset,pcOffset] = ...
    trainingAnalysis(fileList,fileInd)

%% analyze each training session
% 1. PC and d'
% 2. PC and d' for each offset
% 3. RT for each offset
% (trialtype: [signal/noise, offset, noisepatt])
disp('Analyzing training sessions...');
for i = 1:length(fileList)
    % load the data
    load(fileList{i})
    fn = [fileList{i}(1:end-4) '.txt'];
    [t,trialType,response] = parseLog(fn);
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
    
    % compute performance
    [~,~,dp,pc,~] = computePerformanceGoNoGo(response,trialType);
    
    % compute performance for each offset
    offsets = unique(trialType(:,2));
    for j = 1:length(offsets)
        ind = trialType(:,2) == offsets(j);
        [~,~,dpo(j),pco(j),~] = computePerformanceGoNoGo(response(ind), ...
                                                   trialType(ind,1));
    end
    
    % save for each session
    dprime(i)     = dp;
    pcorrect(i)   = pc;
    dpOffset(i,:) = dpo;
    pcOffset(i,:) = pco;
end

% average results from the same day
day = fileInd(:,3);
sames = find(diff(day) == 0,1,'first');

while ~isempty(sames)
    dprime(sames) = mean(dprime(sames:sames+1));
    dprime(sames+1) = [];
    pcorrect(sames) = mean(pcorrect(sames:sames+1));
    pcorrect(sames+1) = [];
    dpOffset(sames,:) = mean(dpOffset(sames:sames+1,:));
    dpOffset(sames+1,:) = [];
    pcOffset(sames,:) = mean(pcOffset(sames:sames+1,:));
    pcOffset(sames+1,:) = [];
    day(sames+1) = [];
    fileInd(sames+1,:) = [];
    sames = find(diff(day) == 0,1,'first');
end
