function plotPsychometric_task(tt,resp,abort,params)
 
%% function plotPsychometric_task(tt,resp,abort,params)
%
% fn = '~/gits/gain-gonogo/_data/CA119/CA119_2003181107_testing.txt';
% load('~/gits/gain-gonogo/_data/CA119/CA119_2003181107_testing.mat','params')
% 
% [~,tt,resp,~,abort] = parseLog(fn);

addpath(genpath('./_analysis/'))

% if it isn't a laser task, set laser column to zeros
if size(tt,2) ~= 4
    tt(:,4) = zeros(length(tt),1);
end

% match tt and resp if necessary
mn = min([length(tt) length(resp) length(abort)]);
ttype = tt(1:mn,:);
response = resp(1:mn);
abort = abort(1:mn);

% get the good index
[~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,ttype(:,1)>0, ...
                                             1,5);

% include trials where the mice did the task and non aborts
include = goodIdx' & ~abort';

% compute performance at each volume, and each laser condition
uL = unique(tt(:,4));
uV = unique(tt(:,1));

for i = 1:length(uL)
    for j = 1:length(uV)
        
        I = tt(:,4) == uL(i) & tt(:,1) == uV(j) & include;
        
        nresp(i,j) = sum(response(I));
        ntrials(i,j) = sum(I);
        
    end
    
    [p(i,:),mdl,threshold(i),sensitivity(i),FIT] = ...
        fitLogistic(params.targetDBShift,nresp(i,2:end)./ntrials(i,2:end),...
                    [],[],[],ntrials(i,2:end));
    
end

if strcmp(params.contrastCondition,'hilo')
    colour = [0 0 1];
else
    colour = [1 0 0];
end

xfit = linspace(min(params.targetDBShift),max(params.targetDBShift),100);

hold on
for i = 1:length(uL)
    
    if uL(i) == 1
        pcolor = [63 209 212] / 255;
    else
        pcolor = colour;
    end
    
    scatter(params.targetDBShift,nresp(i,2:end)./ntrials(i,2:end),...
           35,pcolor,'filled');
    plot(xfit,mdl(p(i,:),xfit),'Color',pcolor,'LineWidth',1);
    scatter(params.targetDBShift(1)-mean(diff(params.targetDBShift)),...
            nresp(i,1)./ntrials(i,1),35,[.5 .5 .5],'filled');
    
    % if threshold is within the plot range, plot it
    if threshold(i) > params.targetDBShift(1) & threshold(i) < params.targetDBShift(end)
        plot([threshold(i) threshold(i)],[0 mdl(p(i,:),threshold(i))],'--',...
             'Color',pcolor)
    end
    
end
ylim([0 1])
ylabel('Response Rate')
xlabel('Target Volume (dB SNR)')
    
set(gca,'xticklabels',num2str([-inf;params.targetDBShift'])) 
plotPrefs;


        






