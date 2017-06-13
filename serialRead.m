function out = serialRead(s)

while 1
    if s.BytesAvailable
        out = fscanf(s);
        break
    end
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 1
        if strcmp(KbName(keyCode),'ESCAPE');
            out = '0000 999999 USEREXIT';
            break
        end
    end
end
