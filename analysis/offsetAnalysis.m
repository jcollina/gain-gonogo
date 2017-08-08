function [hrThresh, hrEasyTr, fa, offsets] =  offsetAnalysis(d,files)

% preload all files and remove ones with too few trials
for i = 1:length(files)
    a = load([d filesep files(i).name]);
    if length(a.ts) < 100
        files(i) = [];
    end
end

% for each file
for i = 1:length(files)
    clear trialType ts params ind resp
    load([d filesep files(i).name]);
    
    % extract responses and trial type
    for j = 1:length(ts)
        resp(j) = any(ts(j).lick < ts(j).respend & ...
                      ts(j).lick > ts(j).respstart);
    end
    ind = removeBadTrials(resp);
    resp = resp(ind(1):ind(2));
    tt = trialType(ind(1):ind(2),:);
    
    % get performance at offset for each level
    lvls = unique(tt(:,1));
    offs = unique(tt(:,2));
    for j = 1:length(lvls)
        for k = 1:length(offs)
            ind = tt(:,1) == lvls(j) & tt(:,2) == offs(k);
            ntrials(j,k) = sum(ind);
            nresps(j,k) = sum(resp(ind));
            rate(j,k) = nresps(j,k) / ntrials(j,k);
        end
    end
    hrThresh(i,:) = rate(3,:);
    hrEasyTr(i,:) = rate(2,:);
    fa(i,:) = rate(1,:);
end

offsets = params.offset - params.baseNoiseD;

