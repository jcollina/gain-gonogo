function [resp,ttype,goodIdx] = getGoodTrials(resp,ttype,start,crit);

function [resp,ttype,goodIdx] = getGoodTrials(resp,ttype,start,crit);
% 
% This function takes a vector of "yes/no" responses [resp] and a
% vector of "present/absent" trials [ttype] to remove trials in which
% the subject has stopped responding due to fatigue or satiety near
% the end of the run, by counting the number of responses from the
% end of the run and stopping when it hits a certain criterion lick
% count provided by [crit]
   
% Truncate based on responses to get rid of the end where mice
% doesn't lick
if nargin == 4
    startv = start;
    count_back = sum(resp) - cumsum(resp);
    endnum = find(count_back == crit);
    endv = endnum(1);
    
    goodIdx = zeros(1,length(resp));
    goodIdx(startv:endv) = 1;
    
    resp = resp(startv:endv);
    ttype = ttype(startv:endv);
else
    goodIdx = ones(1,length(resp));
end