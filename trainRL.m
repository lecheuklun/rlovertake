% trainRL - master script for RL training workflow

%% 1 SETUP & ENVIRONMENT
% defines RL environment and observations

setUpRLEnv;

%% 2 CRITIC
% defines critic

plotNets = 0;

% Define the network layers.
cnet = [
    featureInputLayer(numObs,"Normalization","none","Name","observation")
    fullyConnectedLayer(128,"Name","fc1")
    concatenationLayer(1,2,"Name","concat")
    reluLayer("Name","relu1")
    fullyConnectedLayer(64,"Name","fc3")
    reluLayer("Name","relu2")
    fullyConnectedLayer(32,"Name","fc4")
    reluLayer("Name","relu3")
    fullyConnectedLayer(1,"Name","CriticOutput")];
actionPath = [
    featureInputLayer(numAct,"Normalization","none","Name","action")
    fullyConnectedLayer(128,"Name","fc2")];

% Connect the layers.
criticNetwork = layerGraph(cnet);
criticNetwork = addLayers(criticNetwork, actionPath);
criticNetwork = connectLayers(criticNetwork,"fc2","concat/in2");

% View the critic neural network.
if plotNets
    plot(criticNetwork)
end

% When using two critics, a SAC agent requires them to have different initial parameters. Create and initialize two dlnetwork objects.
criticdlnet = dlnetwork(criticNetwork,'Initialize',false);
criticdlnet1 = initialize(criticdlnet);
criticdlnet2 = initialize(criticdlnet);
% Create the critic functions using rlQValueFunction.
critic1 = rlQValueFunction(criticdlnet1,obsInfo,actInfo, ...
    "ObservationInputNames","observation");
critic2 = rlQValueFunction(criticdlnet2,obsInfo,actInfo, ...
    "ObservationInputNames","observation");

%% 3 ACTOR
% Defines SAC actor

% Create the actor network layers.
anet = [
    featureInputLayer(numObs,"Normalization","none","Name","observation")
    fullyConnectedLayer(128,"Name","fc1")
    reluLayer("Name","relu1")
    fullyConnectedLayer(64,"Name","fc2")
    reluLayer("Name","relu2")];
meanPath = [
    fullyConnectedLayer(32,"Name","meanFC")
    reluLayer("Name","relu3")
    fullyConnectedLayer(numAct,"Name","mean")];
stdPath = [
    fullyConnectedLayer(numAct,"Name","stdFC")
    reluLayer("Name","relu4")
    softplusLayer("Name","std")];

% Connect the layers.
actorNetwork = layerGraph(anet);
actorNetwork = addLayers(actorNetwork,meanPath);
actorNetwork = addLayers(actorNetwork,stdPath);
actorNetwork = connectLayers(actorNetwork,"relu2","meanFC/in");
actorNetwork = connectLayers(actorNetwork,"relu2","stdFC/in");
% View the actor neural network.
if plotNets
    plot(actorNetwork)
end

% Create the actor function using rlContinuousGaussianActor.
actordlnet = dlnetwork(actorNetwork);
actor = rlContinuousGaussianActor(actordlnet, obsInfo, actInfo, ...
    "ObservationInputNames","observation", ...
    "ActionMeanOutputNames","mean", ...
    "ActionStandardDeviationOutputNames","std");

%% 4 AGENT
% defines agent with actor and critic

ewo=EntropyWeightOptions("TargetEntropy",-2,...
    "LearnRate",3e-4,...
    "EntropyWeight",1);

agentOpts = rlSACAgentOptions( ...
    "SampleTime",TsRL, ...
    "TargetSmoothFactor",1e-3, ...    
    "ExperienceBufferLength",50000, ... 
    "MiniBatchSize",512, ...
    "NumWarmStartSteps",1000, ...
    "DiscountFactor",0.99,...
    "EntropyWeightOptions",ewo,...
    "ResetExperienceBufferBeforeTraining",false,...
    "SaveExperienceBufferWithAgent",true);
% For this example the actor and critic neural networks are updated using the Adam algorithm with a learn rate of 1e-4 and gradient threshold of 1. Specify the optimizer parameters.
agentOpts.ActorOptimizerOptions.Algorithm = "adam";
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.ActorOptimizerOptions.GradientThreshold = 1;

for ct = 1:2
    agentOpts.CriticOptimizerOptions(ct).Algorithm = "adam";
    agentOpts.CriticOptimizerOptions(ct).LearnRate = 1e-4;
    agentOpts.CriticOptimizerOptions(ct).GradientThreshold = 1;
end

% Create the SAC agent.
agent = rlSACAgent(actor,[critic1,critic2],agentOpts);

%% 5 TRAIN

trainOpts = rlTrainingOptions(...
    "MaxEpisodes", 5000, ...
    "MaxStepsPerEpisode", 35/TsRL, ...
    "ScoreAveragingWindowLength", 100, ...
    "Plots", "training-progress", ...
    "StopTrainingCriteria", "EpisodeCount", ...
    "StopTrainingValue", 5000, ...
    "UseParallel", false, ...
    "SaveAgentCriteria","EpisodeReward", ...
    "SaveAgentValue",2500,...
    "StopOnError", "off");

loadAgent = true; %CAREFUL
if loadAgent
    agentName = "Agent9-6-2.mat";
    load(agentName,"saved_agent")
    agent=saved_agent;
end

% any agent adjustments
agent.AgentOptions.EntropyWeightOptions.TargetEntropy=-2;
agent.AgentOptions.EntropyWeightOptions.LearnRate=3e-4;

agent.AgentOptions.SampleTime=TsRL;
agent.AgentOptions.SaveExperienceBufferWithAgent=true;
agent.AgentOptions.ResetExperienceBufferBeforeTraining=true; %CAREFUL
agent.AgentOptions.ExperienceBufferLength=5e4;
agent.AgentOptions.MiniBatchSize=512;
agent.AgentOptions.TargetSmoothFactor=5e-3;

stats = train(agent,env,trainOpts);
