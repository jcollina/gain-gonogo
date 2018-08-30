function runGONOGO

% Setup
p = setupSerialPort('COM4',9600);
[s,fs] = setupNidaq(1,250e3);
fn = 'test.txt';
fid = fopen(fn,'w');
state = 0;

% Make stimulus
pad = ceil(fs * .1);
eventLength = ceil(.01 * fs);
stimDur = ceil(3.56 * fs);
noise = rand(1,stimDur)/3;
noise = noise - mean(noise);
sound = [noise zeros(1,pad)];
event = [ones(1,eventLength) ...
         zeros(1,stimDur - eventLength) ...
         ones(1,eventLength) zeros(1,pad - eventLength)] * 3.3;
stim = [sound; event];

fprintf('PRESS ANY KEY TO START...\n');
pause;

while 1
    out = serialRead(p);
    
    fprintf(fid,'%s',out);
    fprintf('%s',out);
    
    if ~isempty(regexp(out,'TRIAL', 'once'))
        % Send trial type
        fprintf(p,'0');
    elseif ~isempty(regexp(out,'TON', 'once')) 
        % Play stimulus
        queueOutputData(s,stim(2,:)');
        startBackground(s);
    elseif ~isempty(regexp(out,'TOFF', 'once'))
        % Make sure we're ready for the next trial
        if s.IsRunning
            stop(s);
        end
    end
end
            
stop(s);           
fclose(p);
delete(p);
clear all

% delete(instrfindall)

keyboard