function behaviorWrapper1(mouseList)

if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049'};
end

for i = 1:length(mouseList)
    behaviorAnalysis(mouseList{i});
end