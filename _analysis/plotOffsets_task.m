function plotOffsets_task(tt,resp,abort,params)
 
%% function plotOffsets_task(tt,resp,abort,params)
%
% fn = 'D:\GitHub\gain-gonogo\_data\CA118\CA118_2003241240_offsetTesting.txt';
% load('D:\GitHub\gain-gonogo\_data\CA118\CA118_2003241240_offsetTesting.mat','params')
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

% compute performance at each volume, and each laser condition, and time
uL = unique(tt(:,4));
uV = unique(tt(:,1));
uT = unique(tt(:,2));

for i = 1:length(uL)
    for j = 1:length(uV)
        for k = 1:length(uT)
        
            I = tt(:,1) == uV(j) & ...
                tt(:,2) == uT(k) & ...
                tt(:,4) == uL(i) & ...
                include;
            
            nresp(i,j,k) = sum(response(I));
            ntrials(i,j,k) = sum(I);
        
        end
        
    end
    
end

if strcmp(params.contrastCondition,'hilo')
    colour1 = [0 0 1];
    colour2 = [.5 .5 1];
else
    colour1 = [1 0 0];
    colour2 = [1 .5 .5];
end


times = params.noiseD - params.baseNoiseD;
vols = [params.targetDBShift(1) - 5 params.targetDBShift];
grad = [linspace(colour2(1),colour1(1),length(vols))' ...
        linspace(colour2(2),colour1(2),length(vols))' ...
        linspace(colour2(3),colour1(3),length(vols))'];
    grad = [.5 .5 .5; colour1; colour2];


hold on
for i = 1:length(uL)
    
    % plot each volume over time
    for k = 1:length(uV)
        
        if uL(i) == 1
            pcolor = [63 209 212] / 255;
            style = '-o';
        else
            pcolor = grad(k,:);
            style = '.-';
        end
        
        plot(times,squeeze(nresp(i,k,:)./ntrials(i,k,:)),...
             style,'Color',pcolor);
        
    end
   
end
ylim([0 1])
ylabel('Response Rate')
xlabel('Target Time (s)')
plotPrefs;


        