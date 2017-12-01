function [stimf, events, target, targetF] = constructStimulus(params,index)

condition = 'hilo';
paramFile = 'booth1-params-dual.txt';
STAGE = 0;
ID = 'CA999';

%% SETUP
% load parameter file for this computer
[params fs] = loadParameters(paramFile);

% directory stuff:
params.IDstr    = ID;
params.IDsess   = [params.IDstr '_' datestr(now,'yymmddHHMM')];
params.base     = pwd;
params.data     = [pwd filesep 'data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.stage    = STAGE;
params.fn       = [params.data filesep params.IDsess];
params.filtdir  = '~/gits/filters';
if ~exist(params.data,'dir')
    mkdir(params.data);
end
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end

%% PARAMETERS
% stimulus parameters
params.fs = 400e3;
params.seed         = 1989;
params.filt         = load([params.filtdir filesep params.filtFile]);
params.filt         = params.filt.FILT;
params.toneF        = 15e3;
params.baseNoiseD   = 3;
params.amp70        = .1;
params.rampD        = .005;
params.nTones       = 34;
params.freqs        = 4e3 * (2 .^ (([0:params.nTones-1])/10)); % this is n freqs spaced 1/6 octave apart
params.mu           = 50;
if strcmp(condition,'lohi')
    params.sd = [5 15];
elseif strcmp(condition,'hilo')
    params.sd = [15 5];
end
params.chordDuration = .025;
params.nNoiseExemplars = 5;
params.postTargetTime = 1;

% task parameters
params.holdD    = 1.5;
params.respD    = 1.2;
params.timeoutD = 7.0;

% construct the stimuli
params.noiseD = params.baseNoiseD + [.33 .66 1];
if params.sd(2) - params.sd(1) > 0
    params.stim = ['D:\stimuli\gainBehavior\170927_LoHiChord-' params.boothID '-dual.mat'];
    params.targetDBShift = linspace(8,20,6);
else
    params.stim = ['D:\stimuli\gainBehavior\170927_HiLoChord-' params.boothID '-dual.mat'];
    params.targetDBShift =linspace(-4,16,6);
end

index{1} = logical([1 1 1]);
index{2} = logical([1 1 1 1 1]);
index{3} = logical([0 0 0 0 0 1]);

% make a stimulus library
rng(params.seed);

if ~exist(params.stim,'file')
    offset = params.noiseD;

    % Samples in ramps and chords
    rs = params.rampD * params.fs;
    cs = (params.chordDuration - params.rampD) * params.fs;
    
    % make stim
    for i = 1:params.nNoiseExemplars
        % make the amplitudes for each type of noise pattern
        blockSamps = round([params.baseNoiseD max(params.noiseD) - params.baseNoiseD + params.postTargetTime] ...
                           / params.chordDuration);
        [amps{i}, db{i}] = makeDRCAmps(length(blockSamps),params.mu,params.sd,params.nTones,...
                             blockSamps,params.amp70);
        for j = 1:length(offset)
            for k = 1:length(params.targetDBShift)
            fprintf('Noise patt %02d, offset %1.2f, level %02d... ',i,offset(j) - ...
                    params.baseNoiseD,params.targetDBShift(k));
            tic
            
            % extract only amps needed for this offset
            ampMat = amps{i}(:,1:round((offset(j)+params.postTargetTime) ...
                                     / params.chordDuration));
            
            % make the target chord
            [target, targetF] = makeTargetChord(params);
            
            % make noise only
            stim = makeContrastBlocks(params.fs,rs,cs,...
                size(ampMat,2)*params.chordDuration,params.freqs,ampMat);
            stimf{1,j,i,k} = conv(stim,params.filt,'same');
                        
            % add target to noise
            chordoff = params.amp70 .* ...
                10 .^ ((params.targetDBShift(k)+params.mu-70)./20);
            ind = round(offset(j) / params.chordDuration);
            ampsT = ampMat;
            ampsT(:,ind) = ampsT(:,ind) + (target' .* chordoff);
                        
            % make target stim
            stim = makeContrastBlocks(params.fs,rs,cs,...
                size(ampMat,2)*params.chordDuration,params.freqs,ampsT);
            stimf{2,j,i,k} = conv(stim,params.filt,'same');
            toc
            end
        end
    end
    fprintf('Saving stimuli as %s\n', params.stim);
    save(params.stim,'params','stimf','target','targetF','amps', ...
         'ampsT','-v7.3');
    
    % index them for current experiment
    stim1 = stimf(:,index{1},index{2},index{3});
else
    % load it
    fprintf('Loading %s...', params.stim);
    matfile(params.stim);
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






