function addData2Queue(src,event)
global g;

g.cnt = g.cnt + 1;
% use the next alternating block
if mod(g.cnt,2)
    % odd trial = low
    data = g.noise(1,:);
else
    % even trial = high
    data = g.noise(2,:);
end

str = {'High','Low'};

% queue the data
queueOutputData(g.s,[data*10; g.events]');
fprintf('Trial %03d - %s contrast\n',g.cnt,str{mod(g.cnt,2)+1});

