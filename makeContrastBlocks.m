function [stim] = makeContrastBlocks(fs,rs,cs,totalDuration,freqs,amps)

addpath(genpath('~/chris-lab/projects/util/'));

% make a waveform
stim = zeros(1,round(totalDuration * fs));
t = 0:1/fs:totalDuration-(1/fs);
% for each frequency
for i = 1:length(freqs)
    %tic
    %fprintf('FREQ = %g\n',freqs(i));
    % make a waveform
    f = sin(freqs(i)*t*pi*2);
    
    % make an amplitude envelope
    ampEnv = zeros(size(stim));
    for j = 0:size(amps,2)-1
        ind = (j:j+1)*(rs+cs) + [1 0];

        % for the very first and last, don't ramp
        if j == 0 || j == size(amps,2)-1
            tmp = ones(1,rs+cs) * amps(i,j+1);
            ampEnv(ind(1):ind(2)) = tmp;
        else
            tmp = ones(1,cs) * amps(i,j+1);
            ramp = interp1([0 1],[amps(i,j) amps(i,j+1)],linspace(0,1, ...
                                                              rs));
            ampEnv(ind(1):ind(2)) = [ramp tmp];
        end
            
        %fprintf('\tchord %d/%d\n',j,length(amps));
    end
    
    stim = stim + (f .* ampEnv);
    %toc
end

% cosine ramp the start and end
ramp = make_ramp(rs);
ramp = [ramp ones(1,length(stim) - (2*length(ramp))) fliplr(ramp)];
stim = stim .* ramp;

% filter it
