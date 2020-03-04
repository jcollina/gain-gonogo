paramFile = 'booth1-params.txt';
[params params.fs] = loadParameters(paramFile);
params.filtdir  = '~/Documents/GitHub/filters';
condition = 'hilo';

%% PARAMETERS
% stimulus parameters
params.seed         = 1989;
params.filt         = load([params.filtdir filesep params.filtFile]);
params.filt         = params.filt.FILT;
params.baseNoiseD   = 3;
params.amp70        = .1;
params.noiseA       = 1;
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

params.noiseD = params.baseNoiseD + [.05 .1 .25 .5 1];
rng(params.seed); % (to make the same stimulus each time)
if params.sd(2) - params.sd(1) > 0
    params.stim = ['~/stimuli/gainBehavior/170629_testingLoHiChord-' params.boothID '.mat'];
    params.targetDBShift = linspace(0,20,6);
else
    params.stim = ['~/stimuli/gainBehavior/170629_testingHiLoChord-' params.boothID '.mat'];
    params.targetDBShift =linspace(-10,10,6);
end

constructStimChords(params)