addpath(genpath('~/chris-lab/code_general/'))
addpath(genpath('~/gits/gain-gonogo/'))
root = '~/gits/gain-gonogo/data';
mouseList = {'CA114','CA117','CA118','CA119','CA121','CA122'};

% for each mouse
for m = 1:length(mouseList)
    
    fprintf('Mouse %s\n',mouseList{m});
    
    % index data files
    dataDir = fullfile(root,mouseList{m});
    [fileList fileInd] = indexDataFiles(dataDir);
    
    clear abortSess hr fa dp pc nTrials abortFrac;
    
    % for each data file
    for i = 1:length(fileList)
        
        clear abort resp tt response trialType;
        
        % was it an abort task?
        vars = who('-file',fileList{i});
        abortSess(i) = any(contains(vars,'abort'));
        
        if ~abortSess(i)
            load(fileList{i});
            abort = zeros(size(resp));
            
        else
            % load using parselog, because some of the abort trials
            % weren't correctly written out
            [~,fn] = fileparts(fileList{i});
            [t,tt,resp,~,abort] = parseLog(fullfile(dataDir,[fn ...
                                '.txt']));
        end
        
        % match trial length
        [mn mi] = min([length(tt) length(resp)]);
        response = resp(1:mn)';
        trialType = tt(1:mn,:);
        abort = abort(1:mn);
        
        % remove abort trials
        response(abort == 1) = [];
        trialType(abort == 1,:) = [];
        
        % remove trials where the mouse stopped licking
        [~,~,~,~,goodIdx] = computePerformanceGoNoGo(response,trialType(:,1)>0,1,7);
        response = response(goodIdx==1);
        trialType = trialType(goodIdx==1,:);
        
        % compute performance on remaining trials
        [hr(i),fa(i),dp(i),pc(i)] = computePerformanceGoNoGo(response,trialType(:,1)>0,20,7);

        % how many total trials did the mice do?
        nTrials(i) = length(tt);
        
        % abort fraction
        abortFrac(i) = sum(abort) / length(abort);
        
    end
    
    dat(m).hr = hr;
    dat(m).fa = fa;
    dat(m).dp = dp;
    dat(m).pc = pc;
    dat(m).nTrials = nTrials;
    dat(m).abortSess = abortSess;
    dat(m).abortFrac = abortFrac;
    dat(m).firstAbortSess = find(abortSess,1,'first');
    
end

f1 = figure(1); clf;
c = colormap(parula(length(mouseList)));
off = .05;

for m = 1:length(mouseList)
    
    % plot stuff, centered on the first abort session
    x = -dat(m).firstAbortSess+1:1:length(dat(m).hr)- ...
        dat(m).firstAbortSess;
    
    subplot(4,1,1); hold on
    ph(1) = plot(x,dat(m).hr,'g','LineWidth',1);
    ph(2) = plot(x,dat(m).fa,'m','LineWidth',1);
    plot(x(x>=0),dat(m).hr(x>=0),'g','LineWidth',2)
    plot(x(x>=0),dat(m).fa(x>=0),'m','LineWidth',2)
    plot(x(x==0),dat(m).hr(x==0),'ko')
    plot(x(x==0),dat(m).fa(x==0),'ko')
    plot(x(end)+off*m,dat(m).hr(end),'.','Color',c(m,:),'MarkerSize',20);
    plot(x(end)+off*m,dat(m).fa(end),'.','Color',c(m,:),'MarkerSize',20);
    ylabel('p(respond)');
    plotPrefs;
    
    if m == length(mouseList)
        legend(ph,'Hits','FAs','location','sw');
    end
    
    subplot(4,1,2); hold on
    plot(x,dat(m).dp,'k','LineWidth',1);
    plot(x(x>=0),dat(m).dp(x>=0),'k','LineWidth',2)
    plot(x(x==0),dat(m).dp(x==0),'ko');
    plot(x(end)+off*m,dat(m).dp(end),'.','Color',c(m,:),'MarkerSize',20);
    ylabel('dPrime');
    plotPrefs;
    
    subplot(4,1,3); hold on
    plot(x,dat(m).nTrials,'k','LineWidth',1);
    plot(x(x>=0),dat(m).nTrials(x>=0),'k','LineWidth',2)
    plot(x(x==0),dat(m).nTrials(x==0),'ko');
    plot(x(end)+off*m,dat(m).nTrials(end),'.','Color',c(m,:), ...
         'MarkerSize',20);
    ylabel('Total Trials');
    plotPrefs;
    
    subplot(4,1,4); hold on
    plot(x,dat(m).abortFrac,'k','LineWidth',1);
    plot(x(x>=0),dat(m).abortFrac(x>=0),'k','LineWidth',2)
    plot(x(x==0),dat(m).abortFrac(x==0),'ko')
    p(m) = plot(x(end)+off*m,dat(m).abortFrac(end),'.','Color',c(m,:), ...
                'MarkerSize',20);
    ylabel('p(abort)')
    xlabel('Session Number rel. first abort session')
    plotPrefs;

    
end

legend(p,mouseList,'location','sw')
fn = sprintf('~/gits/gain-gonogo/analysis/abortSummary.pdf',root);
saveFigPDF(f1,[500 700],fn)

        
        
        
    
    