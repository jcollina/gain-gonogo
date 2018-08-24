function prime(params)
KbName('UnifyKeyNames');

% load the arduino sketch
if params.inverted
    hexPath = [params.hex filesep 'debouncePrime_inv.ino.hex'];
else
    hexPath = [params.hex filesep 'debouncePrime.ino.hex'];
end
loadArduinoSketch(params.com,hexPath);

% wait for exit command
id = params.boothID;
if contains(id,'1')
    escapeCode = '1!';
elseif contains(id,'2')
    escapeCode = '2@';
elseif contains(id,'3')
    escapeCode = '3#';
elseif contains(id,'4')
    escapeCode = '4$';
elseif contains(id,'5')
    escapeCode = '5%';
elseif contains(id,'6')
    escapeCode = '6^';
elseif contains(id,'7')
    escapeCode = '7&';
elseif contains(id,'8')
    escapeCode = '8*';
else
    escapeCode = [];
end
esc = {'ESCAPE', escapeCode};

disp(sprintf('Press %s + %s to quit.',esc{1},esc{2}));

while 1
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 2
        if all(strcmp(KbName(keyCode),esc))
            disp('QUITTING');
            break
        end
    end
    WaitSecs(.005);
end

% load blank arduino sketch
hexPath = [params.hex filesep 'blank.ino.hex'];
loadArduinoSketch(params.com,hexPath);