function tf = contains(s,pattern,varargin)

% for one string
narginchk(2, inf);

try
    stringS = string(s);
    
    if nargin == 2
        tf = stringS.contains(pattern);
    else
        tf = stringS.contains(pattern, varargin{:});
    end
    
catch E
    throw(E)
end