% replay - run this to replay a specific agent

%% load agent 

load('Agent9-6-2.mat',"saved_agent")
% load('Agent9-6-2.mat')

%% run

setUp_main;
simRL=true;
agent=saved_agent;
twoCars=(rlStage==2);
plotTrack;
