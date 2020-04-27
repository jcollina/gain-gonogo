function offsets_abort(s,params)
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
if params.inverted
    hexPath = [params.hex filesep 'go-nogo_abort_selectReward_inv.ino.hex'];
else
    hexPath = [params.hex filesep 'go-nogo_abort_selectReward.ino.hex'];
end
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,19200);

% extract threshold from file
load('_thresholds/thresholds2use.mat');
[ind] = find(strcmp(mouseList,params.IDstr));
[~,cond] = min(params.sd);
thresh = threshold(ind,cond);
if params.sd(2) - params.sd(1) > 0
    params.targetDBShift = 25;
else
    params.targetDBShift = 25;
end
params.targetDBShift = [thresh params.targetDBShift];
disp(['Threshold = ' num2str(thresh)]);

% target times
params.noiseD = params.baseNoiseD + [.05 .1 .25 .5 1];

% make stimuli
rng(params.seed); % (to make the same stimulus each time)
params.stim = fullfile('D:\stimuli\gainBehavior',...
    sprintf('%s_offsets%sChord-%s-thresh%s-dual.mat',...
    params.stimVersion,...
    params.contrastCondition,...
    params.boothID,...
    thresh));
[stim, events, params.target, params.targetF] = constructStimChords(params);

% shuffle the seed to make the trials random each time, but save the state
% to ensure we can reconstruct trial order if all else fails
params.rngState = rng('shuffle');

% presentation probabilities
params.offsetP = [.2 .2 .2 .2 .2];
params.dbP = [.3 .3 .4];

% reward contingency on volumes
params.rewCont = [0 2 1]; % 0 == timeout, 2 == no reward, 1 == reward

% open data file
dt = datestr(now,'yymmddHHMM');
params.IDsess   = [params.IDstr '_' dt];
params.fn       = [params.data filesep params.IDsess];
fn = [params.fn '_offsetTesting.txt'];
mat = [params.fn '_offsetTesting.mat'];

% graph title
tstr = sprintf('%s - %s (%s-%s)\nOffset Performance (thresh = %s)',...
    params.IDstr, ...
    dt, ...
    params.contrastCondition, ...
    params.boothID, ...
    num2str(thresh));

% check for open file
if exist(fn,'file')
    warning(sprintf('File %s already exists!',fn));
    keyboard
end
fid = fopen(fn,'w');

fprintf('PRESS ANY KEY TO START...\n');
KbWait;

% send params to arduino
params.timeoutD = 10;
fprintf(p,'%f %f %f %f %d %f',[params.holdD params.respD ...
    params.rewardDuration params.timeoutD params.debounceTime params.baseNoiseD]);

abort = false;
abortFlag = false;
tt = [];
cnt = 1;
runningAverage = 20;
while cnt < 1e6
    out = serialRead(p,params.boothID);
    
    % write to file and to command window
    fprintf(fid,'\n%s',out);
    fprintf('%s\n',strtrim(out));
    
    if contains(out,'TRIAL')
        
        if cnt == 1 || ~abort(cnt-1)
            % if the last trial wasn't aborted, make a new trial
            
            % random number to determine trial type
            num = rand;
            
            % choose offset
            intd = [0 cumsum(params.offsetP)];
            d = discretize(num,intd,'IncludedEdge','right');
            
            % choose target intensity
            intl = [intd(d) intd(d) + (params.offsetP(d).*cumsum(params.dbP))];
            l = discretize(num,intl,'IncludedEdge','right');
            
            % signal or noise
            tt(cnt,1) = l - 1;
            
            % make sure there aren't too many repeats of signal or noise
            if cnt > 3
                if all(tt(end-3:end-1,1) == 0)
                    % if they're all noise, make next trial a signal trial
                    % according to the signal probabilities
                    intl = [0 cumsum(params.dbP(2:end)) / sum(params.dbP(2:end))];
                    l = discretize(rand,intl,'IncludedEdge','right');
                    tt(cnt,1) = l;
                end
                if all(tt(end-3:end-1,1) > 0)
                    % if they're all signal trials, make the next trial noise
                    tt(cnt,1) = 0;
                end
            end
            
            % determine offset
            tt(cnt,2) = d;
            
            % determine noise pattern
            tt(cnt,3) = randi(size(stim,3),1);
            
        elseif cnt > 1
            % if the last trial was aborted, redo the trial
            tt(cnt,:) = tt(cnt-1,:);
            
        end
        
        % send trial type to arduino
        fprintf(p,'%d',double(params.rewCont(tt(cnt,1)+1)));
                
        % queue stimulus
        if tt(cnt,1) == 0
            lvl = randi(size(stim,1));
        else
            lvl = tt(cnt,1);
        end
        level(cnt) = lvl;
        sound = [stim{(tt(cnt,1)>0)+1,tt(cnt,2),tt(cnt,3),lvl} * params.ampF; ...
            events{tt(cnt,2)} * params.ampF]';
        queueOutput(s,sound,params.device);
        cnd = sprintf('COND%d%d%d',tt(cnt,:));
        fprintf(fid,'%04d %s\r',cnt,['00000000 ' cnd]);
        fprintf('%04d %s\n',cnt,['00000000 ' cnd]);
        
    elseif contains(out,'TON')
        % play stimulus
        startOutput(s,params.device);
        
    elseif contains(out,'TOFF')
        % wait for the sound to end
        wait(s);
         
        % indicate whether this trial was an abort trial and reset the
        % abort index for the next trial
        abort(cnt) = abortFlag;
        if abort(cnt)
            resp(cnt) = 0;
        end
        abortFlag = false;
        
        % plot and update trial count
        plotOnline(tt,resp,abort,runningAverage,tstr);
        cnt = cnt + 1;
        
    elseif contains(out,'REWARDON') || contains(out,'TOSTART') || contains(out,'HIT')
        % some response logic
        resp(cnt) = 1;
        
    elseif contains(out,'EARLYABORT')
        % abort the trial for early licks
        stop(s);
        
        % start the abort flag
        abortFlag = true;
     
    elseif contains(out,'MISS') || contains(out,'CORRECTREJECT')
        resp(cnt) = 0;
        
    elseif contains(out,'USEREXIT')
        break;
    end
end

% save matfile
if ~exist('resp','var')
    resp = [];
elseif ~exist('level','var')
    level = zeros(size(resp));
elseif ~exist('abort','var')
    abort = zeros(size(resp));
end
save(mat,'params','tt','resp','abort');

% close everything
delete(instrfindall)
if strcmp(params.device,'NIDAQ')
    stop(s);
end
fclose('all');
delete(p);

% load the arduino sketch
hexPath = [params.hex filesep 'blank.ino.hex'];
loadArduinoSketch(params.com,hexPath);

% save figure
f1 = figure(1);
[~,tt,resp,~,abort] = parseLog(fn);
plotOnline(tt(:,1),resp,abort,runningAverage,tstr);
print(f1,sprintf('%s_offsetTesting_performance.png',params.fn),'-dpng','-r300');

% and psychometric performance
f2 = figure(2);
plotOffsets_task(tt,resp,abort,params);
title(sprintf('%s Offset Curve',params.IDsess));
print(f2,sprintf('%s_offsetTesting_curve.png',params.fn),'-dpng','-r300');

% compute percent correct
mn = min([length(resp) length(tt)]);
pc = sum((resp(1:mn)' == (tt(1:mn,1)>0)) & ~abort(1:mn)') ./ sum(~abort(1:mn)); 

% compute reward count
rews = sum((resp(1:mn)'==1 & tt(1:mn,1)>0) & ~abort(1:mn)');

fprintf('\n\nPERCENT CORRECT: %02.2f\n\n',pc);
fprintf('\nReceived %03d rewards: %0.4f nL per reward (if  received 1 mL total)\n\n', ...
    rews,1./rews*1000);
