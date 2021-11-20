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

% Index these first trial variations:

gainGamWin= find(firstPlayTable.trial == 1 & firstPlayTable.safe >0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain);
% 5977 first trials where trial was gain type and participant gambled and
% won
% mean outcome amount for this type of trials = 103

% pgamble on next trial:
mean(firstPlayTable.choice(gainGamWin+1)); %  0.6737


gainGamLoss = find(firstPlayTable.trial == 1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss);
%5812 first trials where trial was gain type and participant gambled and
%lost

% mean outcome amount for this type of trial = 0

% pgamble on next trial:
mean(firstPlayTable.choice(gainGamLoss+1)); % 0.7266


gainSafe = find(firstPlayTable.trial == 1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.safe);
% 5562 first trials where trial was gain type and participant chose safe
% option

% mean outcome amount for this type of trial = 44

% pgamble on next trial:
mean(firstPlayTable.choice(gainSafe+1)) % 0.6235


lossGamWin = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain);
% 6778 first trials where trial was loss type and participants gambled and
% won

% mean outcome amount for this type of trial = 0
% pgamble on next trial:
mean(firstPlayTable.choice(lossGamWin+1)) % 0.7307

lossGamLoss = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss);
%6529 first trials where trial was loss type and participants gambled and
%loss

% mean outcome amount for this type of trial = -99
% pgamble on next trial:
mean(firstPlayTable.choice(lossGamLoss+1)) % 0.7059


lossSafe = find(firstPlayTable.trial == 1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe);
% 3772 first trials where trial was loss type and participants chose safe

% mean outcome amount for this type of trial = -43
% pgamble on next trial:
mean(firstPlayTable.choice(lossGamSafe+1)) %0.6307


mixedGamWin = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain);
%5036 first trials where trial was mixed valence and participants gambled
%and won

% mean outcome amount for this type of trial = 57

% pgamble on next trial:
mean(firstPlayTable.choice(mixedGamWin+1)) %0.6962

mixedGamLoss = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss);
%5054 first trials where trial was mixed valenced and participants gambled
%and lost
% mean outcome amount for this type of trial = -49

% pgamble on next trial:
mean(firstPlayTable.choice(mixedGamLoss+1)) %0.7068

mixedSafe = find(firstPlayTable.trial == 1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe);
%2547 first trials where trials was mixed valence and participants took
%safe

% mean outcome amount for this type of trial = 0
% pgamble on next trial:
mean(firstPlayTable.choice(mixedSafe+1)); %0.6368


% interim summary: 
% relative to 0 on a mixed trial with safe outcome, risk-taking increases 
% after a 0 on a loss (i.e. 0 is a win) and gain (i.e. 0 is a loss) trial 
% but there is a very small difference between risk-taking after a 0 on a 
% loss and gain trial. 

% following gain trials, risk-taking was highest when the outcome was a loss, then a win,
% then a safe

% following loss trials, risk-taking was highest when the outcome was a
% win, then a loss, then a safe

% following mixed trials, risk-taking was highest when the outcome was a win, then loss, then safe
% but  the difference between win and loss outcomes in the mixed valece
% trial is very small.


% Check the same pattern, but look at the 2nd and 3rd trials





% additional analyses to do:
% looking at relationship between gambling and life satisfaction
% these are basic correlations - will want to check regressions and look at
% effect sizes
% for example: is life satisfaction related to pgamble?
[r, pval] = corr(subInfo.lifeSat, subInfo.totalGam)
