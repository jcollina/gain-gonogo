function queueOutput(s,stim,device)

isNIDAQ = strcmp(device,'NIDAQ');
isLYNX = contains(device,'Lynx E44');
isASIO = strcmp(device,'ASIO Lynx');

if isASIO
    % load stim to soundcard
    PsychPortAudio('FillBuffer', s, stim');
elseif isNIDAQ
    % load stim to NIDAQ
    queueOutputData(s,stim);
elseif isLYNX
    % load stim to DirectSoundDriver
    queueOutputData(s,stim);
end


