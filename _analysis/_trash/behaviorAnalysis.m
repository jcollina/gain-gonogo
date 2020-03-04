function behaviorAnalysis(ID)

disp(['ANALYZING MOUSE ' ID]);

baseDir = '~/gits/gain-gonogo/data';
dataDir = [baseDir filesep ID];

taskStr = {'LoHi','HiLo'};

% make a master file list
keyboard