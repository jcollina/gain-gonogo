function behaviorWrapper(mouseList)

if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049'};
end

for i = 1:length(mouseList)
    threshold(i,:) = behaviorAnalysis(mouseList{i});
end

if length(threshold) == 4
    save('thresholds.mat','mouseList','threshold')
end

keyboard