function [t,trialType,response,RT,abort] = parseLog(fn)

%% function [t,trialType,response,RT,abort] = parseLog(fn)

%fn = 'D:\GitHub\gain-gonogo\data\CA046\CA046_1707141235_testing.txt';
% Open the logfile
fid = fopen(fn,'r');
C = textscan(fid,'%s %s %s','headerlines',5);
fclose(fid);

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
        t(i).abort = tmpEvents(contains(tmpEvents,'ABORT'));
                
        % important variables
        if contains(t(i).condition{1},'-')
            tmp = strsplit(t(i).condition{1},'-');
            trialType(i,:) = cell2mat(cellfun(@str2num,tmp(2:end),'un',0));
        else
            trialType(i,:) = str2num(t(i).condition{1}(end-2:end)')';
        end
        if isempty(t(i).abort)
            response(i) = any(t(i).lickTimes > t(i).respWin(1) & t(i).lickTimes < t(i).respWin(2));
            abort(i) = 0;
        else
            response(i) = false;
            abort(i) = 1;
        end
        
        % compute reaction time
        if response(i)
            RT(i) = min(t(i).lickTimes(t(i).lickTimes > t(i).respWin(1)) - t(i).respWin(1))*1e-6;
        else
            RT(i) = nan;
        end
    end
end