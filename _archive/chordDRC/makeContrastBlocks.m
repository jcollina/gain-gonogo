function [stim] = makeContrastBlocks(params,amps)

addpath(genpath('~/chris-lab/projects/util/'));

% number of samples in ramps and chords
rs = params.rampDuration * params.fs;
cs = (params.chordDuration - params.rampDuration) * params.fs;

% make a waveform
t1 = tic;
stim = zeros(1,params.totalDuration * params.fs);
t = 0:1/params.fs:params.totalDuration-(1/params.fs);
% for each frequency
for i = 1:length(params.freqs)
    tic
    fprintf('FREQ = %g\n',params.freqs(i));
    % make a waveform
    f = sin(params.freqs(i)*t*pi*2);
    
    % make an amplitude envelope
    ampEnv = zeros(size(stim));
    for j = 0:size(amps,2)-1
        ind = (j:j+1)*(10000) + [1 0];

        % for the very first and last, don't ramp
        if j == 0 | j == size(amps,2)-1
            tmp = ones(1,rs+cs) * amps(i,j+1);
            ampEnv(ind(1):ind(2)) = tmp;
        else
            tmp = ones(1,cs) * amps(i,j+1);
            ramp = interp1([0 1],[amps(i,j) amps(i,j+1)],linspace(0,1, ...
                                                              rs));
            ampEnv(ind(1):ind(2)) = [ramp tmp];
        end
            
        if ~mod(j,1000)
            fprintf('\tchord %d/%d\n',j,length(amps));
        end
    end
    
    stim = stim + (f .* ampEnv);
    toc
end

% cosine ramp the start and end
ramp = make_ramp(params.rampDuration*params.fs);
ramp = [ramp ones(1,length(stim) - (2*length(ramp))) fliplr(ramp)];
stim = stim .* ramp;
toc(t1)

