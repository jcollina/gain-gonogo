function startOutput(s,device)

isOPTB  = contains(device,'OPTB');
isNIDAQ = strcmp(device,'NIDAQ');
isLYNX = contains(device,'Lynx E44') && ~isOPTB;
isASIO = strcmp(device,'ASIO Lynx');

if isASIO || isOPTB
    % start soundcard
    PsychPortAudio('Start', s, 1);
else
    % start NIDAQ
    startBackground(s);
end