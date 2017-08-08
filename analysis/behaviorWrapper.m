mouseList = {'CA049'};%{'CA046','CA047','CA048','CA049'};
mouseTask = 1%[0 1 0 1];
for i = 1:length(mouseList)
    analyzeBehavior(mouseList{i},mouseTask(i));
end