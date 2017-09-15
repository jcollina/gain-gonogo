function behaviorWrapper(mouseList,mouseTask)

if ~exist('mouseList','var')
    mouseList = {'CA046','CA047','CA048','CA049'};
end
if ~exist('mouseTask','var')
    for i = 1:length(mouseList)
        if strcmp(mouseList{i},'CA046')
            mouseTask(i) = 0;
        elseif strcmp(mouseList{i},'CA047')
            mouseTask(i) = 1;
        elseif strcmp(mouseList{i},'CA048')
            mouseTask(i) = 0;
        elseif strcmp(mouseList{i},'CA049')
            mouseTask(i) = 1;
        end
        %mouseTask = [0 1 0 1];
    end
end

for i = 1:length(mouseList)
    analyzeBehavior(mouseList{i},mouseTask(i));
end