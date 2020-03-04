% make quick psych curve
% load parameter file for this computer
paramFile = 'ephysBooth-params.txt';
[params fs] = loadParameters(paramFile);

% setup sound output device
params.fs = fs;

% directory stuff:
params.IDstr    = 'CA123';
params.base     = pwd;
params.data     = [pwd filesep 'data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.filtdir  = 'D:\GitHub\filters';
if ~exist(params.data,'dir')
    mkdir(params.data);
end
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end

%% PARAMETERS
% stimulus parameters
params.seed         = 1989;
params.filt         = load([params.filtdir filesep params.filtFile]);
params.filt         = params.filt.FILT;
params.toneF        = 15e3;
params.baseNoiseD   = 3;
params.amp70        = .1;
params.rampD        = .005;
%params.nTones       = 34;
%params.freqs        = 4e3 * (2 .^ (([0:params.nTones-1])/10)); % this is n freqs spaced 1/6 octave apart
params.nTones       = 33;
params.freqs        = 4e3 * (2 .^ (([0:params.nTones-1])/8));
params.mu           = 50;

params.stimVersion = '101504';
params.chordDuration = .025;
params.nNoiseExemplars = 5;
params.postTargetTime = 1;

% task parameters
params.holdD    = 1.5;
params.respD    = 1.2;
params.timeoutD = 10.0;

params.noiseD = params.baseNoiseD + [.25 .5 .75 1];

% make lo-hi
params.stim = 'D:\stimuli\gainBehavior\ephys_lohi.mat';
params.targetDBShift = linspace(0,25,6);
params.sd = [5 15];
[stimf, events, target, targetF] = constructStimChords(params);

% make hi-lo
params.stim = 'D:\stimuli\gainBehavior\ephys_hilo.mat';
params.targetDBShift = linspace(-5,20,6);
params.sd = [15 5];
[stimf, events, target, targetF] = constructStimChords(params);

