<<<<<<< HEAD
%% 2nd April 2018 - booth 3
empty = 0.9971; % g - weight of empty eppendorf
durations = [25 20 15 ]; % ms - duration of solenoid opening
weights = [1.3342 1.354 1.2368 ]; % weight of eppendorf with water from 100 openings of the valve
=======
%% 2nd April 2018 - booth 3
empty = 0.9971; % g - weight of empty eppendorf
durations = [25 20 17 15 15 15 40 40 ]; % ms - duration of solenoid opening
weights = [1.3342 1.354 1.3543 1.3378 1.2368 1.3476 1.4241 1.4298]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',3)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 5:.1:90;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 8; % if x is ...
y1 = polyval(P,x1)
%% 2nd April 2018 - booth 1
empty = 0.9971; % g - weight of empty eppendorf
durations = [30 ]; % ms - duration of solenoid opening
weights = [1.3371]; % weight of eppendorf with water from 100 openings of the valve
>>>>>>> origin/master
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',3)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 5:.1:90;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 8; % if x is ...
y1 = polyval(P,x1)

%% 3/21/17 - bottomBooth
empty = 1.1108; % g - weight of empty eppendorf
durations = [7 8 9 10 12 20 30 40 60 80]; % ms - duration of solenoid opening
weights = [1.4030 1.4786 1.5013 1.5223 1.5650 1.5855 1.6251 1.6866 1.7746 1.9534]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',3)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 5:.1:90;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 8; % if x is ...
y1 = polyval(P,x1)
