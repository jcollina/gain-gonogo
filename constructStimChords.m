function [stimf, events, target, targetF] = constructStimChords(params)
offset = params.noiseD;

% Samples in ramps and chords
rs = params.rampD * params.fs;
cs = (params.chordDuration - params.rampD) * params.fs;

if ~exist(params.stim,'file')
    fprintf('Building stimuli...\n');
    % make the target chord
    [target, targetF] = makeTargetChord(params);
    
    % vector to indicate possible trial level conditions (0 = noise, >0 =
    % target)
    lvls = [nan params.targetDBShift];
    

    %% make stim
    % for each frozen noise pattern
    for i = 1:params.nNoiseExemplars
        % make frozen noise pattern of the maximum length
        blockSamps = round([params.baseNoiseD max(params.noiseD) - params.baseNoiseD + params.postTargetTime] ...
            / params.chordDuration);
        
        % make the noise amplitudes
        [amps, db] = makeDRCAmps(length(blockSamps),params.mu,params.sd,params.nTones,...
            blockSamps,params.amp70);
        
        % for each offset
        for j = 1:length(offset)
            
            % for each amplitude (0 = noise, >0 = target of varying
            % amplitude)
            for k = 1:length(lvls)
                fprintf('Noise patt %02d, offset %1.2f, level %05.2f... ',...
                    i,offset(j) - params.baseNoiseD,lvls(k));
                tic
                
                % shorten noise to include only 1 second after the target
                nsamps = round([params.noiseD(j) + params.postTargetTime] ...
                    / params.chordDuration);
                tmpamp = amps(:,1:nsamps);
                tmpdbs = db(:,1:nsamps);
                
                % make the stimulus
                if ~isnan(lvls(k))
                    % if a target trial, add target to background noise
                    
                    % target offset amplitude
                    chordoff = params.amp70 .* ...
                        10 .^ (((lvls(k)+params.mu)-70)./20);
                    % sample index
                    ind = round((offset(j)+params.chordDuration) / params.chordDuration);
                    
                    % add target to noise
                    tmpamp(:,ind) = amps(:,ind) + (target' .* chordoff);
                    tmpdbs(:,ind) = db(:,ind) + (target' .* lvls(k));
                end
                                    
                % make stimulus
                stim = makeContrastBlocks(params.fs,rs,cs,...
                    nsamps*params.chordDuration,params.freqs,tmpamp);
                stimf{k,j,i} = conv(stim,params.filt,'same');
                DB{k,j,i} = tmpdbs;
                AMPS{k,j,i} = tmpamp;
                
                
                subplot(3,1,1)
                [s,f,t] = spectrogram(stim,2048,512,params.freqs,params.fs,'yaxis');
                imagesc(t,f,abs(s));
                set(gca,'ydir','normal')
                subplot(3,1,2)
                imagesc(tmpamp)
                set(gca,'ydir','normal')
                subplot(3,1,3)
                ts = (1:length(stimf{k,j,i}))/params.fs;
                plot(ts,stimf{k,j,i})
                axis tight
                drawnow
                pause(.1)

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
    tmp(tEnd:tEnd+(pulseWidth*params.fs)) = .5;
    events{i} = tmp;
%     figure;
%     plot([stimf{end,i,5};events{i}]');
%     keyboard
end
