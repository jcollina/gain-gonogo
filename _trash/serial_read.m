function s = setupSerialPort(port,baud)

if nargin == 1
    baud = 9600;
elseif nargin == 0
    port = 'COM1';
end

fprintf('Opening serial comm. on %s, baud %g...\n\n',port,baud);
s = serial(port);
set(s,'BaudRate',baud);
fopen(s);

