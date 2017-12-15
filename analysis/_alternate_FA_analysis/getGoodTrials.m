function [resp,ttype,goodIdx] = getGoodTrials(resp,ttype,start,crit);

% function [resp,ttype,goodIdx] = getGoodTrials(resp,ttype,start,crit);
% 
% This function takes a vector of "yes/no" responses [resp] and a
% vector of "present/absent" trials [ttype] to remove trials in which
% the subject has stopped responding due to fatigue or satiety near
% the end of the run, by counting the number of responses from the
% end of the run and stopping when it hits a certain criterion lick
% count provided by [crit]

% resize trial type and resp to be in rows
if size(ttype,2) > size(ttype,1)
    ttype = ttype';
end
if size(resp,2) > size(resp,1)
    resp = resp';
end
   
% Truncate based on responses to get rid of the end where mice
% doesn't lick
if nargin == 4
    startv = start;
    count_back = sum(resp) - cumsum(resp);
    endnum = find(count_back == crit);
    endv = endnum(1);
    
    goodIdx = zeros(length(resp),1);
    goodIdx(startv:endv) = 1;
    
    resp = resp(startv:endv);
    ttype = ttype(startv:endv,:);
elseif nargin == 3
    goodIdx = zeros(length(resp),1);
    goodIdx(startv:end) = 1;
    
    resp = resp(startv:end);
    ttype = ttype(startv:end,:);
else
    goodIdx = ones(1,length(resp));
end