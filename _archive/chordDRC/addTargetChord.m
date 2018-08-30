function [amps, db, index, str, events] = addTargetChord(db,target,params)

% index the contrast blocks
fs = 1/params.chordDuration;
blockIdx = repmat([0 1],1,params.nBlocks/2);
a = 1:length(blockIdx);
blockSamps = [a'-1 a'] ...
    .* (fs * params.blockDuration) + repmat([1 0],length(blockIdx),1);

% offsets in samples (chord samples)
offSamps = [nan params.offsets * fs];

cnt = 0;
for i = 1:2
    % randomly select half of this contrast condition
    idx = find(blockIdx == i-1);
    samp = randsample(length(idx),length(offSamps));
    idx = idx(samp);
    
    offsets = offSamps(randperm(length(offSamps)));
    
    % place targets into each block
    for j = 1:length(offsets)
        if ~isnan(offsets(j))
            cnt = cnt + 1;
            ind = blockSamps(idx(j),1)+offsets(j);
            db(:,ind) = db(:,ind) + target';
            % sample index
            sind(1) = ((ind / fs) * params.fs) + 1;
            sind(2) = sind(1) + ((params.chordDuration) * params.fs) - 1;
            sind(3) = sind(1) + ((params.chordDuration + .005) * params.fs) - 1;
            sind = sind - (params.chordDuration * params.fs);
            index(cnt,:) = [sind ind idx(j) offsets(j)*params.chordDuration i-1];
        else
            cnt = cnt + 1;
            index(cnt,:) = [nan nan nan nan idx(j) nan i-1];
        end
    end
end

str = {'rampStartSamps','chordEndSamps','rampEndSamps','chordInd','blockInd',...
    'offsetValue','contrastBlock'};

% convert to amplitudes
amps = params.baseAmplitude .* ...
    10 .^ ((db-70)./20);

%% make events for tones and transitions
% transition events
pulseWidth = .01;
events = zeros(1,params.totalDuration*params.fs);
onsets = ((0:params.blockDuration:params.totalDuration-params.blockDuration) * params.fs) + 1;
for i = 1:length(onsets)
    events(onsets(i):onsets(i)+(pulseWidth*params.fs)) = .5;
end

% target events
for i = 1:size(index,1)
    if ~isnan(index(i,1))
        events(round(index(i,1):index(i,2))) = .5;
    end
end