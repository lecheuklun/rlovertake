% setUpModel - define trajectories, velocity map and pedal map

%% load the scene data files
% load data from Driving Scenario Designer

load('corner_twoCarsRLMPCWide.mat');

% specify simulation stop time
Tstop = 45*5/4;

%% define reference points 

% agent
refPose2 = data.ActorSpecifications(1,1).Waypoints;

xRef2 = refPose2(:,1);
yRef2 = -refPose2(:,2);
X_o2 = xRef2(1);
Y_o2 = yRef2(1); 
psi_o2 = 0.3528 *(pi/180);

% lead car
refPose1 = data.ActorSpecifications(1,2).Waypoints;

xRef1 = refPose1(:,1);
yRef1 = -refPose1(:,2);
X_o1 = xRef1(1);
Y_o1 = yRef1(1); 
psi_o1 = 0.0058 * (pi/180);


%% Calculating reference pose vectors

nPoints=100;

[gradbp2, curvature2] = calculateCurvatureVector(refPose2,xRef2,yRef2,nPoints);
[gradbp1, curvature1] = calculateCurvatureVector(refPose1,xRef1,yRef1,nPoints);

%% Define velocity lookup table

% define data for velocity lookup table

% Simulink coords
critx = -25;
crity = -20;

% Define speeds
highSpeed1=35;
highSpeed2=36;
lowSpeed=12;

xlt = -250:10:200;
ylt = -150:10:100;
vel1 = highSpeed1 * ones(length(xlt),length(ylt));
vel2 = highSpeed2 * ones(length(xlt),length(ylt));

vel1(xlt>critx,ylt<crity) = lowSpeed;
vel2(xlt>critx,ylt<crity) = lowSpeed;

% Linearise braking and accel zones
braking=linspace(36,12,18); %index calc: 41-24+1=18
accel=linspace(12,30,sum(ylt<crity)); % index calc: 26-18+1=9;
accelInds=find(ylt>=-20);
vel2(24:41,ylt<crity) = repmat(braking',1,sum(ylt<crity)); %x=-20 to 150
vel2(xlt>critx,accelInds) = repmat(accel,sum(xlt>critx),1); %y=20 to 100

v_o1 = highSpeed1;
v_o2 = highSpeed2;

%% MPC Pedal Map

% additional vehicle parameters
L = data.ActorSpecifications.Length; % bicycle length
ld = 4; % lookahead distance
rho = 1.21;
Cd = 0.3;
Af = 2;
tire_r = 0.309;
m=2000;
% bounds for 2-D lookup table
accel_vec = (-4:0.5:4)'; % acceleration is between -4 and 4 m/s^2
vel_vec = 0:2:20; % vehicle velocity is between 0 and 20 m/s
torque_map = zeros(length(accel_vec),length(vel_vec));
% calculate required torque
for i = 1:length(accel_vec)
    for j = 1:length(vel_vec)
        % Torque is based on sum of the forces times the wheel radius
        % F_tractive = F_i + F_resistive
        % F_resistive forces are drag and a constant tire loss force
        % The constant is one of the values used to calibrate the map
        % For more information on the forces, see Gillespie's "Fundamentals
        % of Vehicle Dynamics"
        torque_map(i,j) = tire_r*((m*accel_vec(i))+(0.5*rho*Cd*Af*vel_vec(j)^2)+160);
    end
end
% convert torque to pedal based on powertrain parameters
pedal_map = torque_map;
% positive torques are scaled based on powertrain's maximum wheel torque
max_prop_torque = 425*9.5;
pedal_map(pedal_map>0) = pedal_map(pedal_map>0)/max_prop_torque;
% calculate the conversion from torque to maximum pressure
pressure_conv = (0.2*7.5e6*pi*0.05*0.05*.177*2/4)*4*1.01; % 1.01 is a calibrated value
pedal_map(pedal_map<0) = pedal_map(pedal_map<0)/pressure_conv;

%% Calculate Curvature Vector

function [gradbp, curvature] = calculateCurvatureVector(refPose,xRef,yRef,nPoints)
% calculating reference pose vectors

% Based on how far the vehicle travels, the pose is generated using 1-D
% lookup tables.

% calculate distance vector
distancematrix = squareform(pdist(refPose));
distancesteps = zeros(length(refPose)-1,1);
for i = 2:length(refPose)
    distancesteps(i-1,1) = distancematrix(i,i-1);
end
totalDistance = sum(distancesteps); % Total traveled distance
distbp = cumsum([0; distancesteps]); % Distance for each waypoint
gradbp = linspace(0,totalDistance,nPoints); % Linearize distance

% linearize X and Y vectors based on distance
xRef2 = interp1(distbp,xRef,gradbp,'pchip');
yRef2 = interp1(distbp,yRef,gradbp,'pchip');
yRef2s = smooth(gradbp,yRef2);
xRef2s = smooth(gradbp,xRef2);

% calculate curvature vector
curvature = getCurvature(xRef2,yRef2);
end 

%% Curvature Function

function curvature = getCurvature(xRef,yRef)
% Calculate gradient by the gradient of the X and Y vectors
DX = gradient(xRef);
D2X = gradient(DX);
DY = gradient(yRef);
D2Y = gradient(DY);
curvature = (DX.*D2Y - DY.*D2X) ./(DX.^2+DY.^2).^(3/2);
end
