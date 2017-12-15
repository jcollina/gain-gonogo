function [nresp,ntrials,rate,dp,fa] = psychometricPerformanceGoNoGo(trialType,response)

% compute stats
conds = unique(trialType(:,1));
for i = 1:length(conds)
    nresp(i) = sum(response(trialType(:,1)==conds(i)));
    ntrials(i) = sum(trialType(:,1)==conds(i));
    rate(i) = nresp(i)/ntrials(i);
end

% remove noise trials
ind = conds == 0;
fa = rate(ind);
nresp = nresp(~ind);
ntrials = ntrials(~ind);
rate = rate(~ind);
rate(rate>.999) = .999;
rate(rate<.001) = .001;
fa(fa>.999) = .999;
fa(fa<.001) = .001;
dp = norminv(rate) - norminv(fa);
