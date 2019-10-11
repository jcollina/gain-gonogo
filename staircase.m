function staircase(s,params)
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
if params.inverted
    hexPath = [params.hex filesep 'go-nogo_licks_inv.ino.hex'];
else
    hexPath = [params.hex filesep 'go-nogo_licks.ino.hex'];
end
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,9600);

params.noiseD = params.baseNoiseD + .5;
%[.05 .1 .25 .5 1];
rng(params.seed); % (to make the same stimulus each time)
params.targetDBShift = -5:1:25;
params.stim = fullfile('D:\stimuli\gainBehavior',...
    sprintf('%s_staircase%sChord-%s-dual.mat',...
    params.stimVersion,...
    params.contrastCondition,...
    params.boothID));
[stim, events, params.target, params.targetF] = constructStimChords(params);

% shuffle the seed to make the trials random each time, but save the state
% to ensure we can reconstruct trial order if all else fails
params.rngState = rng('shuffle');

% presentation probabilities
params.offsetP = [1];
%[.2 .2 .2 .2 .2];
params.dbP = [.4 .4 .2]; % noise, quest, high SNR
%params.dbP = [.3 .1 .1 .1 .1 .15 .15];

% quest parameters for staircase
params.tGuess = mean(params.targetDBShift);        % threshold guess
params.tGuessSD = 10;      % uncertainty around the guess (SD)
params.pThreshold = 0.70;  % threshold performance value
params.beta = 1.5;         % slope
params.gamma = .1;         % guess rate
params.delta = .05;        % lapse rate
q = QuestCreate(params.tGuess,params.tGuessSD,params.pThreshold,params.beta,params.delta,params.gamma,...
    1,[],[]);
q.normalizePdf = 1;

% open data file
dt = datestr(now,'yymmddHHMM');
params.IDsess   = [params.IDstr '_' dt];
params.fn       = [params.data filesep params.IDsess];
fn = [params.fn '_staircase.txt'];
mat = [params.fn '_staircase.mat'];

% graph title
tstr = sprintf('%s - %s (%s)\n %s Staircase Performance',...
    params.IDstr, ...
    dt, ...
    params.boothID, ...
    params.contrastCondition);

% check for open file
if exist(fn,'file')
    warning(sprintf('File %s already exists!',fn));
    keyboard
end
fid = fopen(fn,'w');

fprintf('PRESS ANY KEY TO START...\n');
KbWait;

params.timeoutD = 10;

% send params to arduino
fprintf(p,'%f %f %f %f %d ',[params.holdD params.respD ...
    params.rewardDuration params.timeoutD params.debounceTime]);

tt = [];
cnt = 1;
runningAverage = 20;
while cnt < 1e6
    out = serialRead(p,params.boothID);
    
    % write to file and to command window
    fprintf(fid,'\n%s',out);
    fprintf('%s\n',strtrim(out));
    
    if contains(out,'TRIAL')
        % random number to determine trial type
        num = rand;
        
        % choose offset
        intd = [0 cumsum(params.offsetP)];
        d = discretize(num,intd,'IncludedEdge','right');
        
        % choose target type
        intl = [intd(d) intd(d) + (params.offsetP(d).*cumsum(params.dbP))];
        l = discretize(num,intl,'IncludedEdge','right');
                
        % determine trial type (0 == noise, 1 == quest, 2 == high snr)
        trialType = l;
        if trialType == 1
            % noise trial
            tt(cnt,1) = 0;
            
        elseif trialType == 2
            % get trial volume from quest
            tTest = QuestQuantile(q);
            if tTest > max(params.targetDBShift)
                tTest = max(params.targetDBShift);
            elseif tTest < min(params.targetDBShift)
                tTest = min(params.targetDBShift);
            end
            tt(cnt,1) = find(params.targetDBShift == round(tTest));
            
        elseif trialType == 3
            % easy target trial
            tt(cnt,1) = length(params.targetDBShift);
            
        end
        
        % if only using staircase trials
        if params.dbP(2) ~= 1
            % make sure there aren't too many repeats of signal or noise
            if cnt > 3
                if all(tt(end-3:end-1,1) == 0)
                    % if they're all noise, make next trial an easy trial
                    tt(cnt,1) = length(params.targetDBShift);
                    trialType = 3;
                end
                if all(tt(end-3:end-1,1) > 0)
                    % if they're all signal trials, make the next trial noise
                    tt(cnt,1) = 0;
                    trialType = 1;
                end
            end
        end
        
        % determine offset
        tt(cnt,2) = d;
        
        % determine noise pattern
        tt(cnt,3) = randi(size(stim,3),1);
        
        % send trial type to arduino
        fprintf(p,'%d',double(tt(cnt,1)>0));
                
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
        
        % write to file
        cnd = sprintf('COND-%02d-%d-%d-%d',tt(cnt,:),trialType-1);
        fprintf(fid,'%04d %s\r',cnt,['00000000 ' cnd]);
        
        % print to screen
        if trialType ~= 2
            cnd = cnd;
        else
            cnd = sprintf('%s QuestDB=%02d',cnd,round(tTest));
        end
        fprintf('%04d %s\n',cnt,['00000000 ' cnd]);
        
    elseif contains(out,'TON')
        % play stimulus
        startOutput(s,params.device);
        
    elseif contains(out,'TOFF')
        % make sure we're ready for the next trial
        if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
            if s.IsRunning
                stop(s);
            end
        end
        % plot the stuff
        plotOnline(tt,resp,runningAverage,tstr);
        
        % if previous trials was a quest trial, update the quest object
        if trialType == 2
            q = QuestUpdate(q,tTest,resp(cnt));
        end
        
        cnt = cnt + 1;
        
    elseif contains(out,'REWARDON') || contains(out,'TOSTART')
        % some response logic
        resp(cnt) = 1;
        
        % stop the stimulus if it is a timeout
        if contains(out,'TOSTART')
            if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
                stop(s);
            end
        end
        
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
    level = [];
end
save(mat,'params','tt','resp','level');

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

% plot performance over time and save
f1 = figure(1);
[~,trialType,response,~] = parseLog(fn);
plotOnline(trialType(:,1),response,runningAverage,tstr);
print(f1,sprintf('%s_staircase_performance.png',params.fn),'-dpng','-r300');

% and psychometric performance
f2 = figure(2);
l = params.targetDBShift;
psychometricCurve(trialType(:,1),response,l,params);
title(sprintf('%s Staircase Curve',params.IDsess));
print(f2,sprintf('%s_staircase_curve.png',params.fn),'-dpng','-r300');

% compute percent correct and reward count
if length(resp)==length(tt)
    pc = mean(resp' == (tt(:,1)>0));
    rews = sum(resp'==1 & (tt(:,1)>0));
else
    pc = mean(resp' == (tt(1:length(resp),1)>0));
    rews = sum(resp'==1 & (tt(1:length(resp),1)>0));
end

fprintf('\n\nPERCENT CORRECT: %02.2f\n\n',pc);
fprintf('\nReceived %03d rewards: %0.4f nL per reward (if  received 1 mL total)\n\n', ...
    rews,1/rews*1000);

