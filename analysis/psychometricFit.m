function fit = psychometricFit(resps,count,snr)

addpath(genpath('Palamedes'));

% Initial parameters
PF = @PAL_Gumbel;
p0 = [mean(snr)+(.4*mean(snr)) .1 .1 .1];
pFree = [1 1 1 1];
lapseLimits = [0 1];

% fix hit rate
resps(resps == 0) = 1;

%searchGrid.alpha = linspace(snr(1),snr(end),100);
%searchGrid.beta  = linspace(0,.5,100);
%searchGrid.gamma = linspace(0,.5,100);
%searchGrid.lambda = linspace(0,.2,100);

% Set search options
options = PAL_minimize('options');
options.TolFun = 1e-10;
options.MaxIter = 10000;
options.MaxFunEvals = 10000;

% Maximum likelihood fitting using Palamedes
[pFit, ll, exitflag, output] = PAL_PFML_Fit(snr,resps,count,p0,pFree,PF,...
                    'searchOptions',options,...
                    'lapseLimits',lapseLimits);
if exitflag == 0
    keyboard
end

% Evaluate fit
fit.x = min(snr):.1:max(snr);
fit.y = PF(pFit,fit.x);
fit.func = PF;
fit.params = pFit;
fit.thresh = fit.params(1);
