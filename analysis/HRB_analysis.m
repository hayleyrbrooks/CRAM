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


nT = 30; % 30 trials
pgamPrevTrialsOnly = array2table(NaN(30,9));
pgamPrevTrialsOnly.Properties.VariableNames={'gainGamWin' 'gainGamLose' 'gainSafe' 'lossGamWin' 'lossGamLose' 'lossSafe' 'mixGamWin' 'mixGamLose' 'mixSafe'};


for t=2:nT % 2-30 bc there is no prev trial before 1


    % PREVIOUS TRIAL WAS GAIN WIN
    PrevGainWinInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain); 
    pgamPrevTrialsOnly.gainGamWin(t)= mean(firstPlayTable.choice(PrevGainWinInd+1));
    
    % PREVIOUS TRIAL WAS GAIN LOSS
    PrevGainLoseInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 
    pgamPrevTrialsOnly.gainGamLose(t)= mean(firstPlayTable.choice(PrevGainLoseInd+1));
    
    % PREVIOUS TRIAL WAS GAIN SAFE
     PrevGainSafeInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.safe); 
    pgamPrevTrialsOnly.gainSafe(t)= mean(firstPlayTable.choice(PrevGainSafeInd+1));
    
    % PREVIOUS TRIAL WAS LOSS WIN
     PrevLossWinInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); 
     pgamPrevTrialsOnly.lossGamWin(t)= mean(firstPlayTable.choice(PrevLossWinInd+1));

    % PREVIOUS TRIAL WAS LOSS LOSE
    PrevLossLoseInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 
    pgamPrevTrialsOnly.lossGamLose(t)= mean(firstPlayTable.choice(PrevLossLoseInd+1));
    
    % PREVIOUS TRIAL WAS LOSS SAFE
    PrevLossSafeInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); 
    pgamPrevTrialsOnly.lossSafe(t)= mean(firstPlayTable.choice(PrevLossSafeInd+1));
    
    %PREVIOUS TRIAL WAS MIX WIN
    PrevMixGainInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain); 
    pgamPrevTrialsOnly.mixGamWin(t)= mean(firstPlayTable.choice(PrevMixGainInd+1));
    
    %PREVIOUS TRIAL WAS MIX LOSS
    PrevMixLossInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss); 
    pgamPrevTrialsOnly.mixGamLose(t)= mean(firstPlayTable.choice(PrevMixLossInd+1));
    
    % PREVIOUS TRIAL WAS MIX SAFE
    PrevMixSafeInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe==0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.safe); 
    pgamPrevTrialsOnly.mixSafe(t)= mean(firstPlayTable.choice(PrevMixSafeInd+1));
    
end

f1=plot(pgamPrevTrialsOnly.gainGamWin, 'color', 'green', 'marker', "o", 'markersize',9, "linewidth", 2); 
hold on
title('P(gamble) on trial (t) as function of previous trial type and outcome');
plot(pgamPrevTrialsOnly.gainGamLose, 'color', 'green', 'marker', "+", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrialsOnly.gainSafe, 'color','green', 'marker', "*", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrialsOnly.lossGamWin, 'color', 'red', 'marker', "o", 'markersize',9, "linewidth", 2);
plot(pgamPrevTrialsOnly.lossGamLose, 'color', 'red', 'marker', "+", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrialsOnly.lossSafe, 'color', 'red', 'marker', "*", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrialsOnly.mixGamWin, 'color', 'blue', 'marker', "o", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrialsOnly.mixGamLose, 'color', 'blue', 'marker', "+", 'markersize',9, "linewidth", 2); 
plot(pgamPrevTrialsOnly.mixSafe, 'color', 'blue', 'marker', "*", 'markersize',9, "linewidth", 2); 
legend({'t-1 gain win', 't-1 gain lose', 't-1 gain safe', 't-1 loss win', 't-1 loss lose', 't-1 loss safe', 't-1 mix win', 't-1 mix lose', 't-1 mix safe'}, 'Location', 'southwest', 'FontSize', 16);
xlabel("trial number")
ylabel("p(gamble)")



% Interim summary
% Looking at risk-taking as a function of previous trial
% type/choice/outcome (not considering current trialstuff ):
% 1) Overall, there is less risk-taking following safe outcomes across all
% trial types and risk-taking following a safe outcome decreases over the task. 
% Perhaps this is because people who choose safe at first are more likley to continue to choose safe across
% the task? Across safe outcomes, there is a larger difference in risk-taking
% following a loss safe outcome (negative value) relative to gain safe and
% mix safe (outcome >=0).
% Ignoring safe outcomes: Risk-taking is consistently higher following loss
% trials and is lowest following a gain win.
% Toward the end of the task, a more apprent pattern emerges with
% risk-taking being highest following losses, middle following mixed trials
% and lowest following gain trials.



%% look at pgamble as a function of previous trial type and outcome splitting up outcomes by amount and focusing on loss and gain types

nT = 30; % 30 trials
pgamsByAmt = array2table(NaN(30,6));
pgamsByAmt.Properties.VariableNames= {'gainLarge' 'gainMed' 'gainZero' 'lossLarge' 'lossMed' 'lossZero'};

for t=2:nT % 2-30 bc there is no prev trial before 1
    
    % PREVIOUS TRIAL WAS A LARGE GAIN
    PrevGainLargeInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome>=100);
    pgamsByAmt.gainLarge(t)= mean(firstPlayTable.choice(PrevGainLargeInd+1));
    
    % PREVIOUS TRIAL WAS A MEDIUM GAIN
    PrevGainMedInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyGain & firstPlayTable.outcome<100 & firstPlayTable.outcome>0);
    pgamsByAmt.gainMed(t)= mean(firstPlayTable.choice(PrevGainMedInd+1));
    
    % PREVIOUS TRIAL WAS A GAIN ZERO (loss)
    PrevGainZeroInd = find(firstPlayTable.trial== t-1 & firstPlayTable.safe>0 & firstPlayTable.riskyGain>0 & firstPlayTable.riskyLoss==0 & firstPlayTable.outcome==firstPlayTable.riskyLoss);
    pgamsByAmt.gainZero(t) = mean(firstPlayTable.choice(PrevGainZeroInd+1)); 
    
    % PREVIOUS TRIAL WAS LARGE LOSS
    PrevLossLargeInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome<=-100);
    pgamsByAmt.lossLarge(t)= mean(firstPlayTable.choice(PrevLossLargeInd+1));
    
    % PREVIOUS TRIAL WAS MEDIUM LOSS
    PrevLossMedInd= find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyLoss & firstPlayTable.outcome>-100 & firstPlayTable.outcome<0);
    pgamsByAmt.lossMed(t)= mean(firstPlayTable.choice(PrevLossMedInd+1));
    
    % PREVIOUS TRIAL WAS LOSS ZERO (win)
    PrevLossZeroInd = find(firstPlayTable.trial== t-1 & firstPlayTable.safe<0 & firstPlayTable.riskyGain==0 & firstPlayTable.riskyLoss<0 & firstPlayTable.outcome==firstPlayTable.riskyGain);
    pgamsByAmt.lossZero(t) = mean(firstPlayTable.choice(PrevLossZeroInd+1));
    
end





%

figure

plot(pgamsByAmt.gainLarge(:), 'color', 'green', 'marker', "+", 'markersize',9, "linewidth", 2); % large gain amount
hold on
plot(pgamsByAmt.gainMed(:), 'color', 'green', 'marker', "o", 'markersize',9, "linewidth", 2); % small-med gain amount
plot(pgamsByAmt.gainZero(:), 'color', 'green', 'marker', "*", 'markersize',9, "linewidth", 2); % gain amount = 0 (loss)
plot(pgamsByAmt.lossLarge(:), 'color', 'red', 'marker', "o", 'markersize',9, "linewidth", 2); % large loss amount
plot(pgamsByAmt.lossMed(:),'color', 'red', 'marker', "+", 'markersize',9, "linewidth", 2); % small-med loss amount
plot(pgamsByAmt.lossZero(:),'color', 'red', 'marker', "*", 'markersize',9, "linewidth", 2); % loss amount = 0 (win)
title('P(gamble) on trials as a function of previous outcome amount');
xlabel('trial number')
ylabel('p(gamble)')
legend({'t-1 gain>=100' 't-1 gain 0>100' 't-1 gain=0' 't-1 loss <=-100' 't-1 loss -100>0' 't-1 loss=0' }, 'Location', 'northwest');


%interim summary
% Across the task, there is more risk-taking following loss outcomes and
% less rik-taking following gain outcomes. 
% ACross all outcomes/trial types, risk-taking is lowest following large
% gain outcomes.
% ACross previous loss trials, risk-taking is highest following
% really high losses or losses of zeroes (not sure what to make of this)
% it looks like people are treating previous loss wins (outcome = 0)
% different than previous gain losses (outcome 0) - cool! 

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



%{ 
When looking at risk-taking as a function of just previous trial stuff, 
there is generally more risk-taking following gains and less risk-taking 
following losses. However, when taking into consideration both previous and 
current trials, there is actually more risk-taking following gain trials and 
less risk-taking following loss trials on both current gain and loss trials?
%}


