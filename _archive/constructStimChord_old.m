function [tone, noise, events] = constructStimChord(params)

Fs = params.fs;
f = params.toneF;
sd = params.toneD;
samp = params.toneA;
namp = params.noiseA;
rd = params.rampD;
offset = params.noiseD;

% Samples in ramps and chords
rs = params.rampD * params.fs;
cs = (params.chordDuration - params.rampD) * params.fs;

if ~exist(params.stim,'file')
    fprintf('Building stimuli...\n');
    % make stim
    for i = 1:params.nNoiseExemplars
        for j = 1:length(offset)
            % make the amplitudes
            blockSamps = [params.baseNoiseD params.noiseD(j) - params.baseNoiseD + params.postTargetTime] ...
                / params.chordDuration;
            [amps, db] = makeDRCAmps(length(blockSamps),params.mu,params.sd,params.nTones,...
                blockSamps,params.amp70);
            
            % make noise only
            noise{i,j} = makeContrastBlocks(params.fs,rs,cs,...
                sum(blockSamps)*params.chordDuration,params.freqs,amps);
            
            keyboard
            
            % make a target chord by choosing several values between each
            % octave
            octs = [4*1e3 .* 2 .^ (0:3) max(params.freqs)];
            nchoices = [5 5 5 2];
            target = zeros(1,length(params.freqs));
            for k = 1:length(nchoices)
                % choose n between each bound
                ind(1) = find(params.freqs == octs(k));
                ind(2) = find(params.freqs == octs(k+1));
                ind = ind(1):ind(2);
                
                % choose n items separated by 1/5 octave
                cnt = 0;
                while 1
                    cnt = cnt + 1;
                    freq = randperm(length(ind)-1,nchoices(k));
                    if ~any(diff(sort(freq))<=1) || isempty(diff(freq))
                        break;
                    end
                end
                length(freq)
                fprintf('%d iterations\n',cnt);
                
                % build target variable
                target(ind(freq)) = params.targetDBShift;
            end
            params.targetFreqs = params.freqs(target>0);
            params.target = target;
            keyboard
            
        end
    end
    
    % make DRCs
    
    for i = 1:length(offset)
        for j = 1:params.nNoiseExemplars
            [noise{i,j}] = makeDRC_target(Fs,rd,params.chordDuration,offset(i),...
                params.freqs,params.mu,params.sd,params.amp70, ...
                params.filt);
        end
    end
    fprintf('Done\n');
    fprintf('Saving stimuli as %s ', params.stim);
    save(params.stim,'params','noise','tone');
    fprintf(' done\n');
else
    % load it
    fprintf('Loading %s...', params.stim);
    a=load(params.stim);
    noise = a.noise;
    tone = a.tone;
    clear a;
    fprintf(' done\n');
end

% make events
pulseWidth = .005;
for i = 1:size(tone,2)
    tmp = zeros(1,length(tone{i}));
    tEnd = round((offset(i)+params.toneD) * Fs);
    tmp(1:pulseWidth*Fs) = 1;
    tmp(tEnd:tEnd+(pulseWidth*Fs)) = 1;
    events{i} = tmp;
end