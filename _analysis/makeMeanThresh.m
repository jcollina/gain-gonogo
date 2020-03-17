% this script takes a list of mice and computes their average threshold,
% then it makes a new file that assigns those threshold averages to new
% mouse IDs

% load in the thresholds2use file
old = load('../_thresholds/thresholds2use_200317.mat');
ids2mean = old.mouseList(1:17);

meanThresh = nanmean(old.threshold(ismember(old.mouseList,ids2mean),:));

ids2make = {'CA118','CA119','CA121','CA122'};

mouseList = [old.mouseList ids2make];
threshold = [old.threshold; repmat(meanThresh,length(ids2make),1)];

save('../_thresholds/threshold_mean.mat','mouseList','threshold')