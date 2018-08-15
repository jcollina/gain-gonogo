function [stimf, event, target, targetF] = constructStimChordTraining(params,s)

offset = params.noiseD;


%rng(params.seed); % (to make the same stimulus each time)
rand("seed",params.seed);

% Samples in ramps and chords
rs = params.rampD * params.fs;
cs = (params.chordDuration - params.rampD) * params.fs;

if ~exist(params.stim,'file')
    fprintf('Building stimuli...\n');
    % make the target chord
    [target, targetF] = makeTargetChord(params);
    
    % make stim
    for i = 1:params.nNoiseExemplars
        for j = 1:length(offset)
            fprintf('Noise patt %02d, offset %1.2f... ',i,offset(j) - params.baseNoiseD);
            tic

            % make the amplitudes
            blockSamps = [params.baseNoiseD params.noiseD(j) - params.baseNoiseD + params.postTargetTime] ...
                / params.chordDuration;
            [amps, db] = makeDRCAmps(length(blockSamps),params.mu,params.sd,params.nTones,...
                blockSamps,params.amp70);
            
            % make noise only
            stim = makeContrastBlocks(params.fs,rs,cs,...
                sum(blockSamps)*params.chordDuration,params.freqs,amps);
            stimf{1,j,i} = conv(stim,params.filt,'same');
                        
            % add target to noise
            chordoff = params.amp70 .* ...
                10 .^ ((params.targetDBShift+params.mu-70)./20);
            ind = round((offset(j)+params.chordDuration) / params.chordDuration);
            ampsT = amps;
            ampsT(:,ind) = amps(:,ind) + (target' .* chordoff);
            
            % make target stim
            stim = makeContrastBlocks(params.fs,rs,cs,...
                sum(blockSamps)*params.chordDuration,params.freqs,ampsT);
            stimf{2,j,i} = conv(stim,params.filt,'same');
            toc            
        end
    end
    fprintf('Saving stimuli as %s\n', params.stim);
    save('-v6',params.stim,'params','stimf','target','targetF','amps','ampsT');
else
    % load it
    fprintf('Loading %s...', params.stim);
    load(params.stim);
    clear a;
    fprintf(' done\n');
end

% make events
pulseWidth = params.rampD;
for i = 1:size(stimf,2)
    tmp = zeros(1,length(stimf{1,i,1}));
    tEnd = round((offset(i)) * params.fs);
    tmp(1:pulseWidth*params.fs) = .5;
    tmp(tEnd:tEnd+(pulseWidth*params.fs)) = .5;
    event{i} = tmp;
    %plot([stimf{2,i,1};events{i}]');
    %keyboard
end

rand("seed",(round(rand*1e6)));
