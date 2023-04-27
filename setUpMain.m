% setUpMain - master script to set up model before simulation

%% Add paths

addpath(genpath('Images'));
addpath(genpath('TrackData'));
addpath(genpath('savedAgents'));
addpath(genpath('HelperScripts'));

%% Constraints and initial conditions

% vehicle constraints
amin = -3;
amax = 3;
umin=-0.3;
umax=0.3;

e1_initial = 0;
e2_initial = 0;


%% Setup scripts

setUpModel;
setUpMPC;
setUpSlipstream;
setUpRLEnv;

%% Load connection bus if missing from workspace

load('busActors.mat')

%% Testing previous versions

if rlStage==1
    amax_ego=amax;
    amin_ego=amin;
    umax_ego=umax;
    umin_ego=umin;
    r_dyNorm=ry;
    vel=vel1;
    vo=36;
end
















