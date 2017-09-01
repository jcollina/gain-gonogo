mouseList = {'CA046','CA047','CA048','CA049'};
mouseTask = [0 1 0 1];
%mouseList = {'CA047'};
%mouseTask = [1];

for i = 1:length(mouseList)
    analyzeBehavior(mouseList{i},mouseTask(i));
end