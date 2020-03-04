function status = contains(a,b)

if iscell(a)
    for i = 1:max(size(a))
        status(i) = ~isempty(strfind(a{i},b));
    end
else
    status = ~isempty(strfind(a,b));
end