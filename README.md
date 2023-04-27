# rlovertake

## Replaying simulation
1. Open `rlOvertakeTwoCars.slx`. 
    * The script `setUpMain.m` should have run automatically, populating the workspace. If the workspace is empty run this again.
2. Open `replay.m` from the HelperScripts folder. 
3. Change the name at the top to the agent name you want.
    * The only available agent is `Agent9-6-2.mat`.
4. Run `replay.m`. This will simulate the model and open a birds-eye scope to visualise the results.
5. To replay the simulation without resimulating, run `plotTrack.m`.
    * You can set real time (recommended), playback speed, and trails using the commented binary switches.
    * To resimulate intentionally, run `simRL=1;` in the command window then run `plotTrack.m`.

## Contents  
•	HelperScripts: Workflow helper scripts  
•	Images: For Simulink model  
•	TrackData: Track representations, from MATLAB Driving Scenario Designer  
•	savedAgents: Contains Agent9-6-2, working overtaking agent  
•	`busActors.mat`: File needed to run simulation  
•	`plotTrack.m`: Runs birds-eye scope visualisation of simulation  
•	`rewardLibrary.slx`: Library of all previous reward formulations  
•	`rlOvertakeTwoCars.slx`: Main Simulink model of two vehicles  
•	`setUpMPC.m`: Setup script for MPC  
•	`setUpMain.m`: Main setup script for whole workflow  
•	`setUpModel.m`: Setup script for Simulink model  
•	`setUpRLEnv.m`: Setup script for RL environment  
•	`setUpSlipstream.m`: Setup script for slipstream modelling  
•	`trainRL.m`: Script for configuring and training SAC agent  
