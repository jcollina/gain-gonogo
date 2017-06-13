function [amps, dBs] = makeAmpBlocks(fs,nBlocks,nTones,blockDur,chordDur,baseAmplitude,MU,SD)

% function [amps, dBs] = makeAmpBlocks(fs,nBlocks,nTones,blockDur,chordDur,baseAmplitude,MU,SD)
% Generates an amplitude matrix to make DRCs of low and high contrast

amps = [];
db = [];
for i = 1:nBlocks/2
    for j = 1:2
        % make some dB and amplitude values per frequency
        dBs(i,j,:,:) = unifrnd(MU-SD(j),MU+SD(j),...
                               nTones,blockDur,chordDur);
        amps(i,j,:,:) = baseAmplitude .* 10 .^ ((dBs(i,j,:,:)-70)./20);
    end
end


