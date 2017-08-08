function [dprime,pcorrect,allRT,dpOffset,pcOffset,rtOffset,day] = trainingAnalysis(trainingFiles,dataDir,n)

disp('Loading training files...');
cnt = 1;
for i = 1:length(trainingFiles)
    fn = [dataDir filesep trainingFiles(i).name];
    if trainingFiles(i).bytes > 1000
        t = parseLog(fn);
        if length(t) > n
            trainingList{cnt} = fn;
            cnt = cnt + 1;
        end
    end
end

%% analyze each training session
% 1. PC and d'
% 2. PC and d' for each offset
% 3. RT for each offset
% (trialtype: [signal/noise, offset, noisepatt])
disp('Analyzing training session: ');
for i = 1:length(trainingList)
    % load the data (and get the date)
    [~, trialType, response, RT] = parseLog(trainingList{i});
    tmp = strfind(trainingList{i},'_');
    dateStr(i,:) = str2num(trainingList{i}(tmp(1)+1:tmp(2)-1));
    disp(dateStr(i,:));
    
    % compute averages and remove early end anding trials
    [~,~,dp,pc,goodIdx] = computePerformanceGoNoGo(response,trialType,20,7);
    RT = RT(goodIdx == 1);
    response = response(goodIdx==1);
    trialType = trialType(goodIdx==1,:);
    
    
    % compute performance for each offset
    offsets = unique(trialType(:,2));
    for j = 1:length(offsets)
        ind = trialType(:,2) == offsets(j);
        [~,~,dpo(j),pco(j),~] = computePerformanceGoNoGo(response(ind), ...
                                                   trialType(ind,1));
        rto(j) = nanmean(RT(ind & trialType(:,1) > 0));
    end
    
    % save for each session
    dprime(i)     = dp;
    pcorrect(i)   = pc;
    allRT(i)      = nanmedian(RT);
    dpOffset(i,:) = dpo;
    pcOffset(i,:) = pco;
    rtOffset(i,:) = rto;
end

% average results from the same day
day = floor(dateStr(:)/10000);
sames = find(diff(day) == 0,1,'first');

while ~isempty(sames)
    dprime(sames) = mean(dprime(sames:sames+1));
    dprime(sames+1) = [];
    pcorrect(sames) = mean(pcorrect(sames:sames+1));
    pcorrect(sames+1) = [];
    allRT(sames) = mean(allRT(sames:sames+1));
    allRT(sames+1) = [];
    dpOffset(sames,:) = mean(dpOffset(sames:sames+1,:));
    dpOffset(sames+1,:) = [];
    pcOffset(sames,:) = mean(pcOffset(sames:sames+1,:));
    pcOffset(sames+1,:) = [];
    rtOffset(sames,:) = mean(rtOffset(sames:sames+1,:));
    rtOffset(sames+1,:) = [];
    day(sames+1) = [];
    sames = find(diff(day) == 0,1,'first');
end
