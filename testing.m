<<<<<<< HEAD
function testing(s, params)
=======
function testing(s,params)
>>>>>>> origin/master
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
hexPath = [params.hex filesep 'go-nogo_licks.ino.hex'];
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,9600);

<<<<<<< HEAD
% construct the stimuli
params.noiseD = params.baseNoiseD + [.25 .5 .75 1];
if params.sd(2) - params.sd(1) > 0
    params.stim = ['D:\stimuli\gainBehavior\170321_trainingLoHiChord-' params.boothID '.mat'];
    params.targetDBShift = 20;
else
    params.stim = ['D:\stimuli\gainBehavior\170321_trainingHiLoChord-' params.boothID '.mat'];
    params.targetDBShift = 10;
end
[stim, events, params.target, params.targetF] = constructStimChordTesting(params,s);

% modify params to reflect actual stimuli used
params.dbSteps = params.dbSteps(1);
params.dB = params.dB(1);

% open data file
fn = [params.fn '_training.txt'];
mat = [params.fn '_training.mat'];
=======
params.noiseD = params.baseNoiseD + [.05 .1 .25 .5 1];
rng(params.seed); % (to make the same stimulus each time)
if params.sd(2) - params.sd(1) > 0
    params.stim = ['~/stimuli/gainBehavior/170629_testingLoHiChord-' params.boothID '.mat'];
    params.targetDBShift = linspace(0,20,6);
else
    params.stim = ['~/stimuli/gainBehavior/170629_testingHiLoChord-' params.boothID '.mat'];
    params.targetDBShift =linspace(-10,10,6);
end
[stim, events, params.target, params.targetF] = constructStimChords(params);

% modify params to reflect actual stimuli used
% add modifications here

% presentation probabilities
params.offsetP = [.2 .2 .2 .2 .2];
params.dbP = [.4 .05 .05 .05 .05 .2 .2];

% open data file
fn = [params.fn '_testing.txt'];
mat = [params.fn '_testing.mat'];
>>>>>>> origin/master
fid = fopen(fn,'w');

fprintf('PRESS ANY KEY TO START...\n');
KbWait;

% send params to arduino
fprintf(p,'%f %f %f %f %d ',[params.holdD params.respD ...
    params.rewardDuration params.timeoutD params.debounceTime]);

tt = [];
cnt = 1;
runningAverage = 20;
<<<<<<< HEAD
while cnt < 2000
=======
while cnt < 1e6
>>>>>>> origin/master
    out = serialRead(p,params.boothID);
    
    % write to file and to command window
    fprintf(fid,'\n%s',out);
    fprintf('%s\n',strtrim(out));
    
    if contains(out,'TRIAL')
<<<<<<< HEAD
        % determine trial type
        tt(cnt,1) = rand > .5;
=======
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
>>>>>>> origin/master
        
        % make sure there aren't too many repeats
        if cnt > 3 && range(tt(end-3:end-1,1)) == 0
            tt(cnt,1) = ~tt(cnt-1,1);
        end
        
<<<<<<< HEAD
        % send trial type to arduino
        fprintf(p,'%d',tt(cnt,1));
        
        % determine offset
        tt(cnt,2) = randi(size(stim,2),1);
        
        % determine noise pattern
        tt(cnt,3) = randi(size(stim,2),1);
        
        % queue stimulus
        sound = [stim{tt(cnt,1)+1,tt(cnt,2),tt(cnt,3)} * params.ampF; ...
=======
        % determine offset
        tt(cnt,2) = d;
        
        % determine noise pattern
        tt(cnt,3) = randi(size(stim,3),1);
        
        % send trial type to arduino
        fprintf(p,'%d',tt(cnt,1)>0);
                
        % queue stimulus
        % NOTE TO FIX*** GENERATES RANDOM AMPLITUDES PER TRIAL ****
        if tt(cnt,1) == 0
            lvl = randi(size(stim,1));
        else
            lvl = tt(cnt,1);
        end
        sound = [stim{(tt(cnt,1)>0)+1,tt(cnt,2),tt(cnt,3),lvl} * params.ampF; ...
>>>>>>> origin/master
            events{tt(cnt,2)} * 1]';
        queueOutput(s,sound,params.device);
        cnd = sprintf('COND%d%d%02d',tt(cnt,:));
        fprintf(fid,'%04d %s\r',cnt,['00000000 ' cnd]);
        fprintf('%04d %s\n',cnt,['00000000 ' cnd]);
    elseif contains(out,'TON')
<<<<<<< HEAD
        
        
=======
>>>>>>> origin/master
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

<<<<<<< HEAD
=======
% save matfile
save(mat,'params','tt','resp');

>>>>>>> origin/master
% compute percent correct
if length(resp)==length(tt)
    pc = sum(resp' == tt(:,1)) / length(resp);
else
   pc = sum(resp' == tt(1:length(resp),1)) / length(resp); 
end
fprintf('\n\nPERCENT CORRECT: %02.2f\n\n',pc);

<<<<<<< HEAD
% save matfile
save(mat,'params','tt','resp');

=======
>>>>>>> origin/master
delete(instrfindall)
if strcmp(params.device,'NIDAQ')
    stop(s);
end
fclose('all');
delete(p);
% load the arduino sketch
hexPath = [params.hex filesep 'blank.ino.hex'];
loadArduinoSketch(params.com,hexPath);
<<<<<<< HEAD
clear all
=======
clear all
>>>>>>> origin/master
