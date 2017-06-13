function startOutput(s,device)

isNIDAQ = strcmp(device,'NIDAQ');

if ~isNIDAQ
    % start soundcard
    PsychPortAudio('Start', s, 1)
else
    % start NIDAQ
    startBackground(s);
end