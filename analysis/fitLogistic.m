function [params,mdl,threshold,sensitivity,FIT] = fitLogistic(x,y)

%% function [params,mdl,FIT] = fitLogistic(x,y)
%
% This function fits a psychometric curve to data using a logistic
% function: 
%
%   y = gamma + (1-gamma-lambda) .* ( 1 / (1 + exp(-(-alpha+beta.*x))) )
%
% where:
%   alpha = x-offset (JND = alpha/beta)
%   beta = slope (sensitivity)
%   gamma = guess rate (FA) -- constrained between 0 and 1
%   lambda = lapse rate (misses when the task is easy) -- constrained between 0 and 1
%
% INPUTS:
%  x,y: x and y data points to fit (eg. x = target SNR, y = p(response))
%
% OUTPUTS:
%  params: the fit parameters [alpha,beta,gamma,lambda]
%  mdl: logistic equation
%  threshold: alpha/beta, or the steepest part of the curve, aka JND
%  sensitivity: beta, or the slope
%  FIT: struct with some info about the fitting


% fitting model and options
mdl = @(a,x) (a(3) + (1-a(3)-a(4)) .* (1 ./ (1 + exp(-(-a(1)+(a(2).*x))))));
options = optimoptions('fmincon',...
                       'OptimalityTolerance', 1e-10,...
                       'StepTolerance', 1e-10, ...
                       'ConstraintTolerance', 1e-10,...
                       'Display','notify');

p0 = [mean(x) ...
      mean(diff(y))/mean(diff(x)) ...
      min(x) ...
      1-max(x)];
lb = [min(x) 0 0 0];
ub = [max(x) 10 1 1];
[params,fval,exitflag,output] = fmincon(...
    @(p) norm(y-mdl(p,x)),p0,[],[],[],[],lb,ub,[],options);

threshold = params(1)/params(2);
sensitivity = params(2);

FIT.finalFuncVal = fval;
FIT.optimFunc = @(p) norm(y-mdl(p,x));
FIT.exitflag = exitflag;
FIT.output = output;
FIT.options = options;