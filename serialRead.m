function out = serialRead(s,id)

if strcmp(id,'booth1')
    escapeCode = '1!';
elseif strcmp(id,'booth2')
    escapeCode = '2@';
elseif strcmp(id,'booth3')
    escapeCode = '3#';
elseif strcmp(id,'booth4')
    escapeCode = '4$';
else
    escapeCode = [];
end
esc = {'ESCAPE', escapeCode};

while 1
    if s.BytesAvailable
        out = fscanf(s);
        break
    end
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 2
        if all(strcmp(KbName(keyCode),esc))
            out = '0000 999999 USEREXIT';
            break
        end
    end
end
