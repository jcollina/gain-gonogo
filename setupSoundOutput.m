function [s,realFS] = setupSoundOutput(fs,device,ch)

isNIDAQ = strcmp(device,'NIDAQ');

if ~isNIDAQ
    % setup the soundcard
    InitializePsychSound(1);
    
    % find the device
    d = PsychPortAudio('GetDevices',3);
    ind = find(strcmp({d.DeviceName}, device));
    id = d(ind).DeviceIndex;
    
    % open and determine real framerate
    s = PsychPortAudio('Open', id, 1, 3, fs, length(ch), [], [], ch);
    status = PsychPortAudio('GetStatus', s);
    realFS = status.SampleRate;
else
    % setup the NIDAQ
    daqreset;
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,'dev1',ch,'Voltage');
    s.Rate = fs;
    realFS = s.Rate;
end
    