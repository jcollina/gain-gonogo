function genDRC
close all
clear
addpath('C:\Users\Chris\Documents\chris-lab\projects\util\');
addpath('C:\Users\Chris\Documents\GitHub\Kath\contrastGainStim_chris\');

% this script makes DRC stimuli of varying contrast. it does this
% for each timestep by pulling samples from a random distribution
% to determine the level for each frequency band. then, makes pure
% tones at each band, scaling them by the appropriate level. 5ms
% linear ramps are inserted between each chord transition to
% prevent acoustic distortions
% 
% methods based on Rabinowitz, et al., 2011 (Neuron)

%% SETUP
% output directory
stimDir = 'C:\Users\Chris\Documents\GitHub\Kath\stimuli\';
params.filtName = '20170216_2PspkrNidaqInvFilt_3k-80k_fs400k.mat';
filtPath = ['C:\calibration\Filters\' params.filtName];
fname = '20170302_contrastGain83dB_chris';

% load filter
load(filtPath);

% parameters
params.seed = 89; %13
params.fs = 400e3;
params.filt = FILT;
params.nTones = 34;
params.freqs = 10^3 * ...
    (2 .^ (([0:params.nTones-1])/6)); % this is n freqs spaced 1/6 octave apart
params.mu = 83; % mean dB level
params.sd = [5 15]; % standard deviation of dB levels
params.rampDuration = .005;
params.chordDuration = .025;
params.blockDuration = 8; % duration of each contrast block
params.baseAmplitude = .1;
params.nBlocks = 20; % nBlocks per rec
params.totalDuration = params.nBlocks * params.blockDuration;
params.offsets = [.05 .1 .25 .5 1 2 4 9];
params.f = 15e3;
params.toneDB = 75;
params.nReps = 10;


%% STIMULUS CONSTRUCTION
rng(params.seed);

% make contrast blocks
[stim amps dbs] = makeContrastBlocks(params,params.nBlocks);
events = zeros(size(stim));
ev = ones(1,params.fs*0.05)*5; % we will place a 50ms event at the onset of every transition
for ii=1:params.nBlocks
    transitionTime = (ii-1)*(params.blockDuration*params.fs)+1;
    events(transitionTime:transitionTime+length(ev)-1) = ev;
end

% Filter the stimulus
stim1 = conv(stim,params.filt,'same');

x = [stim1;events];

fn = [stimDir fname '.wav'];
chunk_size = []; nbits = 16;
wavwrite_append((x/10)', fn, chunk_size, params.fs, nbits);

save([stimDir fname '.mat'],'params')

    
% %%
% tones = zeros(params.nReps,length(stim));
% stimulus = zeros(params.nReps,length(stim));
% for i = 1:params.nReps
%     tic
%     % make tones and add to stim
%     fprintf('Adding tones...\n');
%     [tones(i,:) index{i}] = addToneOffsets(params);
%     stimulus(i,:) = tones(i,:) + stim;
%     
%     fn = [stimDir filesep sprintf('%s%02d.wav',fname,i)];
%     if ~exist(fn,'file')
%         % filter
%         fprintf('Filtering... \n');
%         stim1 = conv(stimulus(i,:),params.filt,'same');
% 
%         % write to wav file
%         
%         wavwrite_append(stim1',fn, 1e6, params.fs, 16);
%     end
%     toc
% end
% 
% save([stimDir filesep fname '-idx.mat'],'index','params','envelope');
% 
% keyboard
% 
% % filter
% stim1 = conv(stimulus(1,:),params.filt,'same');
% 
% tones1 = conv(tones(1,:),params.filt,'same');
% stim2 = conv(stim,params.filt,'same');
% stim2 = tones1 + stim2;


% write to wav file
%  figure(1)
%  subplot(1,2,1)
%  hold on
%  plot(stim(1:params.fs*20),'b');
%  plot(events(1:params.fs*20),'r');
%  hold off
%  
%  subplot(1,2,2)
%  hold on
%  plot(stim(end-params.fs*20:end),'b');
%  plot(events(end-params.fs*20:end),'r');
%  hold off

% 
% [S,F,T] = spectrogram(stim(1:params.fs*20),params.chordDuration*params.fs,...
%                       0,params.freqs,params.fs,'yaxis');
% figure(2)
% surf(T,F,10*log10(abs(S)),'EdgeColor','none')
% colormap('jet')
% view([0 90])
% axis tight
% xlabel('Time')
% ylabel('Frequency')
% set(gca,'YScale','log')
% colorbar;
% 
% keyboard


    

