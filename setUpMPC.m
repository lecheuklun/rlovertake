% setUpMPC - MPC controller settings

%% MPC settings

Ts = 0.1;
pred_horizon = 20;
cont_horizon = 2;

w_veltrack = 0.1;
w_laterror = 2;
w_dax = 0.1;
w_dphi = 0.1;

%% Benchmarking tests

testMode = false;

%%

if testMode
    out = sim('mpcTestCorner_main.slx');
    out.SimulationMetadata.TimingInfo
end

%%

if testMode
    beep
    plotTrack;
end