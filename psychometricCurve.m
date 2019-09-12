function psychometricCurve(x,y,l,params)

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

% choose color
if strcmp(params.contrastCondition,'lohi')
    col = [1 0 0];
elseif strcmp(params.contrastCondition,'hilo')
    col = [0 0 1];
end

% plotting
hold on
plot(fit.x,fit.y,'Color',col,'LineWidth',2);
plot(min(l)-5, hr(1),'.','Color',[.5 .5 .5],'MarkerSize',30);
xLimits = xlim;
plot([xLimits(1) fit.thresh],[.5 .5],'--k');
plot([fit.thresh fit.thresh],[0 .5],'--k');
plot(l,hr(2:end),'.k','MarkerSize',30);
xlabel('dbSteps');
ylabel('pHit');
ylim([0 1]);
xlim(XLimits);
set(gca,'XTick',l);