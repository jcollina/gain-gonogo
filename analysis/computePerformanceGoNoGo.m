function [hr,fa,dp,pc,goodIdx] = computePerformanceGoNoGo(resp,ttype,start,crit,respThresh)
    
%% function [hr,fa,dp,pc] = computePerformance(resp,ttype,truncate)
% 
% This function takes a vector of "yes/no" responses [resp] and a
% vector of "present/absent" trials [ttype] to compute the hit rate, false
% alarm rate, dprime index and overall percent correct. Optionally,
% if truncate is set to true, it attempts to remove trials in which
% the subject has stopped responding due to fatigue or satiety near
% the end of the run, by counting the number of responses from the
% end of the run and stopping when it hits a certain criterion lick
% count provided by [crit]

% Truncate based on responses to get rid of the end where mice
% doesn't lick
if exist('crit','var') & ~isempty(crit)
    if ~exist('start','var')|isempty(start)
        start = 20;
    end
    startv = start;
    count_back = sum(resp) - cumsum(resp);
    endnum = find(count_back == crit);
    if isempty(endnum)
        endv = length(resp);
    else
        endv = endnum(1);
    end
    
    goodIdx = zeros(1,length(resp));
    goodIdx(startv:endv) = 1;
else
    goodIdx = ones(1,length(resp));
end

% remove periods where there were no licks
if exist('respThresh','var')
    respMean = movmean(resp,15);
    goodIdx = respMean >= respThresh;
end

goodIdx = logical(goodIdx);

resp = resp(goodIdx);
ttype = ttype(goodIdx);

ttype = ttype>0;
if any(size(resp) ~= size(ttype))
    ttype = ttype';
end
pc = mean(resp == ttype);
hr = mean(resp(ttype>0));
fa = mean(resp(ttype==0));

% Correct for perfect hr/fa
hr1 = hr;
fa1 = fa;
if hr1 == 1
    hr1 = .99;
end
if hr1 == 0
    hr1 = .01;
end
if fa1 == 0
    fa1 = .01;
end
if fa1 == 1
    fa1 = .99;
end

dp = norminv(hr1) - norminv(fa1);
