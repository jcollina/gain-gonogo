function status = contains(a,b)

status = ~isempty(strfind(a,b));