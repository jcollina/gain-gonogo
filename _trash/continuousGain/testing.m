% first try to continuously update buffer
global g;
[g.s,fs] = setupNI_analog([0 1],400e3);

% make some data that you want to alternate
params.filt         = load('SMALL_BOOTH_FILT_70dB_200-9e3kHZ');
params.filt         = params.filt.filt;
params.amp70        = .1;
params.rampD        = .005;
params.nTones       = 34;
params.freqs        = 10^3 * (2 .^ (([0:params.nTones-1])/6)); % this is n freqs spaced 1/6 octave apart
params.mu           = 50;
params.sd           = [5 15];
params.chordDuration = .025;
params.noiseDuration = 3;
params.toneDB        = 65;
params.toneA         = params.amp70 .* ...
    10 .^ ((params.toneDB-70)./20);
params.offset        = 1;
for i = 1:2
    [noise(i,:) events] = makeDRC_target(fs,params.rampD,params.chordDuration,...
        params.noiseDuration,params.freqs,params.mu,params.sd(i),...
        params.amp70,params.toneA,params.offset,params.filt);
end
events = events * 5;

% global variables to pass to callback function
g.noise = noise;
g.events = events;
g.cnt = 1;
g.flag = false;
g.lh = addlistener(g.s,'DataRequired',@addData2Queue);


% now play it continuously, alternating each block
g.s.IsContinuous = true;
queueOutputData(g.s,[noise(1,:)*10; events]');
str = {'High','Low'};
fprintf('Trial %03d - %s contrast\n',g.cnt,str{mod(g.cnt,2)+1});
g.s.startBackground();
