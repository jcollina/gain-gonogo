function [t,trialType,response,RT] = parseLog(fn)

%fn = '.\data\CA075\CA075_1808091412_testing.txt';
% Open the logfile
fid = fopen(fn,'r');
C = textscan(fid,'%s %s %s','headerlines',5);
fclose(fid);
%keyboard
% convert to numeric
trials = cell2mat(cellfun(@str2double,C{1},'un',0));
times = cell2mat(cellfun(@str2double,C{2},'un',0));
event = C{3};

% Get trial indices
x = regexp(event,'TRIAL');
tind = find(~cellfun(@isempty,x));
tind(end+1) = length(x);

% for each trial:
for ii = 1:length(tind)-1
    
    tmpTimes = times(tind(ii):tind(ii+1)-1);
    tmpEvents = event(tind(ii):tind(ii+1)-1);
    
    if ~isempty(tmpTimes) && any(contains(tmpEvents,'TOFF'))
        t(ii).lickTimes = tmpTimes(strcmp(tmpEvents,'LICK'));
        t(ii).trialTimes = [tmpTimes(strcmp(tmpEvents,'TON'))
            tmpTimes(strcmp(tmpEvents,'TOFF'))];
        t(ii).stimTimes = [tmpTimes(strcmp(tmpEvents,'STIMON'))];
        t(ii).respWin = [tmpTimes(strcmp(tmpEvents,'RESPON'))
            tmpTimes(strcmp(tmpEvents,'RESPOFF'))];
        t(ii).rewardTimes = [tmpTimes(strcmp(tmpEvents,'REWARDON'))
            tmpTimes(strcmp(tmpEvents,'REWARDOFF'))];
        t(ii).toStart = [tmpTimes(strcmp(tmpEvents,'TOSTART'))
            tmpTimes(strcmp(tmpEvents,'TOEND'))];
        t(ii).condition = tmpEvents(contains(tmpEvents,'COND'));
%        keyboard
        % important variables
        trialType(ii,:) = str2double(t(ii).condition{1}(end-2:end)')';
        response(ii) = any(t(ii).lickTimes > t(ii).respWin(1) & t(ii).lickTimes < t(ii).respWin(2));
        
        % compute reaction time
        if response(ii)
            RT(ii) = min(t(ii).lickTimes(t(ii).lickTimes > t(ii).respWin(1)) - t(ii).respWin(1))*1e-6;
        else
            RT(ii) = nan;
        end
    end
end