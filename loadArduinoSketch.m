function [status, cmdOut] = loadArduinoSketch(comport,sketch)

cmdIn = sprintf('%s%s%s%s:i"','cmd /C ""C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude.exe" -C"C:\Program Files (x86)\Arduino\hardware\tools\avr/etc/avrdude.conf" -v -patmega328p -carduino -P',comport,' -b115200 -D -Uflash:w:',sketch);

[status,cmdOut] = dos(cmdIn);

if status == 0
    fprintf('LOADED HEX FILE: %s\n',sketch);
else
    error('FAILED TO LOAD HEX FILE');
end