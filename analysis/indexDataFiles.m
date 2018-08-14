function [fileList fileInd] = indexDataFiles(dataDir)

files = dir([dataDir filesep '*.mat']);

% make a file list and index
n = 100;
cnt = 1;
for i = 1:length(files)
    load([dataDir filesep files(i).name]);
    % if there are enough trials
    [mn mi] = min([length(tt) length(resp)]);
    if mn >= n
        % add to file list
        fileList{cnt} = [dataDir filesep files(i).name];
        % classify by behavioral task type
        if params.sd(1) < params.sd(2)
            fileInd(cnt,1) = 1;
        else
            fileInd(cnt,1) = 2;
        end
        
        % classify by behavior task
        if contains(files(i).name,'_training')
            fileInd(cnt,2) = 1;
        elseif contains(files(i).name,'_testing')
            fileInd(cnt,2) = 2;
        elseif contains(files(i).name,'_offsetTesting')
            fileInd(cnt,2) = 3;
        end
        
        % extract dates
        tmp = strfind(fileList{cnt},'_');
        dateStr = str2num(fileList{cnt}(tmp(1)+1:tmp(2)-1));
        fileInd(cnt,3) = floor(dateStr/10000);
        
        % add number of trials
        fileInd(cnt,4) = mn;
        
        % was it a recording session?
        fileInd(cnt,5) = contains(params.boothID,'rec');
        
        cnt = cnt + 1;
    end
end




