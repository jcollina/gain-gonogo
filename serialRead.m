function out = serialRead(s,id)

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

while 1
%    if s.BytesAvailable
%        out = fscanf(s);
%        break
%    end
    [~,~,keyCode] = KbCheck;
    if sum(keyCode) == 2
        if all(strcmp(KbName(keyCode),esc))
            out = '0000 999999 USEREXIT';
            break
        end
    end
    
    out = serialReadOctave(s,1);
    if all(int8(out) == 1)
        continue
    else
        break
    end
end