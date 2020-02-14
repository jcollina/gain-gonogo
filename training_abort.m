function training_abort(s,params)
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
if params.inverted
    hexPath = [params.hex filesep 'go-nogo_debug_inv.ino.hex'];
else
    hexPath = [params.hex filesep 'go-nogo_licks.ino.hex'];
end
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,19200);

% construct the stimuli
params.noiseD = params.baseNoiseD + [.25 .5 .75 1];

if params.sd(2) - params.sd(1) > 0
    params.targetDBShift = 25;
else
    params.targetDBShift = 20;
end
params.stim = fullfile('D:\stimuli\gainBehavior',...
    sprintf('%s_training%sChord-%s-dual.mat',...
    params.stimVersion,...
    params.contrastCondition,...
    params.boothID));
[stim, events, params.target, params.targetF] = constructStimChords(params);

% shuffle the seed to make the trials random each time, but save the state
% to ensure we can reconstruct trial order if all else fails
params.rngState = rng('shuffle');

% open data file
dt = datestr(now,'yymmddHHMM');
params.IDsess   = [params.IDstr '_' dt];
params.fn       = [params.data filesep params.IDsess];
fn = [params.fn '_training.txt'];
mat = [params.fn '_training.mat'];

% graph title
tstr = sprintf('%s - %s (%s)\n %s Training Performance',...
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
pause;

% send params to arduino
fprintf(p,'%f %f %f %f %d ',[params.holdD params.respD ...
    params.rewardDuration params.timeoutD params.debounceTime]);

% trial loop
abort = false;
abortFlag = false;
tt = [];
cnt = 1;
runningAverage = 20;
while cnt < 2000
    out = serialRead(p,params.boothID);
    
    % write to file and to command window
    fprintf(fid,'\n%s',out);
    fprintf('%s\n',strtrim(out));
    
    if contains(out,'TRIAL')
        
        if cnt == 1 || ~abort(cnt-1)
            % if the last trial wasn't aborted, make a new trial

            % determine trial type
            tt(cnt,1) = rand > .5;
            
            % make sure there aren't too many repeats
            if cnt > 3 && range(tt(end-3:end-1,1)) == 0
                tt(cnt,1) = ~tt(cnt-1,1);
            end
            
            % determine offset
            tt(cnt,2) = randi(size(stim,2),1);
            
            % determine noise pattern
            tt(cnt,3) = randi(size(stim,3),1);
            
        elseif cnt > 1
            % if the last trial was aborted, redo the trial
            tt(cnt,:) = tt(cnt-1,:);
            
        end
        
        % send trial type to arduino
        fprintf(p,'%d',tt(cnt,1));
                
        % queue stimulus
        sound = [stim{tt(cnt,1)+1,tt(cnt,2),tt(cnt,3)} * params.ampF; ...
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
        abortFlag = false;
        
        % plot and update trial count
        plotOnline(tt,resp,runningAverage,tstr);
        cnt = cnt + 1;
        
    elseif contains(out,'REWARDON') || contains(out,'TOSTART')
        % stop the stimulus if it is a timeout
        if contains(out,'TOSTART')
            stop(s);
        end
        
        % some response logic
        resp(cnt) = 1;
                
    elseif contains(out,'EARLYABORT')
        % abort the trial for early licks
        stop(s);
        
        % mark as invalid response
        resp(cnt) = nan;
        
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
    level = [];
end
save(mat,'params','tt','resp');

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
[~,tt,resp,~] = parseLog(fn);
plotOnline(tt(:,1),resp,runningAverage,tstr);
print(f1,sprintf('%s_training_performance.png',params.fn),'-dpng','-r300');

% compute percent correct
if length(resp)==length(tt)
    pc = sum(resp' == tt(:,1)) / length(resp);
else
   pc = sum(resp' == tt(1:length(resp),1)) / length(resp); 
end
rews = sum(resp'==1 & (tt(:,1)>0));
fprintf('\n\nPERCENT CORRECT: %02.2f\n\n',pc);
fprintf('\nReceived %03d rewards: %0.4f nL per reward (if  received 1 mL total)\n\n', ...
    rews,1/rews*1000);
