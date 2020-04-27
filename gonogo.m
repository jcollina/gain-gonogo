function gonogo(ID,STAGE,paramFile,condition)
close all
clearvars -except ID STAGE paramFile condition
delete(instrfindall)
dbstop if error

if nargin < 4 || ~exist('condition','var')
    condition = 'hilo';
end
if nargin < 3 || ~exist('paramFile','var');
    paramFile = 'booth1-params.txt';
end
if nargin < 2 || ~exist('STAGE','var')
    STAGE = 0;
end
if nargin < 1 || ~exist('ID','var')
    ID = 'CA999';
end

addpath(genpath('_analysis'));
addpath(genpath('_task'));
addpath(genpath('_thresholds'));


%% SETUP
% load parameter file for this computer
[params fs] = loadParameters(fullfile('_params',paramFile));

% setup sound output device
[s,params.fs] = setupSoundOutput(fs,params.device,params.channel);

% directory stuff:
params.IDstr    = ID;
params.base     = pwd;
params.data     = [pwd filesep '_data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.stage    = STAGE;
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
if strcmp(condition,'lohi')
    params.sd = [5 15];
elseif strcmp(condition,'hilo')
    params.sd = [15 5];
end
params.contrastCondition = condition;
params.stimVersion = '200406';
params.chordDuration = .025;
params.nNoiseExemplars = 5;
params.postTargetTime = 1;

% task parameters
params.holdD    = 1.5;
params.respD    = 1.2;
params.timeoutD = 10.0;

% go into task sequence
cnt = 1;
while cnt <= length(STAGE)
    switch STAGE(cnt)
        case -1
            disp('RUNNING LICK TUBE PRIMING')
            prime(params);
            
        case 0
            disp('RUNNING HABITUATION');
            habituation(params);
            
        case 1
            disp('RUNNING TRAINING');
            training(s,params);
            
        case 10
            disp('RUNNING TRAINING W. ABORT');
            training_abort(s,params);
            
        case 2
            disp('RUNNING TESTING');
            psych(s,params);
            
        case 20
            disp('RUNNING TESTING W. ABORT');
            params.targetDBShift = linspace(0,25,6); % target volumes
            params.offsetP = [.25 .25 .25 .25];      % target time probabilities
            params.dbP = [.4 .05 .05 .05 .05 .2 .2]; % target volume probabilities
            params.rewCont = [0 2 2 2 2 1 1];        % reward contingency (0=timeout,1=reward,2=noreward)
            params.stimLabel = 'testing';
            
            psych_abort(s,params);
            
        case 21
            disp('RUNNING TESTING W. OPTO');
            params.opto = true;
            psych_opto_abort(s,params);
            
        case 22
            disp('RUNNING PSYCH - WIDE RANGE');
            params.targetDBShift = [linspace(0,25,6) 30]; % target volumes
            params.offsetP = [.25 .25 .25 .25];      % target time probabilities
            params.dbP = [.4 .05 .05 .05 .05 .05 .05 .3];     % target volume probabilities
            params.rewCont = [0 2 2 2 2 2 2 1];        % reward contingency (0=timeout,1=reward,2=noreward)
            params.stimLabel = 'testingWide';
            
            psych_abort(s,params);
            
        case 23
            disp('RUNNING PSYCH - NARROW RANGE');
            params.targetDBShift = [linspace(0,25,6) 30]; % target volumes
            params.offsetP = [.25 .25 .25 .25];      % target time probabilities
            params.dbP = [.4 .05 .05 .05 .05 .05 .05 .3];     % target volume probabilities
            params.rewCont = [0 2 2 2 2 2 2 1];        % reward contingency (0=timeout,1=reward,2=noreward)
            params.stimLabel = 'testingNarrow';
            
            psych_abort(s,params);
            
        case 3
            disp('RUNNING OFFSET TESTING');
            offsets(s,params);
            
        case 30
            disp('RUNNING OFFSET TESTING W. ABORT');
            offsets_abort(s,params);
            
        case 31
            disp('RUNNING THRESHOLD-OPTO TESTING');
            threshold_opto_abort(s,params);
            
        case 5
            disp('RUNNING STAIRCASE');
            staircase(s,params);
            
    end
    cnt = cnt + 1;
end

close('all')
close all
clear all 