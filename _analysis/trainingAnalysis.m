function [dprime,pcorrect,dpOffset,pcOffset,day,hitrate,farate] = ...
    trainingAnalysis(fileList,fileInd)

%% analyze each training session
% 1. PC and d'
% 2. PC and d' for each offset
% 3. RT for each offset
% (trialtype: [signal/noise, offset, noisepatt])
disp('Analyzing training sessions...');
for i = 1:length(fileList)
    % load the data
    abort = [];
    load(fileList{i})
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
    
    % compute averages and remove early end anding trials
    [hr,fa,dp,pc,goodIdx] = computePerformanceGoNoGo(response,trialType,20,7);
    response = response(goodIdx==1&~abort');
    trialType = trialType(goodIdx==1&~abort',:);    
    
    % compute performance for each offset
    offsets = unique(trialType(:,2));
    for j = 1:length(offsets)
        ind = trialType(:,2) == offsets(j);
        [~,~,dpo(j),pco(j),~] = computePerformanceGoNoGo(response(ind), ...
                                                   trialType(ind,1));
    end
    
    % save for each session
    hitrate(i)    = hr;
    farate(i)     = fa;
    dprime(i)     = dp;
    pcorrect(i)   = pc;
    dpOffset(i,:) = dpo;
    pcOffset(i,:) = pco;
end

% average results from the same day
day = fileInd(:,3);
sames = find(diff(day) == 0,1,'first');

while ~isempty(sames)
    hitrate(sames) = mean(hitrate(sames:sames+1));
    hitrate(sames+1) = [];
    farate(sames) = mean(farate(sames:sames+1));
    farate(sames+1) = [];
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
