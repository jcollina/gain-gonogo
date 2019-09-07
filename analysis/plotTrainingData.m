function plotTrainingData(dat)

for i = 1:length(dat)
    
    % sort in ascending time
    [~,sI] = sort(dat(i).training.date);
    date = dat(i).training.date(sI);
    contrast = dat(i).training.contrast(sI);
    hitrate = dat(i).training.hr(sI);
    farate = dat(i).training.fa(sI);
    dprime = dat(i).training.dprime(sI);
    
    % find the contrast switches
    switches = find(diff(contrast)~=0);
    
    % if there are switches
    if ~isempty(switches)
        
        % exclude early switches (possible mistakes)
        if switches(1) < 10
            switches(1) = [];
        end
        
        % check for erroneous switches after the first
        errSwitch = find(diff(switches) < 3);
        while any(errSwitch)
            switches(errSwitch(1):errSwitch(1)+1) = [];
            errSwitch = find(diff(switches) < 3);
        end
        
    end
    
    % if there are no more switches, just use the last element
    if isempty(switches)
        switches = length(contrast);
    end
    
    % index up to the first switch, excluding sessions where there
    % was an inappropriate switch
    ind = 1:switches(1);
    contrastI(i) = mode(contrast(ind));
    ind(contrast(ind) ~= contrastI(i)) = [];
    
     % days from first training day
    dt = datetime(num2str(date(ind,:)),'InputFormat', ...
                  'yyMMdd');
    nDays{i} = daysact(dt(1)-1,dt);
    
    % training performance
    hrt{i} = hitrate(ind);
    fat{i} = farate(ind);
    dpt{i} = dprime(ind);
    nd(i) = max(nDays{i});
    index{i} = ind;

end

% performance matrix across all possible days
dpmat = nan(length(dat),max(nd));
hrmat = nan(length(dat),max(nd));
famat = nan(length(dat),max(nd));
days = 1:max(nd);

for i = 1:length(dat)
    dpmat(i,index{i}) = dpt{i};
    hrmat(i,index{i}) = hrt{i};
    famat(i,index{i}) = fat{i};
    
    if contrastI(i) == 2
        subplot(3,3,1); hold on;
        p = plot(nDays{i},dpt{i},'b'); p.Color(4) = .35;
        subplot(3,3,2); hold on;
        p = plot(nDays{i},hrt{i},'b'); p.Color(4) = .35;
        subplot(3,3,3); hold on;
        p = plot(nDays{i},fat{i},'b'); p.Color(4) = .35;
    else
        subplot(3,3,4); hold on
        p = plot(nDays{i},dpt{i},'r'); p.Color(4) = .35;
        subplot(3,3,5); hold on;
        p = plot(nDays{i},hrt{i},'r'); p.Color(4) = .35;
        subplot(3,3,6); hold on;
        p = plot(nDays{i},fat{i},'r'); p.Color(4) = .35;
    end
end
subplot(3,3,1); hold on
plot(days,nanmean(dpmat(contrastI==2,:)),'b','LineWidth',1.5)
xlim([0 80]);
title(sprintf('d-prime (n=%d)',length(dat)));
xlabel('Days from first session');
ylabel('d-prime');
subplot(3,3,4); hold on
plot(days,nanmean(dpmat(contrastI==1,:)),'r','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('d-prime');
subplot(3,3,7); hold on
plot(days,nanmean(dpmat(contrastI==2,:)),'b','LineWidth',1.5)
plot(days,nanmean(dpmat(contrastI==1,:)),'r','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('d-prime');

subplot(3,3,2); hold on
plot(days,nanmean(hrmat(contrastI==2,:)),'b','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('Hit Rate');
title('Hit Rate');
subplot(3,3,5); hold on
plot(days,nanmean(hrmat(contrastI==1,:)),'r','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('Hit Rate');
subplot(3,3,8); hold on
plot(days,nanmean(hrmat(contrastI==2,:)),'b','LineWidth',1.5)
plot(days,nanmean(hrmat(contrastI==1,:)),'r','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('Hit Rate');

subplot(3,3,3); hold on
plot(days,nanmean(famat(contrastI==2,:)),'b','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('FA Rate');
title('False Alarm Rate')
subplot(3,3,6); hold on
plot(days,nanmean(famat(contrastI==1,:)),'r','LineWidth',1.5)
xlim([0 80]);
xlabel('Days from first session');
ylabel('FA Rate');
subplot(3,3,9); hold on
plot(days,nanmean(famat(contrastI==2,:)),'b','LineWidth',1.5)
plot(days,nanmean(famat(contrastI==1,:)),'r','LineWidth',1.5)
ylim([0 1]);
xlim([0 80]);
xlabel('Days from first session');
ylabel('FA Rate');