function trainingPlot(fileList,fileInd)

% load all the trial info
keyboard

for s = 1:length(fileList)
    % load the data
    fn = [fileList{s}(1:end-4) '.txt'];
    load(fileList{s})
    [t,trialType,response,RT] = parseLog(fn);

    offsets = params.noiseD - params.baseNoiseD;

    % sort trial number by offset time and S vs N
    [~,ind] = sortrows(trialType,[2 1]);

    % IMPORTANT NOTE: response window event starts at the END of the
    % ramping period up to the target, so 5ms after the start of the
    % target

    % OBSERVATION: the actual timing of the start event to the target
    % onset (response window) is off by 20ms???? WTF? (corresponds to
    % the debounce delay... it's probably because it checks the
    % lickport for that long each time, but I'm not sure why that would
    % cause it to be 20ms early?)
    %
    % Additional thought on this: is it because the target is added
    % to the chords, so it may be off by near the chord duration?
    % this makes sense: if you shift the event forward by the ramp
    % duration, as noted above, it would be exactly 25ms early, so
    % we are just putting the chord slightly too soon

    % loop through trials and plot relevant parameters (timing relative
    % to response window onset)
    hold on
    for i = 1:length(ind)
        targetTime = t(ind(i)).respWin(1);
        lickTimes = t(ind(i)).lickTimes - targetTime;
        lickTimes = lickTimes(lickTimes/1e6 > -4 & lickTimes/1e6 < 2);
        transitionTime = targetTime - (params.rampD*1e6) - ...
            (offsets(trialType(ind(i),2))*1e6) - targetTime;
        targetLickInd = lickTimes > 0 & ...
            lickTimes <= params.respD*1e6;
        respLicks = lickTimes(targetLickInd);
        okLicks = lickTimes(lickTimes > (t(ind(i)).stimTimes - targetTime) & ...
                            lickTimes < transitionTime);
        badLicks = lickTimes(lickTimes > (transitionTime) & ...
                             lickTimes < 0);
        
        line([transitionTime transitionTime]'/1e6,[i i+1]',...
             'Color',[0 1 0],'LineWidth',3);
        line([lickTimes lickTimes]'/1e6, repmat([i i+1],length(lickTimes),1)',...
             'Color',[.5 .5 .5],'LineWidth',2);
        if ~isempty(respLicks)
            line([respLicks respLicks]'/1e6, repmat([i i+1],length(respLicks),1)',...
                 'Color',[0 0 1],'LineWidth',2);
        end
        if ~isempty(okLicks)
            line([okLicks okLicks]'/1e6, repmat([i i+1],length(okLicks),1)',...
                 'Color',[.5 .5 .5],'LineWidth',2);
        end
        if ~isempty(badLicks)
            line([badLicks badLicks]'/1e6, repmat([i i+1],length(badLicks),1)',...
                 'Color',[1 0 0],'LineWidth',2);
        end
        plot([0 0],[1 length(ind)],'k--','LineWidth',2)
    end
end

keyboard
    
        
    