function genDRC2p

clear all
close all
addpath(genpath('~/projects/util/'));

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
stimDir = '~/data/gain_adaptation/stimulus';
filtPath = '~/gits/filters/20170216_2PspkrNidaqInvFilt_3k-80k_fs400k.mat';
fname = '20170303_contrastGain65dB_tChord17';

% load filter
load(filtPath);

% parameters
params.seed = 1989; %13
params.fs = 400e3;
params.filt = FILT;
params.filtPath = filtPath;
params.nTones = 34;
params.freqs = 4*1e3 * ...
    (2 .^ (([0:params.nTones-1])/10)); % this is n freqs spaced 1/6 octave apart
params.mu = 65; % mean dB level
params.sd = [5 15]; % standard deviation of dB levels
params.rampDuration = .005;
params.chordDuration = .025;
params.blockDuration = 10; % duration of each contrast block
params.baseAmplitude = .1;         % target amplitude at 70db
params.nBlocks = 18; % nBlocks per rec
params.totalDuration = params.nBlocks * params.blockDuration;
params.offsets = [.05 .1 .25 .5 1 2 4 9];
params.f = 15e3;
params.nReps = 10;
params.targetDBShift = 10;
params.chordDB = params.mu + params.targetDBShift;


%% STIMULUS CONSTRUCTION
rng(params.seed);

% define some sample and block variables
rs = params.rampDuration * params.fs;
cs = (params.chordDuration - params.rampDuration) * params.fs;
n = params.nBlocks;

% make contrast amplitude values
[~, dbs] = makeChordAmplitudes(rs,cs,n,params);

% make a target chord by choosing several values between each
% octave
octs = [4*1e3 .* 2 .^ (0:3) max(params.freqs)];
nchoices = [5 5 5 2];
target = zeros(1,length(params.freqs));
for i = 1:length(nchoices)
    % choose n between each bound
    ind(1) = find(params.freqs == octs(i));
    ind(2) = find(params.freqs == octs(i+1));
    ind = ind(1):ind(2);
    
    % choose n items separated by 1/5 octave
    cnt = 0;
    while 1
        cnt = cnt + 1;
        freq = randperm(length(ind)-1,nchoices(i));
        if ~any(diff(sort(freq))<=1) || isempty(diff(freq))
            break;
        end
    end
    length(freq)
    fprintf('%d iterations\n',cnt);
    
    % build target variable
    target(ind(freq)) = params.targetDBShift;
end
params.targetFreqs = params.freqs(target>0);
params.target = target;

    
for i = 1:params.nReps
    % add in targets
    [amps{i} db{i} index{i} str events{i}] = addTargetChord(dbs,target,params);
    
    % generate each stim waveform
    [stim] = makeContrastBlocks(params,amps{i});
    
    figure
    hold on
    plot(stim)
    plot(events{i},'LineWidth',2)
    hold off
    
    % save wav file
    fn = [stimDir filesep sprintf('%s_%02d.wav',fname,i)];
    if ~exist(fn,'file')
        % filter
        fprintf('Filtering %s\n...',fn);
        tic
        stim1 = conv(stim,params.filt,'same');
        toc
        
        % write
        wavwrite_append([stim1' events{i}'],fn,2e6,params.fs,16);
    end
end

keyboard

save([stimDir filesep fname '.mat'],'params','amps','db','index');
    

%% PRESENTED LATE FEBRUARY DIVIDED BY 10 -- 63dB rather than 83dB
% events = zeros(size(stim));
% ev = ones(1,params.fs*0.05)*5; % we will place a 50ms event at the onset of every transition
% for ii=1:params.nBlocks
%     transitionTime = (ii-1)*(params.blockDuration*params.fs)+1;
%     events(transitionTime:transitionTime+length(ev)-1) = ev;
% end


% % Filter the stimulus
% stim1 = conv(stim,params.filt,'same');
% 
% x = [stim1;events];
% 
% fn = [stimDir fname '.wav'];
% chunk_size = []; nbits = 16;
% wavwrite_append((x/10)', fn, chunk_size, params.fs, nbits);
% 
% save([stimDir fname '.mat'],'params')

    
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


    

