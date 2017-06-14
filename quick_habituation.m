function quick_habituation(ID,paramFile)

close all
clearvars -except ID STAGE paramFile
delete(instrfindall)
dbstop if error

if nargin < 2 || ~exist('paramFile','var');
    paramFile = 'booth22-params.txt';
end
if nargin < 1 || ~exist('ID','var')
    ID = 'CA999';
end

%% SETUP
% load parameter file for this computer
[params fs] = loadParameters(paramFile);

% directory stuff:
params.IDstr    = ID;
params.IDsess   = [params.IDstr '_' datestr(now,'yymmddHHMM')];
params.base     = pwd;
params.data     = [pwd filesep 'data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.fn       = [params.data filesep params.IDsess];
params.filtdir  = 'C:\Users\geffen-behaviour2\Documents\GitHub\filters';

% task parameters
params.holdD    = 1.5;
params.respD    = 1.2;
params.timeoutD = 7.0;

disp('RUNNING HABITUATION');
habituation(params);

