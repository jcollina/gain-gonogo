function [t,trialType,response] = parseLog(fn)

%fn = 'D:\GitHub\gain-gonogo\data\CA046\CA046_1707141235_testing.txt';
% Open the logfile
fid = fopen(fn,'r');
C = textscan(fid,'%s %s %s','headerlines',5);
fclose(fid);

% load the parameters for computing trial timing
load([fn(1:end-4) '.mat']);
offsets = params.noiseD - params.baseNoiseD;

% convert to numeric
trials = cell2mat(cellfun(@str2num,C{1},'un',0));
times = cell2mat(cellfun(@str2num,C{2},'un',0));
events = C{3};

% Get trial indices
x = regexp(events,'TRIAL');
tind = find(~cellfun(@isempty,x));
tind(end+1) = length(x);

% for each trial:
for i = 1:length(tind)-1
    tmpTimes = times(tind(i):tind(i+1)-1);
    tmpEvents = events(tind(i):tind(i+1)-1);
    
    if ~isempty(tmpTimes) && any(contains(tmpEvents,'TOFF'))
        t(i).lickTimes = tmpTimes(strcmp(tmpEvents,'LICK'));
        t(i).trialTimes = [tmpTimes(strcmp(tmpEvents,'TON'))
            tmpTimes(strcmp(tmpEvents,'TOFF'))];
        t(i).stimTimes = [tmpTimes(strcmp(tmpEvents,'STIMON'))];
        t(i).respWin = [tmpTimes(strcmp(tmpEvents,'RESPON'))
            tmpTimes(strcmp(tmpEvents,'RESPOFF'))];
        t(i).rewardTimes = [tmpTimes(strcmp(tmpEvents,'REWARDON'))
            tmpTimes(strcmp(tmpEvents,'REWARDOFF'))];
        t(i).toStart = [tmpTimes(strcmp(tmpEvents,'TOSTART'))
            tmpTimes(strcmp(tmpEvents,'TOEND'))];
        t(i).condition = tmpEvents(contains(tmpEvents,'COND'));
        
        % important variables
        str = t(i).condition{1};
        if length(str) == 8
            trialType(i,1) = str2num(str(5));
            trialType(i,2) = str2num(str(6));
            trialType(i,3) = str2num(str(7:8));
        else
            trialType(i,:) = str2num(t(i).condition{1}(end-2: ...
                                                       end)')';
        end
        
        % get transition time (event is accurate to the
        % target time, but the actual target offset is a chord too
        % early, so it is offset by 20ms)
        t(i).transition = t(i).respWin(1) - offsets(trialType(i,2))*1e6 ...
            + params.chordDuration*1e6 - params.rampD*1e6;
        
        % responses count as any licks AFTER the transition and
        % during the window
        response(i) = any(t(i).lickTimes > t(i).transition & t(i).lickTimes < t(i).respWin(2));
        
        % compute reaction time
        if response(i)
            t(i).firstLick = min(t(i).lickTimes(t(i).lickTimes > t(i).transition) - t(i).transition)*1e-6;
            t(i).RT = min(t(i).lickTimes(t(i).lickTimes > t(i).transition) - t(i).respWin(1))*1e-6;
        else
            t(i).firstLick = nan;
            t(i).RT = nan;
        end
    end
end
