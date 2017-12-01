function [stimf, events, target, targetF] = constructStimChords(params)
offset = params.noiseD;

% Samples in ramps and chords
rs = params.rampD * params.fs;
cs = (params.chordDuration - params.rampD) * params.fs;

if ~exist(params.stim,'file')
    fprintf('Building stimuli...\n');
    % make stim
    for i = 1:params.nNoiseExemplars
        for j = 1:length(offset)
            for k = 1:length(params.targetDBShift)
            fprintf('Noise patt %02d, offset %1.2f, level %02d... ',i,offset(j) - params.baseNoiseD,params.targetDBShift(k));
            tic
            
            % make the target chord
            [target, targetF] = makeTargetChord(params);

            % make the amplitudes
            blockSamps = round([params.baseNoiseD params.noiseD(j) - params.baseNoiseD + params.postTargetTime] ...
                / params.chordDuration);
            [amps, db] = makeDRCAmps(length(blockSamps),params.mu,params.sd,params.nTones,...
                blockSamps,params.amp70);
            
            % make noise only
            stim = makeContrastBlocks(params.fs,rs,cs,...
                sum(blockSamps)*params.chordDuration,params.freqs,amps);
            stimf{1,j,i,k} = conv(stim,params.filt,'same');
                        
            % add target to noise
            chordoff = params.amp70 .* ...
                10 .^ ((params.targetDBShift(k)+params.mu-70)./20);
            ind = round(offset(j) / params.chordDuration);
            ampsT = amps;
            ampsT(:,ind) = amps(:,ind) + (target' .* chordoff);
            
            % make target stim
            stim = makeContrastBlocks(params.fs,rs,cs,...
                sum(blockSamps)*params.chordDuration,params.freqs,ampsT);
            stimf{2,j,i,k} = conv(stim,params.filt,'same');
            toc
            end
        end
    end
    fprintf('Saving stimuli as %s\n', params.stim);
    save(params.stim,'params','stimf','target','targetF','amps','ampsT');
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
    tEnd = round((offset(i)-params.chordDuration) * params.fs);
    tmp(1:pulseWidth*params.fs) = 1;
    tmp(tEnd:tEnd+(pulseWidth*params.fs)) = 1;
    events{i} = tmp;
    %figure;
    %plot([stimf{2,i,1,6};events{i}]');
end
