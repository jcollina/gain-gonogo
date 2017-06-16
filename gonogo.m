function gonogo(ID,STAGE,paramFile,condition)
close all
clearvars -except ID STAGE paramFile condition
delete(instrfindall)
dbstop if error

if nargin < 3 || ~exist('paramFile','var');
    paramFile = 'booth1-params.txt';
end
if nargin < 2 || ~exist('STAGE','var')
    STAGE = 0;
end
if nargin < 1 || ~exist('ID','var')
    ID = 'CA999';
end

%% SETUP
% load parameter file for this computer
[params fs] = loadParameters(paramFile);

% setup sound output device
[s,params.fs] = setupSoundOutput(fs,params.device,params.channel);

% directory stuff:
params.IDstr    = ID;
params.IDsess   = [params.IDstr '_' datestr(now,'yymmddHHMM')];
params.base     = pwd;
params.data     = [pwd filesep 'data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.stage    = STAGE;
params.fn       = [params.data filesep params.IDsess];
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
params.dbSteps      = [linspace(5,-15,6)]; %linspace(0,-20,5);
params.dB           = 70 + params.dbSteps;
params.amp70        = .1;
params.toneA        = params.amp70 .* 10 .^ (params.dbSteps./20);
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

% task parameters
params.holdD    = 1.5;
params.respD    = 1.2;
params.timeoutD = 7.0;

% go into task sequence
cnt = 1;
while cnt <= length(STAGE)
    switch STAGE(cnt)
        case 0
            disp('RUNNING HABITUATION');
            habituation(params);
        case 1
            disp('RUNNING TRAINING');
            training(s,params);
        case 2
            disp('RUNNING TESTING');
            testing(s,params);
        case 3
            disp('RUNNING VARIABLE NOISE');
            testingVarOffsets(s,params);
    end
    cnt = cnt + 1;
end

close('all')
clear all