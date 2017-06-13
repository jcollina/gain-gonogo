function resp = parseResp(out,tt)

resp = NaN;
if tt == 1
    % signal trials
    if ~isempty(regexp(out,'HIT','once'))
        resp = 1;
    elseif ~isempty(regexp(out,'MISS','once'))
        resp = 0;
    end
else
    % noise trials
    if ~isempty(regexp(out,'FALSEALARM','once'))
        resp = 1;
    elseif ~isempty(regexp(out,'CORRECTREJECT','once'))
        resp = 0;
    end
end
