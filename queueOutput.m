function queueOutput(s,stim,device)

isOPTB  = contains(device,'OPTB');
isNIDAQ = strcmp(device,'NIDAQ');
isLYNX = contains(device,'Lynx E44') && ~isOPTB;
isASIO = strcmp(device,'ASIO Lynx');

if isASIO || isOPTB
    % load stim to soundcard
    PsychPortAudio('FillBuffer', s, stim');
elseif isNIDAQ
    % load stim to NIDAQ
    queueOutputData(s,stim);
elseif isLYNX
    % load stim to DirectSoundDriver
    queueOutputData(s,stim);
end


