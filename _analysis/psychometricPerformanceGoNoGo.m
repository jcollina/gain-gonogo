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
rate(rate>.99) = .99;
rate(rate<.01) = .01;
fa(fa>.99) = .99;
fa(fa<.01) = .01;
dp = norminv(rate) - norminv(fa);
