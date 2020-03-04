function testing(params)

KbName('UnifyKeyNames');
dbstop if error
delete(instrfindall)

% Load corresponding Arduino sketch
hexPath = [params.hex filesep 'testingWithOutput.ino.hex'];
[~, cmdOut] = loadArduinoSketch(params.comPort,hexPath);
cmdOut
disp('STARTING SERIAL');
s = setupSerial(params.comPort);
n = params.n;

% Open text file
fileGoto = [params.fn '_testing.txt'];
fn = fopen(fileGoto,'w');

%Send setup() variables to arduino
varvect = [params.holdD params.rewardD params.respD params.timeoutD];
fprintf(s,'%f %f %f %f ',varvect);

% Make stimuli
Fs = params.fsActual;
f = params.toneF;
sd = params.toneD;
samp = params.toneA;
namp = params.noiseA;
rd = params.rampD;
offset = params.noiseD;
offProbs = [.2 .2 .2 .2 .2];
dbProbs = [.4 .2 .2 .05 .05 .05 .05];

constructStim;

% modify params to reflect actual stimuli used
params.offProbs = offProbs;
params.saProbs = dbProbs;
params.offset = offset;

disp(' ');
disp('Press any key to start TESTING...');
disp(' ');
pause;


% Preallocate some variables
t                   = 0;
ts                  = {};
timeoutState        = 0;
rewardState         = 0;
taskState           = 0;
lickCount           = [];
disp(' ');
%%Task
while 1
    
    switch taskState
        
        case 0 %proceed when arduino signals (2s no licks)
            t = t + 1;
            lickCount = 0;
            
            if t ~= 1
                fprintf(' Waiting %g seconds with no licks to proceed...\n',params.holdD)
            end
            
            while 1
                if s.BytesAvailable > 0
                    ardOutput = fscanf(s,'%c');
                    ts(t).trialstart = str2num(ardOutput(1:end-2));
                    taskState = 1;
                    break
                end
            end
            
        case 1 %generate random stimuli
            % choose a random DRC pattern and offset
            pattChoice = randi(size(noise,2));
            
            % random number to determine trial type
            num = rand;
            
            % Choose duration
            intd = [0 cumsum(offProbs)];
            d = discretize(num,intd,'IncludedEdge','right');
            
            %Choose Signal Strength
            intl = [intd(d) intd(d) + (offProbs(d).*cumsum(dbProbs))];
            l = discretize(num,intl,'IncludedEdge','right');
            
            trialType(t,:) = [(l-1) d pattChoice];
            
            %Prevent more than three trial or noise signals in a row
            tlvl(t) = trialType(t,1);
            tdur(t) = trialType(t,2);
            
            if t > 4
                if all(tlvl(end-3:end) == 0)
                    intx = [0 cumsum(ones(1,length(intl)-2) / (length(intl)-2))];
                    trialType(t,1) = discretize(rand,intx,'IncludedEdge','right');
                    tlvl(t) = trialType(t,1);
                end
                if all(tlvl(end-3:end) > 0);
                    trialType(t,1) = 0;
                    tlvl(t) = trialType(t,1);
                end
                if range(tdur(end-3:end)) == 0 && length(offset) > 1
                    inty = [0 cumsum(ones(1,length(offset) - 1) / (length(offset) - 1))];
                    trialType(t,2) = discretize(rand,inty,'IncludedEdge','right') + 1;
                    tdur(t) = trialType(t,2);
                end
            end
            
            if trialType(t,1) == 0
                %Noise
                fprintf(s,'%i',0);
                queueOutputData(n,...
                    [noise{trialType(t,2),trialType(t,3)}'*10 ...
                    events{trialType(t,2)}'*5]);
                fprintf('%03d %d %d %d %s NOISE_TRIAL\n',t,...
                    trialType(t,1),trialType(t,2),trialType(t,3),...
                    ardOutput(1:end-2));
                startForeground(n)
                taskState = 2;
            else
                %Signal
                fprintf(s,'%i',1);
                queueOutputData(n,...
                    [(noise{trialType(t,2),trialType(t,3)} + ...
                    (tone{trialType(t,2)} * samp(trialType(t,1))))' * 10 ...
                    events{trialType(t,2)}'*5]);
                fprintf('%03d %d %d %d %s SIGNAL_TRIAL\n',t,...
                    trialType(t,1),trialType(t,2),trialType(t,3),...
                    ardOutput(1:end-2));
                startForeground(n)
                taskState = 2;
            end
            
        case 2 %Interpret Arduino Output for Display
            
            ardOutput = fscanf(s,'%c');
            if ardOutput(1) == 'L'
                fprintf('%03d %d %d %d %s LICK\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ardOutput(2:end-2))
                lickCount = lickCount + 1;
                ts(t).lick(lickCount) = str2double(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %d %010d LICK\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).lick(lickCount));
            elseif ardOutput(1) == 'R'
                fprintf('%03d %d %d %d %d %s REWARD\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ardOutput(2:end-2))
                ts(t).rewardstart = str2num(ardOutput(2:end-2));
                rewardState = 1;
                fprintf(fn,'%03d %d %d %d %010d REWARD_START\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).rewardstart);
            elseif ardOutput(1) == 'W'
                ts(t).rewardend = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %d %010d REWARD_END\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).rewardend);
            elseif ardOutput(1) == 'T'
                if timeoutState ~= 1
                    fprintf('%03d %d %d %d %d %s TIMEOUT\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ardOutput(2:end-2))
                    timeoutState = 1;
                end
                ts(t).timeoutstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %d %010d TIMEOUT_START\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).timeoutstart);
            elseif ardOutput(1) == 'S'
                ts(t).stimstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %d %010d STIM_START\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).stimstart);
            elseif ardOutput(1) == 'O'
                ts(t).stimend = str2num(ardOutput(2:end-2));
                ts(t).respstart = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %d %010d STIM_END_RESP_START\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).stimend);
            elseif ardOutput(1) == 'C'
                fprintf('    %g Lick(s) Detected...',lickCount)
                ts(t).respend = str2num(ardOutput(2:end-2));
                fprintf(fn,'%03d %d %d %d %010d RESP_END\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).respend);
                taskState = 3;
            end
            
        case 3 %Timeout, Reward
            while timeoutState == 1
                ardOutput = fscanf(s,'%c');
                if ardOutput(1) == 'T'
                    ts(t).timeoutstart = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %d %d %d %010d TIMEOUT_START\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).timeoutstart);
                elseif ardOutput(1) == 'Q'
                    ts(t).timeoutend = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %d %d %d %010d TIMEOUT_END\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).timeoutend);
                    timeoutState = 0;
                    break
                end
            end
            while rewardState == 1
                ardOutput = fscanf(s,'%c');
                if ardOutput(1) == 'W'
                    ts(t).rewardend = str2num(ardOutput(2:end-2));
                    fprintf(fn,'%03d %d %d %d %010d REWARD_END\n',t,trialType(t,1),trialType(t,2),trialType(t,3),ts(t).rewardend);
                    rewardState = 0;
                    break
                end
            end
            taskState = 4;
            
        case 4 %End Trial
            if n.IsRunning == 1
                stop(n)
            end
            taskState = 0;
    end
    
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE');
            disp('User exit...');
            break
        end
    end
    if t > 1000
        disp('Max trials reached...');
        break;
    end
end

if t > 50
    save(sprintf('%s_testing.mat',params.fn),'ts','trialType','params');
    [f,pC] = plotPerformance(ts,trialType);
    [h,~] = Psychometric_Curve_CA(ts,trialType,params);
    fprintf('%g%% CORRECT\n',pC*100);
    print(f,sprintf('%s_performance.png',params.fn),'-dpng','-r300');
    print(h,sprintf('%s_psychCurve.png',params.fn),'-dpng','-r300');
end
fclose(fn);
delete(s);
pause

