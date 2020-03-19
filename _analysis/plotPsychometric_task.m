function plotPsychometric_task(tt,resp,abort,params)
 
%% function plotPsychometric_task(tt,resp,abort,params)
%
% fn = '~/gits/gain-gonogo/_data/CA117/CA117_2003181244_optoTesting.txt';
% load('~/gits/gain-gonogo/_data/CA117/CA117_2003181244_optoTesting.mat','params')
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

vols = params.targetDBShift;
xfit = linspace(min(vols),max(vols),100);
dbDiff = mean(diff(vols));

hold on
for i = 1:length(uL)
    
    if uL(i) == 1
        pcolor = [63 209 212] / 255;
        style = 'o';
        sz = 30;
    else
        pcolor = colour;
        style = '.';
        sz = 200;
    end
    
    scatter(vols,nresp(i,2:end)./ntrials(i,2:end),...
           sz,pcolor,style);
    plot(xfit,mdl(p(i,:),xfit),'Color',pcolor,'LineWidth',1);
    s = scatter(vols(1)-dbDiff,...
                nresp(i,1)./ntrials(i,1),sz,pcolor,style);
    
    
    % if threshold is within the plot range, plot it
    if threshold(i) > vols(1) & threshold(i) < vols(end)
        plot([threshold(i) threshold(i)],[0 mdl(p(i,:),threshold(i))],'--',...
             'Color',pcolor)
    end
    
end
ylim([0 1])
xlim([min(vols)-2*dbDiff max(vols)+dbDiff])
ylabel('Response Rate')
xlabel('Target Volume (dB SNR)')
    
set(gca,'xticklabels',num2str([-inf;params.targetDBShift'])) 
plotPrefs;


        






