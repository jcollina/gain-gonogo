function queueOutput(s,stim,device)

isNIDAQ = strcmp(device,'NIDAQ');

if ~isNIDAQ
    % load stim to soundcard
    PsychPortAudio('FillBuffer', s, stim');
else
    % load stim to NIDAQ
    queueOutputData(s,stim);
end


