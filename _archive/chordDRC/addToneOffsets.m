function [tones index] = addToneOffsets(params)

% index the contrast blocks
blockIdx = repmat([0 1],1,params.nBlocks/2);
a = 1:length(blockIdx);
blockSamps = [a'-1 a'] ...
    .* 10000 * 400 + repmat([1 0],length(blockIdx),1);

% offsets in samples
offSamps = params.offsets * params.fs;

% make tone template
amp = params.baseAmplitude .* ...
      10 .^ ((params.toneDB-70)./20);
tone = genTone(params.fs,params.f,...
               params.chordDuration-(2*params.rampDuration),...
               amp,params.rampDuration);

% preallocate a tone stimulus vector
tones = zeros(1,params.totalDuration*params.fs);
cnt = 0;
for i = 1:2
    % randomly select half of this contrast condition
    idx = find(blockIdx == i-1);
    samp = randsample(length(idx),length(params.offsets));
    idx = idx(samp);
    
    offsets = offSamps(randperm(length(offSamps)));
    
    % place tones into each block
    for j = 1:length(offsets)
        cnt = cnt + 1;
        start = blockSamps(idx(j),1)+offsets(j);
        ind = start:(start+params.chordDuration*params.fs)-1;
        tones(ind) = tone;
        index(cnt,:) = [ind(1) ind(end) offsets(j) / params.fs i-1];
    end
end        
    
    
    
    
