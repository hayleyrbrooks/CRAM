% Temporal context,risky decision-making, aging and mood

% Hayley Brooks
% Created October 2021

% reset 
clear all;

% get in the right directory
cd /Users/shlab/Desktop/GBEdata/Rutledge_risk_and_happiness_task_2020

%load the data
load ('Rutledge_GBE_risk_data.mat');
% this loads depData (depression data) and subjData (choicesets, age, gender, etc)

load('firstPlayTable.mat');
% this was generated below but now commented out
% its basically the long format of the data above
% saving the code in the event we want to change it

%% Data set up

%firstPlayTable = [];


for s=1:length(subjData)
    t=subjData(s).data{1}(:,1:10);                   % pull out first play only 
    % includes: trial number, side of screen w/risky option, safe value,
    % value on winning side, value on losing side, choice, outcome, choice
    % latency, happiness rating after trial
    
    t(:,size(t,2)+1) = subjData(s).id;               % add a column and store ID
    t(:,size(t,2)+1) = subjData(s).age;              % add a column and store age
    t(:,size(t,2)+1) = subjData(s).lifeSatisfaction; % add a column and store life satisfaction
    
    subjData(s).totalGam = 100*mean(t(:,7));         % pgam across all trial types
    subjData(s).gainGam  = 100*mean(t(t(:,3)>0,7));  % pgam gain only trials
    subjData(s).mixedGam = 100*mean(t(t(:,3)==0,7)); % pgam mixed trials
    subjData(s).lossGam  = 100*mean(t(t(:,3)<0,7));  % pgam loss trials
    
    
    % combine first plays into a table
    % firstPlayTable = [firstPlayTable; t]; % this is saved now, so I am commenting it out
    % takes several minutes to run.
end

% change firstPlayTable into a table with variable names
% firstPlayTable = array2table(firstPlayTable);
% firstPlayTable.Properties.VariableNames = {'trial' 'riskySide' 'safe' 'riskyGain' 'riskyLoss' 'blank' 'choice' 'outcome' 'choiceLatency' 'happiness' 'id' 'age' 'lifeSat' };
% save('firstPlayTable.mat', 'firstPlayTable')


% create a table for subject information
% sub Id, pgam (all trials, gain trials, mixed trials and loss trials),
% age, life satisfaction
subIds = vertcat(subjData.id);
totalGam = vertcat(subjData.totalGam);
gainGam = vertcat(subjData.gainGam);
mixedGam = vertcat(subjData.mixedGam);
lossGam = vertcat(subjData.lossGam);
age = vertcat(subjData.age);
lifeSat = vertcat(subjData.lifeSatisfaction);
isFemale  = vertcat(subjData.isFemale);

subInfo = table(subIds,totalGam,gainGam,mixedGam,lossGam,lifeSat, isFemale);


%% Explore some stuff

%{ 
 Starting with first plays only:
    What does gambling look like for each participant (not collapsing
    across trial types yet)? How many people always or never gamble? We can't really learn much from
    them contextually on an individual-level basis because their behavior doesn't
    change. Perhaps do analyses that include and exclude them?
%}


% how many people never or always gambled across all trials in first play?

alwaysGambleID = subInfo.subIds(subInfo.totalGam ==100); % sub IDs of those who always gambled
alwaysGambleTot = size(alwaysGambleID,1); % 1653 participants

neverGambleID = subInfo.subIds(subInfo.totalGam == 0); % sub IDs of those who never gambled
neverGambleTot = size(neverGambleID,1); % 37 participants

boundsID = [alwaysGambleID; neverGambleID]; % combine IDs for subs at bounds
boundsTot = size(boundsID,1); % 1690 participants total who never or always gambled

% For all participants (n=47067)
mean(subInfo.totalGam); % 63.7258 - this is high from what I am used to seeing
mean(subInfo.gainGam); % 69.8555
mean(subInfo.lossGam); % 55.1376
mean(subInfo.mixedGam); % 67.1059

adjustIds = subInfo.subIds((subInfo.totalGam <100 & subInfo.totalGam >0)); % vector with participants who were not at bounds
% Excluding participants at the 0 and 100 pgam bounds
mean(subInfo.totalGam(subInfo.subIds(adjustIds))); % 62.4563
mean(subInfo.gainGam(subInfo.subIds(adjustIds))); % 68.8144
mean(subInfo.lossGam(subInfo.subIds(adjustIds))); % 53.5484
mean(subInfo.mixedGam(subInfo.subIds(adjustIds))); %65.9624
% generally lower risk-taking when removing people at the bounds



%% saving stuff
%writetable( firstPlayTable, 'firstPlayTable.csv');
%writetable(subInfo, 'subInfo.csv');

%% Analysis

% Does risk-taking on the second trial depend on the previous trial type and outcome? 
% starting with 1st and 2nd trial for simplicity
% There will be 9 variations on the first trial (gain, loss, and mixed trials with 3 choices/outcomes).

pgams = NaN(3,9); % rows are trials 2-4 and columns are the various trial type outcome combinations
pgams = array2table(pgams);
pgams.Properties.VariableNames= {'gainGamWin' 'gainGamLoss' 'gainSafe' 'lossGamWin' 'lossGamLoss' 'lossSafe' 'mixedGamWin' 'mixedGamLoss' 'mixedSafe'};

% gain trial, gambled and won (these are trials 1-3)
gainGamWin1= find(firstPlayTable.trial == 1 & firstPlayTable.safe >0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5977 trials, 103 mean outcome
gainGamWin2= find(firstPlayTable.trial == 2 & firstPlayTable.safe >0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5746 trials, 104 mean outcome
gainGamWin3= find(firstPlayTable.trial == 3 & firstPlayTable.safe >0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5923 trials, 104 mean outcome

% pgamble on next trial (these are trials 2-4):
pgams.gainGamWin(1) = mean(firstPlayTable.choice(gainGamWin1+1)); %  0.6737 (pgamble on trial 2)
pgams.gainGamWin(2) = mean(firstPlayTable.choice(gainGamWin2+1)); %  0.6639 (pgamble on trial 3)
pgams.gainGamWin(3) = mean(firstPlayTable.choice(gainGamWin3+1)); %  0.6740 (pgamble on trial 4)


% gain trial, gambled and loss (these are trials 1-3; mean outcome = 0)
gainGamLoss1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5812 trials
gainGamLoss2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5636 trials
gainGamLoss3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5849 trials

% pgamble on next trial (these are trials 2-4):
pgams.gainGamLoss(1) = mean(firstPlayTable.choice(gainGamLoss1+1)); % 0.7266 (pgamble on trial 2)
pgams.gainGamLoss(2) = mean(firstPlayTable.choice(gainGamLoss2+1)); % 0.7016 (pgamble on trial 3)
pgams.gainGamLoss(3) = mean(firstPlayTable.choice(gainGamLoss3+1)); % 0.7073 (pgamble on trial 4)


% gain trials, safe (these are trials 1-3)
gainSafe1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.safe); %5562 trials, 44 mean outcome
gainSafe2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.safe); %5657 trials, 45 mean outcome
gainSafe3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.safe); %5455 trials, 44 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.gainSafe(1) = mean(firstPlayTable.choice(gainSafe1+1)); % 0.6235
pgams.gainSafe(2) = mean(firstPlayTable.choice(gainSafe2+1)); % 0.6164
pgams.gainSafe(3) = mean(firstPlayTable.choice(gainSafe3+1)); % 0.6266


% loss trials, gamble won (these are trials 1-3, mean outcome = 0)
lossGamWin1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %6778 trials
lossGamWin2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5638 trials
lossGamWin3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5147 trials

% pgamble on next trials (these are trials 2-4)
pgams.lossGamWin(1) = mean(firstPlayTable.choice(lossGamWin1+1)); %0.7307
pgams.lossGamWin(2) = mean(firstPlayTable.choice(lossGamWin2+1)); %0.7185
pgams.lossGamWin(3) = mean(firstPlayTable.choice(lossGamWin3+1)); %0.7496


% loss trials, gamble loss (these are trials 1-3)
lossGamLoss1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %6529 trials, -99 mena outcome
lossGamLoss2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5707 trials, -97 mean outcome
lossGamLoss3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5198 trials, -96 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.lossGamLoss(1) = mean(firstPlayTable.choice(lossGamLoss1+1)) % 0.7059
pgams.lossGamLoss(2) = mean(firstPlayTable.choice(lossGamLoss2+1)) % 0.7069
pgams.lossGamLoss(3) = mean(firstPlayTable.choice(lossGamLoss3+1)) % 0.7384


% loss trials, safe (these are trials 1-3)
lossSafe1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %3772 trials, -43 mean outcome
lossSafe2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %6040 trials, -43 mean outcome
lossSafe3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %6937 trials, -43 mean outcome

% pgamble on next trial (these are trials 2-4):
pgams.lossSafe(1) = mean(firstPlayTable.choice(lossSafe1+1)) %0.6307
pgams.lossSafe(2) = mean(firstPlayTable.choice(lossSafe2+1)) %0.6555
pgams.lossSafe(3) = mean(firstPlayTable.choice(lossSafe3+1)) %0.6494


% mixed trials, gamble win (these are trials 1-3)
mixedGamWin1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5036 trials, 57 mean outcome
mixedGamWin2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %4801 trials, 58 mean outcome
mixedGamWin3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %4750 trials, 57 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.mixedGamWin(1) = mean(firstPlayTable.choice(mixedGamWin1+1)) %0.6962
pgams.mixedGamWin(2) = mean(firstPlayTable.choice(mixedGamWin2+1)) %0.6657
pgams.mixedGamWin(3) = mean(firstPlayTable.choice(mixedGamWin3+1)) %0.6838


% mixed trials, gamble loss (these are trials 1-3)
mixedGamLoss1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5054 trials, -49 mean outcome
mixedGamLoss2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %4831 trials, -47 mean outcome
mixedGamLoss3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %4661 trials, -47 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.mixedGamLoss(1) = mean(firstPlayTable.choice(mixedGamLoss1+1)) %0.7068
pgams.mixedGamLoss(2) = mean(firstPlayTable.choice(mixedGamLoss2+1)) %0.6643
pgams.mixedGamLoss(3) = mean(firstPlayTable.choice(mixedGamLoss3+1)) %0.6953


% mixed trials, safe (these are trials 1-3, mean outcome =0)
mixedSafe1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %2547 trials
mixedSafe2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %3011 trials
mixedSafe3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %3147 trials

% pgamble on next trial (these are trials 2-4)
pgams.mixedSafe(1) = mean(firstPlayTable.choice(mixedSafe1+1)); %0.6368
pgams.mixedSafe(2) = mean(firstPlayTable.choice(mixedSafe2+1)); %0.6054
pgams.mixedSafe(3) = mean(firstPlayTable.choice(mixedSafe3+1)); %0.6107

% plot 6 lines across trials 2-4 (green = gain trial; red = loss trial;
% blue =  mixed trial; + = win outcome and o = loss outcome)
f1=plot(pgams{:,1}, 'color', 'green', 'marker', "+", 'markersize',9, "linewidth", 2); % gain gamble win
hold on
plot(pgams{:,2}, 'color', 'green', 'marker', "o", 'markersize',9, "linewidth", 2); % gain gamble loss
%plot(pgams{:,3},  'color', 'green', 'marker', "*", 'markersize',9, "linewidth", 2); % gain safe
plot(pgams{:,4}, 'color', 'red', 'marker', "+", 'markersize',9, "linewidth", 2); % loss gamble win
plot(pgams{:,5}, 'color', 'red', 'marker', "o", 'markersize',9, "linewidth", 2); % loss gamble loss
%plot(pgams{:,6}, 'color', 'red', 'marker', "*", 'markersize',9, "linewidth", 2); % loss safe
plot(pgams{:,7},'color', 'blue', 'marker', "+", 'markersize',9, "linewidth", 2); % mixed gamble win
plot(pgams{:,8},'color', 'blue', 'marker', "o", 'markersize',9, "linewidth", 2); % mixed gamble loss
%plot(pgams{:,9},'color', 'blue', 'marker', "*", 'markersize',9, "linewidth", 2); % mixed safe

% TO DO: I think this plot is cool but it would be more cool to see how the pattern
% continues across the entire task. Need to recode the stuff above to be
% more efficient if we want to look at these patterns across all trials.


% Interim summary: 
% Relative to 0 on a mixed trial with safe outcome, risk-taking increases 
% after a 0 on a loss (i.e. 0 is a win) and gain (i.e. 0 is a loss) trial 
% but there is a very small difference between risk-taking after a 0 on a 
% loss and gain trial. 
% Following gain trials, risk-taking was highest when the outcome was a loss, then a win,
% then a safe
% Following loss trials, risk-taking was highest when the outcome was a
% win, then a loss, then a safe
% Following mixed trials, risk-taking was highest when the outcome was a win, then loss, then safe
% but  the difference between win and loss outcomes in the mixed valece
% trial is very small.



%% The analysis above looks at risk-taking on the current trial as a
% function of the previous trial type, choice and outcome. What does
% it look like as both a function of prevoius trial events and current
% trial type. For now, don't worry about safe trials. Just looking at
% trials 1 and 2 right now.

% T-1 = GAIN, GAMBLE, WIN:
% t = gain gambled
% t = loss gambled
% t = mixed gambled

% index for all t-1: gainGamWin1
% index  for all t: gainGamWin1+1

gainGamWinNext = firstPlayTable(gainGamWin1 + 1,:); % all trials following a gain trial, gamble win

% When previous trial was gain trial type and participants gambled and
% won the following trials were...
gainGamWinNextGain = find(gainGamWinNext.trial == 2 & gainGamWinNext.safe >0 & gainGamWinNext.riskyGain>0 & gainGamWinNext.riskyLoss==0); % gain trials (2017)
gainGamWinNextLoss = find(gainGamWinNext.trial == 2 & gainGamWinNext.safe <0 & gainGamWinNext.riskyGain==0 & gainGamWinNext.riskyLoss<0); % loss trials (2305)
gainGamWinNextMix  = find(gainGamWinNext.trial == 2 & gainGamWinNext.safe ==0 & gainGamWinNext.riskyGain>0 & gainGamWinNext.riskyLoss<0); % mixed trials (1655)

% and average gambling on those trials was:
mean(firstPlayTable.choice(gainGamWinNextGain)); %0.6044
mean(firstPlayTable.choice(gainGamWinNextLoss)); %0.6213
mean(firstPlayTable.choice(gainGamWinNextMix));  %0.6066

% following gain trial win (avg outcome = 103) --> gambling on gain and mixed are similar but slightly
% higher when current loss trial type.


% T-1: GAIN, GAMBLE, LOSS:
% t = gain gambled
% t = loss gambled
% t = mixed gambled

% index for all t-1: gainGamLoss1
% index  for all t: gainGamLoss1+1

gainGamLossNext = firstPlayTable(gainGamLoss1 + 1,:); % all trials following a gain trial, gamble loss

% When previous trial was gain trial type and participants gambled and
% loss the following trials were...
gainGamLossNextGain = find(gainGamLossNext.trial == 2 & gainGamLossNext.safe >0 & gainGamLossNext.riskyGain>0 & gainGamLossNext.riskyLoss==0); % gain trials (1992)
gainGamLossNextLoss = find(gainGamLossNext.trial == 2 & gainGamLossNext.safe <0 & gainGamLossNext.riskyGain==0 & gainGamLossNext.riskyLoss<0); % loss trials (2208)
gainGamLossNextMix  = find(gainGamLossNext.trial == 2 & gainGamLossNext.safe ==0 & gainGamLossNext.riskyGain>0 & gainGamLossNext.riskyLoss<0); % mixed trials (1612)

% and average gambling on those trials was:
mean(firstPlayTable.choice(gainGamLossNextGain)); %0.6135
mean(firstPlayTable.choice(gainGamLossNextLoss)); %0.5969
mean(firstPlayTable.choice(gainGamLossNextMix));  %0.6210

% following gain trial loss (outcome = 0) --> gambling highest for mixed and lowest
% for loss trials.


% T-1: LOSS, GAMBLE, WIN
% t = gain gambled
% t = loss gambled
% t = mixed gambled

% index for all t-1: lossGamWin1
% index  for all t: lossGamWin1+1

lossGamWinNext = firstPlayTable(lossGamWin1 + 1,:); % all trials following a loss trial, gamble win

% When previous trial was loss trial type and participants gambled and
% won the following trials were...
lossGamWinNextGain = find(lossGamWinNext.trial == 2 & lossGamWinNext.safe >0 & lossGamWinNext.riskyGain>0 & lossGamWinNext.riskyLoss==0); % gain trials (2532)
lossGamWinNextLoss = find(lossGamWinNext.trial == 2 & lossGamWinNext.safe <0 & lossGamWinNext.riskyGain==0 & lossGamWinNext.riskyLoss<0); % loss trials (2343)
lossGamWinNextMix  = find(lossGamWinNext.trial == 2 & lossGamWinNext.safe ==0 & lossGamWinNext.riskyGain>0 & lossGamWinNext.riskyLoss<0); % mixed trials (1903)

% and average gambling on those trials was:
mean(firstPlayTable.choice(lossGamWinNextGain)); %0.6181
mean(firstPlayTable.choice(lossGamWinNextLoss)); %0.6206
mean(firstPlayTable.choice(lossGamWinNextMix));  %0.6190

% following loss trial win (outcome = 0) --> gambling is roughly the same
% on gain and mixed trials and slightly higher on loss trials

% T-1 LOSS, GAMBLE, LOSS
% t = gain gambled
% t = loss gambled
% t = mixed gambled

% index for all t-1: lossGamLoss1
% index  for all t: lossGamLoss1+1

lossGamLossNext = firstPlayTable(lossGamLoss1 + 1,:); % all trials following a loss trial, gamble loss

% When previous trial was loss trial type and participants gambled and
% loss the following trials were...
lossGamLossNextGain = find(lossGamLossNext.trial == 2 & lossGamLossNext.safe >0 & lossGamLossNext.riskyGain>0 & lossGamLossNext.riskyLoss==0); % gain trials (2522)
lossGamLossNextLoss = find(lossGamLossNext.trial == 2 & lossGamLossNext.safe <0 & lossGamLossNext.riskyGain==0 & lossGamLossNext.riskyLoss<0); % loss trials (2281)
lossGamLossNextMix  = find(lossGamLossNext.trial == 2 & lossGamLossNext.safe ==0 & lossGamLossNext.riskyGain>0 & lossGamLossNext.riskyLoss<0); % mixed trials (1726)

% and average gambling on those trials was:
mean(firstPlayTable.choice(lossGamLossNextGain)); %0.6086
mean(firstPlayTable.choice(lossGamLossNextLoss)); %0.6199
mean(firstPlayTable.choice(lossGamLossNextMix));  %0.6101

% following loss trial loss (avg outcome -97) --> gambling is highest for
% loss trials and lowest for gain trials although the differences are small

% T-1 MIXED, GAMBLE, WIN
% t = gain gambled
% t = loss gambled
% t = mixed gambled

% index for all t-1: mixedGamWin1
% index  for all t: mixedGamWin1+1

mixedGamWinNext = firstPlayTable(mixedGamWin1 + 1,:); % all trials following a mixed trial, gamble loss

% When previous trial was mixed trial type and participants gambled and
% win the following trials were...
mixedGamWinNextGain = find(mixedGamWinNext.trial == 2 & mixedGamWinNext.safe >0 & mixedGamWinNext.riskyGain>0 & mixedGamWinNext.riskyLoss==0); % gain trials (1826)
mixedGamWinNextLoss = find(mixedGamWinNext.trial == 2 & mixedGamWinNext.safe <0 & mixedGamWinNext.riskyGain==0 & mixedGamWinNext.riskyLoss<0); % loss trials (1982)
mixedGamWinNextMix  = find(mixedGamWinNext.trial == 2 & mixedGamWinNext.safe ==0 & mixedGamWinNext.riskyGain>0 & mixedGamWinNext.riskyLoss<0); % mixed trials (1228)

% and average gambling on those trials was:
mean(firstPlayTable.choice(mixedGamWinNextGain)); %0.6002
mean(firstPlayTable.choice(mixedGamWinNextLoss)); %0.5928
mean(firstPlayTable.choice(mixedGamWinNextMix));  %0.6059

% following a mixed trial win (avg outcome =57) --> risk-taking is very
% similar across gain, loss and mixed trials (slighly slower on current loss)


% T-1 MIXED, GAMBLE, LOSS
% t = gain gambled
% t = loss gambled
% t = mixed gambled

% index for all t-1: mixedGamLoss1
% index  for all t: mixedGamLoss1+1

mixedGamLossNext = firstPlayTable(mixedGamLoss1 + 1,:); % all trials following a mixed trial, gamble loss

% When previous trial was mixed trial type and participants gambled and
% loss the following trials were...
mixedGamLossNextGain = find(mixedGamLossNext.trial == 2 & mixedGamLossNext.safe >0 & mixedGamLossNext.riskyGain>0 & mixedGamLossNext.riskyLoss==0); % gain trials (1871)
mixedGamLossNextLoss = find(mixedGamLossNext.trial == 2 & mixedGamLossNext.safe <0 & mixedGamLossNext.riskyGain==0 & mixedGamLossNext.riskyLoss<0); % loss trials (1916)
mixedGamLossNextMix  = find(mixedGamLossNext.trial == 2 & mixedGamLossNext.safe ==0 & mixedGamLossNext.riskyGain>0 & mixedGamLossNext.riskyLoss<0); % mixed trials (1267)

% and average gambling on those trials was:
mean(firstPlayTable.choice(mixedGamLossNextGain)); %0.5949
mean(firstPlayTable.choice(mixedGamLossNextLoss)); %0.6044
mean(firstPlayTable.choice(mixedGamLossNextMix));  %0.5927

% Following a mixed trial loss, risk-taking is slighly higher on a loss
% trial relative to gain and mixed trial although differences are small


% Risk-taking on a gain trial when previous trial was...
    % gain gamble win   = 0.6044
    % gain gamble loss  = 0.6135
    % loss gamble win   = 0.6181
    % loss gamble loss  = 0.6086
    % mixed gamble win  = 0.6002
    % mixed gamble loss = 0.5949

% Risk-taking on a loss trial when previous trial was...
    % gain gamble win   = 0.6213
    % gain gamble loss  = 0.5969
    % loss gamble win   = 0.6206
    % loss gamble loss  = 0.6199
    % mixed gamble win  = 0.5928
    % mixed gamble loss = 0.6044

% Risk-taking on a mixed trial when previous trial was...
    % gain gamble win   = 0.6066
    % gain gamble loss  = 0.6210
    % loss gamble win   = 0.6190
    % loss gamble loss  = 0.6101
    % mixed gamble win  = 0.6059
    % mixed gamble loss = 0.5927

% TO DO: PLOT this stuff!
