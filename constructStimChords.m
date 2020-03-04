function [stimf, events, target, targetF] = constructStimChords(params)
offset = params.noiseD;

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
            for k = 1:length(params.targetDBShift)
            
                fprintf('Noise patt %02d, offset %1.2f, level %05.2f... ',i,offset(j) - params.baseNoiseD,params.targetDBShift(k));
                tic
                
                % make the amplitudes
                rng(i); % this ensures a fixed noise pattern for each exemplar
                blockSamps = round([params.baseNoiseD params.noiseD(j) - params.baseNoiseD + params.postTargetTime] ...
                    / params.chordDuration);
                [amps, db] = makeDRCAmps(length(blockSamps),params.mu,params.sd,params.nTones,...
                    blockSamps,params.amp70);
                                
                % make noise only
                stim = makeContrastBlocks(params.fs,rs,cs,...
                    sum(blockSamps)*params.chordDuration,params.freqs,amps);
                stimf{1,j,i,k} = conv(stim,params.filt,'same');
                DB{1,j,i,k} = db;
                AMPS{1,j,i,k} = amps;
                                
                % add target to noise
                chordoff = params.amp70 .* ...
                    10 .^ ((params.targetDBShift(k)+params.mu-70)./20);
                ind = round((offset(j)+params.chordDuration) / params.chordDuration);
                ampsT = amps;
                ampsT(:,ind) = amps(:,ind) + (target' .* chordoff);
                dbT = db;
                dbT(:,ind) = db(:,ind) + (target' .* params.targetDBShift(k));
                
                % make target stim
                stim = makeContrastBlocks(params.fs,rs,cs,...
                    sum(blockSamps)*params.chordDuration,params.freqs,ampsT);
                stimf{2,j,i,k} = conv(stim,params.filt,'same');
                DB{2,j,i,k} = dbT;
                AMPS{2,j,i,k} = ampsT;
                
                
%                 if k == 6
%                     %ts = (1:length(stimf{2,j,i,k}))/params.fs;
%                     %plot(ts,stimf{2,j,i,k})
%                     subplot(3,1,1)
%                     spectrogram(stimf{2,j,i,k},2048,512,params.freqs,params.fs,'yaxis')
%                     subplot(3,1,2)
%                     imagesc(ampsT)
%                     colorbar
%                     subplot(3,1,3)
%                     ts = (1:length(stimf{2,j,i,k}))/params.fs;
%                     plot(ts,stimf{2,j,i,k})
%                     keyboard
%                 end
                toc
            end
        end
    end
    fprintf('Saving stimuli as %s\n', params.stim);
    save(params.stim,'params','stimf','target','targetF','DB','AMPS');
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
    tmp(tEnd:tEnd+(pulseWidth*2*params.fs)) = .5;
    events{i} = tmp;
    %figure;
    %plot([stimf{2,i,1,6};events{i}]');
    %keyboard
end
