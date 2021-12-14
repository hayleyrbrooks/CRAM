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



%% saving stuff - don't need to do this everytime unless we change the tables
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
lossGamLoss1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %6529 trials, -99 mean outcome
lossGamLoss2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5707 trials, -97 mean outcome
lossGamLoss3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5198 trials, -96 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.lossGamLoss(1) = mean(firstPlayTable.choice(lossGamLoss1+1)); % 0.7059
pgams.lossGamLoss(2) = mean(firstPlayTable.choice(lossGamLoss2+1)); % 0.7069
pgams.lossGamLoss(3) = mean(firstPlayTable.choice(lossGamLoss3+1)); % 0.7384


% loss trials, safe (these are trials 1-3)
lossSafe1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %3772 trials, -43 mean outcome
lossSafe2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %6040 trials, -43 mean outcome
lossSafe3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %6937 trials, -43 mean outcome

% pgamble on next trial (these are trials 2-4):
pgams.lossSafe(1) = mean(firstPlayTable.choice(lossSafe1+1)); %0.6307
pgams.lossSafe(2) = mean(firstPlayTable.choice(lossSafe2+1)); %0.6555
pgams.lossSafe(3) = mean(firstPlayTable.choice(lossSafe3+1)); %0.6494


% mixed trials, gamble win (these are trials 1-3)
mixedGamWin1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %5036 trials, 57 mean outcome
mixedGamWin2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %4801 trials, 58 mean outcome
mixedGamWin3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); %4750 trials, 57 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.mixedGamWin(1) = mean(firstPlayTable.choice(mixedGamWin1+1)); %0.6962
pgams.mixedGamWin(2) = mean(firstPlayTable.choice(mixedGamWin2+1)); %0.6657
pgams.mixedGamWin(3) = mean(firstPlayTable.choice(mixedGamWin3+1)); %0.6838


% mixed trials, gamble loss (these are trials 1-3)
mixedGamLoss1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %5054 trials, -49 mean outcome
mixedGamLoss2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %4831 trials, -47 mean outcome
mixedGamLoss3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); %4661 trials, -47 mean outcome

% pgamble on next trial (these are trials 2-4)
pgams.mixedGamLoss(1) = mean(firstPlayTable.choice(mixedGamLoss1+1)); %0.7068
pgams.mixedGamLoss(2) = mean(firstPlayTable.choice(mixedGamLoss2+1)); %0.6643
pgams.mixedGamLoss(3) = mean(firstPlayTable.choice(mixedGamLoss3+1)); %0.6953


% mixed trials, safe (these are trials 1-3, mean outcome =0)
mixedSafe1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %2547 trials
mixedSafe2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %3011 trials
mixedSafe3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); %3147 trials

% pgamble on next trial (these are trials 2-4)
pgams.mixedSafe(1) = mean(firstPlayTable.choice(mixedSafe1+1)); %0.6368
pgams.mixedSafe(2) = mean(firstPlayTable.choice(mixedSafe2+1)); %0.6054
pgams.mixedSafe(3) = mean(firstPlayTable.choice(mixedSafe3+1)); %0.6107


% plot 6 lines across trials 2-4 (green = gain trial; red = loss trial;
% blue =  mixed trial; + = win outcome and o = loss outcome)'
% not plotting previous safe trials
figure

f1 = plot(pgams{:,1}, 'color', 'green', 'marker', "+", 'markersize',9, "linewidth", 2); % gain gamble win
hold on
plot(pgams{:,2}, 'color', 'green', 'marker', "o", 'markersize',9, "linewidth", 2); % gain gamble loss
%plot(pgams{:,3},  'color', 'green', 'marker', "*", 'markersize',9, "linewidth", 2); % gain safe
plot(pgams{:,4}, 'color', 'red', 'marker', "+", 'markersize',9, "linewidth", 2); % loss gamble win
plot(pgams{:,5}, 'color', 'red', 'marker', "o", 'markersize',9, "linewidth", 2); % loss gamble loss
%plot(pgams{:,6}, 'color', 'red', 'marker', "*", 'markersize',9, "linewidth", 2); % loss safe
plot(pgams{:,7},'color', 'blue', 'marker', "+", 'markersize',9, "linewidth", 2); % mixed gamble win
plot(pgams{:,8},'color', 'blue', 'marker', "o", 'markersize',9, "linewidth", 2); % mixed gamble loss
%plot(pgams{:,9},'color', 'blue', 'marker', "*", 'markersize',9, "linewidth", 2); % mixed safe
title('P(gamble) on trials 2-4');
xticklabels({'2','','','','','3','','','','','4'})
xlabel('trial number')
ylabel('p(gamble)')
legend({'t-1 gain win' 't-1 gain lose' 't-1 loss win' 't-1 loss lose' 't-1 mix win' 't-1 mix lose' }, 'Location', 'northwest');


% Interim summary
% Across trials 2-4 there is a decent amount of variability in pgamble
% as a function of previous trial type and outcome (not taking into consideration current
% trial). However, there are three patterns that may be worth following up
% on. First, it looks like people generally take more risks following a
% loss trial and risk-taking is higher following a loos win relative to a
% loss lose. Second, there is a consistently large difference between
% risk-taking following a gain trial where risk-taking is low following a
% gain win relative to a gain loss. hird, it looks like there could be a
% difference in how people behave following a gain lose (0) and a loss win
% (0). There does not appear to be much of a consistent difference in gambling following a mixed trial.



%% look at pgamble as a functio of previous trial type and outcome splitting up outcomes by amount and focusing on loss and gain types


pgamsByAmt = NaN(4,6); % rows are trials 2-5 and columns are the various trial type outcome combinations
pgamsByAmt = array2table(pgamsByAmt);
pgamsByAmt.Properties.VariableNames= {'gainLarge' 'gainMed' 'gainZero' 'lossLarge' 'lossMed' 'lossZero'};




% pull out previous trial stuff
% groups of gain outcomes (0,1-99, 100+)
% trial 1
gainLargeOC1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome>=100); %3025 trials, 128 mean outcome; range = 100-220
gainMedOC1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain & firstPlayTable.outcome<100 & firstPlayTable.outcome>0);%  2952 trials, 76 mean outcome;
gainZeroOC1 = gainGamLoss1;

% pgamble on next trial following gain outcome (trial 2)
pgamsByAmt.gainLarge(1) = mean(firstPlayTable.choice(gainLargeOC1+1)); %  
pgamsByAmt.gainMed(1) = mean(firstPlayTable.choice(gainMedOC1+1)); %
pgamsByAmt.gainZero(1) = mean(firstPlayTable.choice(gainZeroOC1+1)); % 


% trial 2
gainLargeOC2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome>=100); %2912   trials, 129 mean outcome; range = 100-220
gainMedOC2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain & firstPlayTable.outcome<100 & firstPlayTable.outcome>0);%  2834  trials, 78 mean outcome;
gainZeroOC2 = gainGamLoss2;

% pgamble on next trial following gain outcome (trial 3)
pgamsByAmt.gainLarge(2) = mean(firstPlayTable.choice(gainLargeOC2+1)); %  
pgamsByAmt.gainMed(2) = mean(firstPlayTable.choice(gainMedOC2+1)); %
pgamsByAmt.gainZero(2) = mean(firstPlayTable.choice(gainZeroOC2+1)); % 


% trial 3
gainLargeOC3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome>=100); %3054 trials, 129 mean outcome; range = 100-220
gainMedOC3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain & firstPlayTable.outcome<100 & firstPlayTable.outcome>0);%   2869  trials, 78 mean outcome;
gainZeroOC3 = gainGamLoss3;

% pgamble on next trial following gain outcome (trial 4)
pgamsByAmt.gainLarge(3) = mean(firstPlayTable.choice(gainLargeOC3+1)); %  
pgamsByAmt.gainMed(3) = mean(firstPlayTable.choice(gainMedOC3+1)); %
pgamsByAmt.gainZero(3) = mean(firstPlayTable.choice(gainZeroOC3+1)); % 


% trial 4
gainLargeOC4 = find(firstPlayTable.trial == 4 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome>=100); 
gainMedOC4 = find(firstPlayTable.trial == 4 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain & firstPlayTable.outcome<100 & firstPlayTable.outcome>0);
gainZeroOC4 = find(firstPlayTable.trial == 4 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 

% pgamble on next trial following gain outcome (trial 5)
pgamsByAmt.gainLarge(4) = mean(firstPlayTable.choice(gainLargeOC4+1)); %  
pgamsByAmt.gainMed(4) = mean(firstPlayTable.choice(gainMedOC4+1)); %
pgamsByAmt.gainZero(4) = mean(firstPlayTable.choice(gainZeroOC4+1)); % 

% groups of loss outcomes (-0, -1-99, -100+)
% trial 1
lossLargeOC1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome<=-100);% 2933 trials, mean = -128; range = -100 - -220
lossMedOC1 = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss & firstPlayTable.outcome>-100 & firstPlayTable.outcome<0); %3596  trials, -76 mean outcome
lossZeroOC1 = lossGamLoss1;

% pgamble on next trial following loss outcome (trial 2)
pgamsByAmt.lossLarge(1) = mean(firstPlayTable.choice(lossLargeOC1+1)); %  
pgamsByAmt.lossMed(1) = mean(firstPlayTable.choice(lossMedOC1+1)); %
pgamsByAmt.lossZero(1) = mean(firstPlayTable.choice(lossZeroOC1+1)); % 

% trial 2
lossLargeOC2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome<=-100);%2378 trials, mean = -127; range = -100 - -220
lossMedOC2 = find(firstPlayTable.trial == 2 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss & firstPlayTable.outcome>-100 & firstPlayTable.outcome<0); %3329 trials, -76 mean outcome
lossZeroOC2 = lossGamLoss2;

% pgamble on next trial following loss outcome (trial 3)
pgamsByAmt.lossLarge(2) = mean(firstPlayTable.choice(lossLargeOC2+1)); %  
pgamsByAmt.lossMed(2) = mean(firstPlayTable.choice(lossMedOC2+1)); %
pgamsByAmt.lossZero(2) = mean(firstPlayTable.choice(lossZeroOC2+1)); % 

% trial 3
lossLargeOC3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome<=-100); % 2078 trials, mean = -127; range = -100 - -220
lossMedOC3 = find(firstPlayTable.trial == 3 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss & firstPlayTable.outcome>-100 & firstPlayTable.outcome<0); % 3120 trials, -76 mean outcome
lossZeroOC3 = lossGamLoss3;

% pgamble on next trial following loss outcome (trial 4)
pgamsByAmt.lossLarge(3) = mean(firstPlayTable.choice(lossLargeOC3+1)); %  
pgamsByAmt.lossMed(3) = mean(firstPlayTable.choice(lossMedOC3+1)); %
pgamsByAmt.lossZero(3) = mean(firstPlayTable.choice(lossZeroOC3+1)); % 


% trial 4
lossLargeOC4 = find(firstPlayTable.trial == 4 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome<=-100);
lossMedOC4 = find(firstPlayTable.trial == 4 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss & firstPlayTable.outcome>-100 & firstPlayTable.outcome<0); 
lossZeroOC4 = find(firstPlayTable.trial == 4 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss);


% pgamble on next trial following loss outcome (trial 5)
pgamsByAmt.lossLarge(4) = mean(firstPlayTable.choice(lossLargeOC4+1)); %  
pgamsByAmt.lossMed(4) = mean(firstPlayTable.choice(lossMedOC4+1)); %
pgamsByAmt.lossZero(4) = mean(firstPlayTable.choice(lossZeroOC4+1)); %

figure

plot(pgamsByAmt{:,1}, 'color', 'green', 'marker', "+", 'markersize',9, "linewidth", 2); % large gain amount
hold on
plot(pgamsByAmt{:,2}, 'color', 'green', 'marker', "o", 'markersize',9, "linewidth", 2); % small-med gain amount
plot(pgamsByAmt{:,3}, 'color', 'green', 'marker', "*", 'markersize',9, "linewidth", 2); % gain amount = 0 (loss)
plot(pgamsByAmt{:,4}, 'color', 'red', 'marker', "o", 'markersize',9, "linewidth", 2); % large loss amount
plot(pgamsByAmt{:,5},'color', 'red', 'marker', "+", 'markersize',9, "linewidth", 2); % small-med loss amount
plot(pgamsByAmt{:,6},'color', 'red', 'marker', "*", 'markersize',9, "linewidth", 2); % loss amount = 0 (win)
title('P(gamble) on trials 2-5');
xticklabels({'2','','3','','4','','5'})
xlabel('trial number')
ylabel('p(gamble)')
legend({'t-1 gain>=100' 't-1 gain 0>100' 't-1 gain=0' 't-1 loss <=-100' 't-1 loss -100>0' 't-1 loss=0' }, 'Location', 'northwest');


%interim summary
% Across trials 2-5, it looks like there could be some pattern emerging where risk-taking is generally higher following losses
% and lower following gains. 
% Risk-taking is consistently the lowest following a
% large win
% this matches patterns from SH lab data.

%% Look at p(gamble) as a function of current trial type and previous trial type/choice/outcome
% will focus on gain and loss previous outcomes (and not safe) for right
% now.

% for each trial, note the trial type with 1 and others =0
firstPlayTable.mixType(firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0)=1; % current mix trial
firstPlayTable.lossType(firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0)=1; % current loss trial
firstPlayTable.gainType(firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0)=1; % current gain trial



nT = 30; % 30 trials
pgamPrevTrials = array2table(NaN(30,22));
pgamPrevTrials.Properties.VariableNames ={'allCurrTypes' 
                                           'allCurrGain' 
                                           'allCurrLoss' 
                                           'allCurrMix' 
                                           
                                           'currGainPrevGainWin'
                                           'currGainPrevGainLose'
                                           'currGainPrevLossWin'
                                           'currGainPrevLossLose'
                                           'currGainPrevMixWin'
                                           'currGainPrevMixLose'
                                           
                                           'currLossPrevGainWin'
                                           'currLossPrevGainLose'
                                           'currLossPrevLossWin'
                                           'currLossPrevLossLose'
                                           'currLossPrevMixWin'
                                           'currLossPrevMixLose'
                                           
                                           'currMixPrevGainWin'
                                           'currMixPrevGainLose'
                                           'currMixPrevLossWin'
                                           'currMixPrevLossLose'
                                           'currMixPrevMixWin'
                                           'currMixPrevMixLose'
                                           
                                           };

for t=2:nT % 2-30 bc there is no prev trial before 1
    currTrialInd = find(firstPlayTable.trial==t); % index of current trial
    prevTrialInd = find(firstPlayTable.trial==t-1); % index of previous trial
     
%     if size(currTrialInd) ~= size(prevTrialInd)
%         fprintf('current trial vector != previous trial vector for trial number %i\n',t)
%     end %double checking that vectors for current and previous trials are same size
%     
   
    
    currGainInd = find(firstPlayTable.trial==t & firstPlayTable.safe >0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0); % index current gain trials
    currLossInd = find(firstPlayTable.trial==t & firstPlayTable.safe <0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0); % index current loss trials
    currMixInd = find(firstPlayTable.trial==t & firstPlayTable.safe ==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0);  % index current mix trials
    
    pgamPrevTrials.allCurrTypes(t) = mean(firstPlayTable.choice(currTrialInd)); % pgamble across all current trials
    pgamPrevTrials.allCurrGain(t) = mean(firstPlayTable.choice(currGainInd));   % pgamble across all current gain trials
    pgamPrevTrials.allCurrLoss(t) = mean(firstPlayTable.choice(currLossInd));   % pgamble across all current loss trials
    pgamPrevTrials.allCurrMix(t) = mean(firstPlayTable.choice(currMixInd));     % pgamble across all current mix trials


    % PREVIOUS TRIAL WAS GAIN WIN
    PrevGainWinInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain); 
    
    % current trial is mix
    currMixPrevGainWinInd = find(firstPlayTable.mixType(PrevGainWinInd + 1)==1); % index current mix trials following a gain win  
    pgamPrevTrials.currMixPrevGainWin(t) = mean(firstPlayTable.choice(currMixPrevGainWinInd));
    
    % current trial is loss
    currLossPrevGainWinInd = find(firstPlayTable.lossType(PrevGainWinInd + 1)==1); % index current loss trials following a gain win  
    pgamPrevTrials.currLossPrevGainWin(t) = mean(firstPlayTable.choice(currLossPrevGainWinInd));
    
    %current trial is gain
    currGainPrevGainWinInd = find(firstPlayTable.gainType(PrevGainWinInd + 1)==1); % index current gain trials following a gain win  
    pgamPrevTrials.currGainPrevGainWin(t) = mean(firstPlayTable.choice(currGainPrevGainWinInd));
    
    
    
    % PREVIOUS TRIAL WAS GAIN LOSS
    PrevGainLoseInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 
    
    % current trial is mix
    currMixPrevGainLoseInd = find(firstPlayTable.mixType(PrevGainLoseInd + 1)==1); % index current mix trials following a gain loss  
    pgamPrevTrials.currMixPrevGainLose(t) = mean(firstPlayTable.choice(currMixPrevGainLoseInd));
    
    % current trial is loss
    currLossPrevGainLoseInd = find(firstPlayTable.lossType(PrevGainLoseInd + 1)==1); % index current loss trials following a gain loss  
    pgamPrevTrials.currLossPrevGainLose(t) = mean(firstPlayTable.choice(currLossPrevGainLoseInd));
    
    %current trial is gain
    currGainPrevGainLoseInd = find(firstPlayTable.gainType(PrevGainLoseInd + 1)==1); % index current gain trials following a gain loss  
    pgamPrevTrials.currGainPrevGainLose(t) = mean(firstPlayTable.choice(currGainPrevGainLoseInd));
    
    
    
    % PREVIOUS TRIAL WAS LOSS WIN
     PrevLossWinInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); 
         
    % current trial is mix
    currMixPrevLossWinInd = find(firstPlayTable.mixType(PrevLossWinInd + 1)==1); % index current mix trials following a loss win  
    pgamPrevTrials.currMixPrevLossWin(t) = mean(firstPlayTable.choice(currMixPrevLossWinInd));
    
    % current trial is loss
    currLossPrevLossWinInd = find(firstPlayTable.lossType(PrevLossWinInd + 1)==1); % index current loss trials following a loss win  
    pgamPrevTrials.currLossPrevLossWin(t) = mean(firstPlayTable.choice(currLossPrevLossWinInd));
    
    %current trial is gain
    currGainPrevLossWinInd = find(firstPlayTable.gainType(PrevLossWinInd + 1)==1); % index current gain trials following a loss win  
    pgamPrevTrials.currGainPrevLossWin(t) = mean(firstPlayTable.choice(currGainPrevLossWinInd));
    
     
     
    % PREVIOUS TRIAL WAS LOSS LOSE
    PrevLossLoseInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 

    % current trial is mix
    currMixPrevLossLoseInd = find(firstPlayTable.mixType(PrevLossLoseInd + 1)==1); % index current mix trials following a loss loss  
    pgamPrevTrials.currMixPrevLossLose(t) = mean(firstPlayTable.choice(currMixPrevLossLoseInd));
    
    % current trial is loss
    currLossPrevLossLoseInd = find(firstPlayTable.lossType(PrevLossLoseInd + 1)==1); % index current loss trials following a loss loss  
    pgamPrevTrials.currLossPrevLossLose(t) = mean(firstPlayTable.choice(currLossPrevLossLoseInd));
    
    %current trial is gain
    currGainPrevLossLoseInd = find(firstPlayTable.gainType(PrevLossLoseInd + 1)==1); % index current gain trials following a loss loss  
    pgamPrevTrials.currGainPrevLossLose(t) = mean(firstPlayTable.choice(currGainPrevLossLoseInd));
    
    
    
    
    %PREVIOUS TRIAL WAS MIX WIN
    PrevMixGainInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); 

    % current trial is mix
    currMixPrevMixWinInd = find(firstPlayTable.mixType(PrevMixGainInd + 1)==1); % index current mix trials following a mix win  
    pgamPrevTrials.currMixPrevMixWin(t) = mean(firstPlayTable.choice(currMixPrevMixWinInd));
    
    % current trial is loss
    currLossPrevMixWinInd = find(firstPlayTable.lossType(PrevMixGainInd + 1)==1); % index current loss trials following a mix win  
    pgamPrevTrials.currLossPrevMixWin(t) = mean(firstPlayTable.choice(currLossPrevMixWinInd));
    
    %current trial is gain
    currGainPrevMixWinInd = find(firstPlayTable.gainType(PrevMixGainInd + 1)==1); % index current gain trials following a mix win  
    pgamPrevTrials.currGainPrevMixWin(t) = mean(firstPlayTable.choice(currGainPrevMixWinInd));
    
    
    
    
    %PREVIOUS TRIAL WAS MIX LOSS
    PrevMixLossInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 

    
    % current trial is mix
    currMixPrevMixLoseInd = find(firstPlayTable.mixType(PrevMixLossInd + 1)==1); % index current mix trials following a mix loss   
    pgamPrevTrials.currMixPrevMixLose(t) = mean(firstPlayTable.choice(currMixPrevMixLoseInd));
    
    % current trial is loss
    currLossPrevMixLoseInd = find(firstPlayTable.lossType(PrevMixLossInd + 1)==1); % index current loss trials following a mix loss  
    pgamPrevTrials.currLossPrevMixLose(t) = mean(firstPlayTable.choice(currLossPrevMixLoseInd));
    
    %current trial is gain
    currGainPrevMixLoseInd = find(firstPlayTable.gainType(PrevMixLossInd + 1)==1); % index current gain trials following a mix loss  
    pgamPrevTrials.currGainPrevMixLose(t) = mean(firstPlayTable.choice(currGainPrevMixLoseInd));
    
    
end


%% plot the results above
figure
% plot 18 lines above 
% current trial is gain type
subplot(3,2,1)
f1=plot(pgamPrevTrials.currGainPrevGainLose, 'color', [0, 0.4470, 0.7410], 'marker', "o", 'markersize',9, "linewidth", 2); 
hold on
title('P(gamble) on gain trial (t)');
plot(pgamPrevTrials.currGainPrevGainWin, 'color', [0.8500, 0.3250, 0.0980], 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrials.currGainPrevLossLose, 'color',[0.4940, 0.1840, 0.5560], 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrials.currGainPrevLossWin, 'color', [0.9290, 0.6940, 0.1250], 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrials.currGainPrevMixLose, 'color', [0.3010, 0.7450, 0.9330], 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrials.currGainPrevMixWin, 'color', [0.4660, 0.6740, 0.1880], 'marker', "o", 'markersize',9, "linewidth", 2); 

% current trial is loss type
subplot(3,2,3)
f2=plot(pgamPrevTrials.currLossPrevGainLose, 'color', [0, 0.4470, 0.7410], 'marker', "o", 'markersize',9, "linewidth", 2); 
hold on
title('P(gamble) on loss trial (t)');
plot(pgamPrevTrials.currLossPrevGainWin, 'color', [0.8500, 0.3250, 0.0980], 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrials.currLossPrevLossLose, 'color', [0.4940, 0.1840, 0.5560], 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrials.currLossPrevLossWin, 'color', [0.9290, 0.6940, 0.1250], 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrials.currLossPrevMixLose, 'color', [0.3010, 0.7450, 0.9330], 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrials.currLossPrevMixWin, 'color', [0.4660, 0.6740, 0.1880], 'marker', "o", 'markersize',9, "linewidth", 2); 


% current trial is mix type
subplot(3,2,5)
f3=plot(pgamPrevTrials.currMixPrevGainLose, 'color', [0, 0.4470, 0.7410], 'marker', "o", 'markersize',9, "linewidth", 2); 
title('P(gamble) on mix trial (t)');
hold on
plot(pgamPrevTrials.currMixPrevGainWin, 'color', [0.8500, 0.3250, 0.0980], 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrials.currMixPrevLossLose, 'color', [0.4940, 0.1840, 0.5560], 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrials.currMixPrevLossWin, 'color', [0.9290, 0.6940, 0.1250], 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrials.currMixPrevMixLose, 'color', [0.3010, 0.7450, 0.9330], 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrials.currMixPrevMixWin, 'color', [0.4660, 0.6740, 0.1880], 'marker', "o", 'markersize',9, "linewidth", 2); 




x = linspace(0, 1, 100)';
subplot(3,2,[2 4 6])
plot(x, nan)
legend({'t-1 gain lose', 't-1 gain win', 't-1 loss lose', 't-1 loss win', 't-1 mix lose', 't-1 mix win'}, 'Location', 'west', 'FontSize', 16);
axis off


% interim pattern
% not really seeing a big pattern emerge here, divide into bins of trials
% plotting trials 2-10, 11-20, 21-30 (not plotting trial 1 because there is
% no previous trial)



%% plotting pgamble on current trials as a function of current trial and previous trial
% collapse across trials 2-10, 11-20, and 21-30
figure
% current trial gain
subplot(3,2,1)
plot([mean(pgamPrevTrials.currGainPrevGainLose(2:10)) mean(pgamPrevTrials.currGainPrevGainLose(11:20)) mean(pgamPrevTrials.currGainPrevGainLose(21:30))],'color', [0, 0.4470, 0.7410], 'marker', "o", 'markersize',9, "linewidth", 2)
hold on
title('P(gamble) on current gain trials')
plot([mean(pgamPrevTrials.currGainPrevGainWin(2:10))  mean(pgamPrevTrials.currGainPrevGainWin(11:20))  mean(pgamPrevTrials.currGainPrevGainWin(21:30))],'color', [0.8500, 0.3250, 0.0980], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currGainPrevLossLose(2:10))  mean(pgamPrevTrials.currGainPrevLossLose(11:20))  mean(pgamPrevTrials.currGainPrevLossLose(21:30))],'color', [0.4940, 0.1840, 0.5560], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currGainPrevLossWin(2:10))  mean(pgamPrevTrials.currGainPrevLossWin(11:20))  mean(pgamPrevTrials.currGainPrevLossWin(21:30))],'color', [0.9290, 0.6940, 0.1250], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currGainPrevMixLose(2:10))  mean(pgamPrevTrials.currGainPrevMixLose(11:20))  mean(pgamPrevTrials.currGainPrevMixLose(21:30))],'color', [0.3010, 0.7450, 0.9330], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currGainPrevMixWin(2:10))  mean(pgamPrevTrials.currGainPrevMixWin(11:20))  mean(pgamPrevTrials.currGainPrevMixWin(21:30))],'color', [0.4660, 0.6740, 0.1880], 'marker', "o", 'markersize',9, "linewidth", 2)

% current trial loss
subplot(3,2,3)
plot([mean(pgamPrevTrials.currLossPrevGainLose(2:10)) mean(pgamPrevTrials.currGainPrevGainLose(11:20)) mean(pgamPrevTrials.currGainPrevGainLose(21:30))],'color', [0, 0.4470, 0.7410], 'marker', "o", 'markersize',9, "linewidth", 2)
hold on
title('P(gamble) on current loss trials')
plot([mean(pgamPrevTrials.currLossPrevGainWin(2:10))  mean(pgamPrevTrials.currLossPrevGainWin(11:20))  mean(pgamPrevTrials.currLossPrevGainWin(21:30))],'color', [0.8500, 0.3250, 0.0980], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currLossPrevLossLose(2:10))  mean(pgamPrevTrials.currLossPrevLossLose(11:20))  mean(pgamPrevTrials.currLossPrevLossLose(21:30))],'color', [0.4940, 0.1840, 0.5560], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currLossPrevLossWin(2:10))  mean(pgamPrevTrials.currLossPrevLossWin(11:20))  mean(pgamPrevTrials.currLossPrevLossWin(21:30))],'color', [0.9290, 0.6940, 0.1250], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currLossPrevMixLose(2:10))  mean(pgamPrevTrials.currLossPrevMixLose(11:20))  mean(pgamPrevTrials.currLossPrevMixLose(21:30))],'color', [0.3010, 0.7450, 0.9330], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currLossPrevMixWin(2:10))  mean(pgamPrevTrials.currLossPrevMixWin(11:20))  mean(pgamPrevTrials.currLossPrevMixWin(21:30))],'color', [0.4660, 0.6740, 0.1880], 'marker', "o", 'markersize',9, "linewidth", 2)


% current mix loss
subplot(3,2,5)
plot([mean(pgamPrevTrials.currMixPrevGainLose(2:10)) mean(pgamPrevTrials.currMixPrevGainLose(11:20)) mean(pgamPrevTrials.currMixPrevGainLose(21:30))],'color', [0, 0.4470, 0.7410], 'marker', "o", 'markersize',9, "linewidth", 2)
hold on
title('P(gamble) on current mix trials')
plot([mean(pgamPrevTrials.currMixPrevGainWin(2:10))  mean(pgamPrevTrials.currMixPrevGainWin(11:20))  mean(pgamPrevTrials.currMixPrevGainWin(21:30))],'color', [0.8500, 0.3250, 0.0980], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currMixPrevLossLose(2:10))  mean(pgamPrevTrials.currMixPrevLossLose(11:20))  mean(pgamPrevTrials.currMixPrevLossLose(21:30))],'color', [0.4940, 0.1840, 0.5560], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currMixPrevLossWin(2:10))  mean(pgamPrevTrials.currMixPrevLossWin(11:20))  mean(pgamPrevTrials.currMixPrevLossWin(21:30))],'color', [0.9290, 0.6940, 0.1250], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currMixPrevMixLose(2:10))  mean(pgamPrevTrials.currMixPrevMixLose(11:20))  mean(pgamPrevTrials.currMixPrevMixLose(21:30))],'color', [0.3010, 0.7450, 0.9330], 'marker', "o", 'markersize',9, "linewidth", 2)
plot([mean(pgamPrevTrials.currMixPrevMixWin(2:10))  mean(pgamPrevTrials.currMixPrevMixWin(11:20))  mean(pgamPrevTrials.currMixPrevMixWin(21:30))],'color', [0.4660, 0.6740, 0.1880], 'marker', "o", 'markersize',9, "linewidth", 2)


x = linspace(0, 1, 100)';
subplot(3,2,[2 4 6])
plot(x, nan)
legend({'t-1 gain lose', 't-1 gain win', 't-1 loss lose', 't-1 loss win', 't-1 mix lose', 't-1 mix win'}, 'Location', 'west', 'FontSize', 16, 'linewidth', 2);
axis off



% Interim summary
% On current gain and loss trials, it looks like risk-taking could be
% higher following gain trials (regardless of win or lose) relative to the
% other previous trial types and this difference seems to be largest in the
% middle of the task.





