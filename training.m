function training(s,params)
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

% construct the stimuli
params.noiseD = params.baseNoiseD + [.25 .5 .75 1];

if params.sd(2) - params.sd(1) > 0
    params.stim = ['D:\stimuli\gainBehavior\190129_trainingLoHiChord-' params.boothID '-dual.mat'];
    params.targetDBShift = 20;
else
    params.stim = ['D:\stimuli\gainBehavior\190129_trainingHiLoChord-' params.boothID '-dual.mat'];
    params.targetDBShift = 16;
end
[stim, events, params.target, params.targetF] = constructStimChords(params);
rng('shuffle');

% modify params to reflect actual stimuli used

% graph title
tstr = [params.boothID ': ' params.IDstr];

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
        tt(cnt,3) = randi(size(stim,3),1);
                
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
        % make sure we're ready for the next trial
        if strcmp(params.device,'NIDAQ') || contains(params.device,'Lynx E44')
            if s.ScansQueued > 0
                stop(s);
            end
        end
        % plot the stuff
        plotOnline(tt,resp,runningAverage,tstr);
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
