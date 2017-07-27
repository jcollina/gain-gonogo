function testing(s,params)
KbName('UnifyKeyNames');
delete(instrfindall);

% load the arduino sketch
hexPath = [params.hex filesep 'go-nogo_licks.ino.hex'];
loadArduinoSketch(params.com,hexPath);

% open the serial port
p = setupSerialPort(params.com,9600);

params.noiseD = params.baseNoiseD + [.25 .5 .75 1];
%[.05 .1 .25 .5 1];
rng(params.seed); % (to make the same stimulus each time)
if params.sd(2) - params.sd(1) > 0
    params.stim = ['D:\stimuli\gainBehavior\170727_testingLoHiChord-' params.boothID '-dual.mat'];
    params.targetDBShift = linspace(8,20,6);
else
    params.stim = ['D:\stimuli\gainBehavior\170727_testingHiLoChord-' params.boothID '-dual.mat'];
    params.targetDBShift =linspace(-5,15,6);
end
[stim, events, params.target, params.targetF] = constructStimChords(params);
rng('shuffle');

% modify params to reflect actual stimuli used
% add modifications here

% presentation probabilities
params.offsetP = [.25 .25 .25 .25];
%[.2 .2 .2 .2 .2];
params.dbP = [.4 .05 .05 .05 .05 .2 .2];

% open data file
fn = [params.fn '_testing.txt'];
mat = [params.fn '_testing.mat'];
fid = fopen(fn,'w');

fprintf('PRESS ANY KEY TO START...\n');
KbWait;

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
        
        % send trial type to arduino
        fprintf(p,'%d',double(tt(cnt,1)>0));
                
        % queue stimulus
        % NOTE TO FIX*** GENERATES RANDOM AMPLITUDES PER TRIAL ****
        if tt(cnt,1) == 0
            lvl = randi(size(stim,1));
        else
            lvl = tt(cnt,1);
        end
        sound = [stim{(tt(cnt,1)>0)+1,tt(cnt,2),tt(cnt,3),lvl} * params.ampF; ...
            events{tt(cnt,2)} / 2]';
        queueOutput(s,sound,params.device);
        cnd = sprintf('COND%d%d%d',tt(cnt,:));
        fprintf(fid,'%04d %s\r',cnt,['00000000 ' cnd]);
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

% save matfile
save(mat,'params','tt','resp');

% compute percent correct
if length(resp)==length(tt)
    pc = sum(resp' == tt(:,1))>0 / length(resp);
else
   pc = sum(resp' == tt(1:length(resp),1))>0 / length(resp); 
end
fprintf('\n\nPERCENT CORRECT: %02.2f\n\n',pc);

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
plotOnline(trialType(:,1),response,runningAverage);
print(f1,sprintf('%s_testing_performance.png',params.fn),'-dpng','-r300');

% and psychometric performance
f2 = figure(2);
l = params.targetDBShift;
psychometricCurve(trialType(:,1),response,l);
title(sprintf('%s Psychometric Curve',params.IDsess));
print(f2,sprintf('%s_testing_curve.png',params.fn),'-dpng','-r300');

