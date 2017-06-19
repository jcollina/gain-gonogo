function training(s,params)
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
hexPath = [params.hex filesep 'go-nogo_licks.ino.hex'];
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,9600);

% construct the stimuli
params.noiseD = params.baseNoiseD + [.25 .5 .75 1];
rng(params.seed); % (to make the same stimulus each time)
if params.sd(2) - params.sd(1) > 0
    params.stim = ['D:\stimuli\gainBehavior\170321_trainingLoHiChord-' params.boothID '.mat'];
    params.targetDBShift = 20;
else
    params.stim = ['D:\stimuli\gainBehavior\170321_trainingHiLoChord-' params.boothID '.mat'];
    params.targetDBShift = 10;
end
[stim, events, params.target, params.targetF] = constructStimChordTraining(params,s);

% modify params to reflect actual stimuli used
params.dbSteps = params.dbSteps(1);
params.dB = params.dB(1);

% open data file
fn = [params.fn '_training.txt'];
mat = [params.fn '_training.mat'];
fid = fopen(fn,'w');

fprintf('PRESS ANY KEY TO START...\n');
KbWait;

% send params to arduino
fprintf(p,'%f %f %f %f %d ',[params.holdD params.respD ...
    params.rewardDuration params.timeoutD params.debounceTime]);

tt = [];
cnt = 1;
runningAverage = 20;
while cnt < 2000
    out = serialRead(p,params.boothID);
    
    % write to file and to command window
    fprintf(fid,'\n%s',out);
    fprintf('%s\n',strtrim(out));
    
    if contains(out,'TRIAL')
        % determine trial type
        tt(cnt,1) = rand > .5;
        
        % make sure there aren't too many repeats
        if cnt > 3 && range(tt(end-3:end-1,1)) == 0
            tt(cnt,1) = ~tt(cnt-1,1);
        end
        
        % send trial type to arduino
        fprintf(p,'%d',tt(cnt,1));
        
        % determine offset
        tt(cnt,2) = randi(size(stim,2),1);
        
        % determine noise pattern
        tt(cnt,3) = randi(size(stim,2),1);
        
        % queue stimulus
        sound = [stim{tt(cnt,1)+1,tt(cnt,2),tt(cnt,3)} * params.ampF; ...
            events{tt(cnt,2)} * 1]';
        queueOutput(s,sound,params.device);
        cnd = sprintf('COND%d%d%02d',tt(cnt,:));
        fprintf(fid,'%04d %s\r',cnt,['00000000 ' cnd]);
        fprintf('%04d %s\n',cnt,['00000000 ' cnd]);
    elseif contains(out,'TON')
        
        
        % play stimulus
        startOutput(s,params.device);
    elseif contains(out,'TOFF')
        % make sure we're ready for the next trial
        if strcmp(params.device,'NIDAQ')
            if s.IsRunning
                stop(s);
            end
        end
        % plot the stuff
        plotOnline(tt,resp,runningAverage);
        cnt = cnt + 1;
    elseif contains(out,'REWARDON') || contains(out,'TOSTART')
        % some response logic
        resp(cnt) = 1;
    elseif contains(out,'MISS') || contains(out,'CORRECTREJECT')
        resp(cnt) = 0;
    elseif contains(out,'USEREXIT')
        break;
    end
end

% compute percent correct
pc = sum(resp' == tt(:,1)) / length(resp);
fprintf('\n\nPERCENT CORRECT: %02.2f\n\n',pc);

% save matfile
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
clear all