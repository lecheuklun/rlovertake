% setUpRLEnv - defines RL environment and observation architecture

% Settings
TsRL=Ts;
rlStage=2;
testMode = false;
newNet=true;

numObs=12;
switch rlStage
    case 1
        mdl = 'rlOvertakeOneCarFollow';
        if ~newNet
            numObs = 9;
        end
    case 2
        mdl = 'rlOvertakeTwoCars';
        if testMode
            mdl = 'rlOvertakeTwoCarsTest';
        end
end

numAct = 2;

agentblk = [mdl '/RL Agent'];

obsInfo = rlNumericSpec([numObs 1],'LowerLimit',-inf*ones(numObs,1),'UpperLimit',inf*ones(numObs,1));
obsInfo.Name = 'observations';

actInfo = rlNumericSpec([numAct 1],'LowerLimit',[amin;umin],'UpperLimit',[amax;umax]);
actInfo.Name = 'accel;steer';

env = rlSimulinkEnv(mdl,agentblk,obsInfo,actInfo);

switch rlStage
    case 1
        env.ResetFcn = @(in)localResetFcnOneCar(in);
    case 2
        env.ResetFcn = @(in)localResetFcn(in);
        if testMode
            env.ResetFcn = @(in)localResetFcnTest(in);
        end
end


%% local reset functions

function in = localResetFcn(in) 
in = setVariable(in,'e1_initial', 0); 
in = setVariable(in,'e2_initial', 0); 

in = setVariable(in,'v_o1', 35*1.1); 
in = setVariable(in,'X_o1', -234.95); 
in = setVariable(in,'Y_o1', -51.1); 
in = setVariable(in,'psi_o1', 0.0058); 

in = setVariable(in,'v_o2', 36);
in = setVariable(in,'X_o2', -246.2234); 
in = setVariable(in,'Y_o2', -51.1682); 
in = setVariable(in,'psi_o2', 0.0062); 
end

function in = localResetFcnTest(in) 
in = setVariable(in,'e1_initial', 0); 
in = setVariable(in,'e2_initial', 0); 

in = setVariable(in,'v_o1', 35); 
in = setVariable(in,'X_o1', -234.95); 
in = setVariable(in,'Y_o1', -51.1); 
in = setVariable(in,'psi_o1', 0.0058);

in = setVariable(in,'r_curv', 1);

in = setVariable(in,'v_o2', 36);
in = setVariable(in,'X_o2', -246.2234); 
in = setVariable(in,'Y_o2', -51.1682+3); 
in = setVariable(in,'psi_o2', 0.0062); 
end


function in = localResetFcnOneCar(in) 
in = setVariable(in,'e1_initial', 0); 
in = setVariable(in,'e2_initial', 0); 

in = setVariable(in,'v_o', 36); 
in = setVariable(in,'X_o2', -246.2234); 
in = setVariable(in,'Y_o2', -51.1682); 
in = setVariable(in,'psi_o2', 0.0062); 
end
