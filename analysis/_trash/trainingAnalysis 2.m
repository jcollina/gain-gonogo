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
    
    % compute averages and remove early end anding trials
    [~,~,~,~,goodIdx] = computePerformanceGoNoGo1(response,trialType,t,offsets,20,7);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);  
    
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
