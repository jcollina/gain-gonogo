function psychometricCurve(x,y,l)

% function psychometricCurve(x,y,n)
% Inputs: x (levels)
%         y (response per trial)
%         l (actual stimulus values, string?)

conds = unique(x);
nConditions = length(unique(x));
for i = 1:nConditions
    r(i) = sum(y(x==conds(i)));
    n(i) = sum(x==conds(i));
    hr(i) = r(i)/n(i);
end

% fit the psychometric function
fit = psychometricFit(r(2:end),n(2:end),l);

% plotting
h = figure;
hold on
plot(fit.x,fit.y,'k','LineWidth',2);
plot(min(l)-5, hr(1),'.k','MarkerSize',30);
xLimits = xlim;
plot([xLimits(1) fit.thresh],[.5 .5],'--k');
plot([fit.thresh fit.thresh],[0 .5],'--k');
plot(l,hr(2:end),'.r','MarkerSize',30);
xlabel('dbSteps');
ylabel('pHit');
ylim([0 1]);
set(gca,'XTick',l);