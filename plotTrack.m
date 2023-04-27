% plotTrack - visualises RL simulation from Simulink on a birds-eye scope.

%% Simulate data

% run simRL=true; in command window before this to resimulate
if ~exist('simRL','var')
    simRL=true;
end

if simRL
    simOptions = rlSimulationOptions('MaxSteps',ceil(Tstop/Ts));
    experience = sim(env,agent,simOptions);
    out = experience.SimulationInfo;
    simRL=false;
end

%% Load data

coords = out.simout.Data;

%% Initialise simulation

% twoCars = true; % TWO CAR SWITCH
% if switching from twoCars false to true, need to clear the scenario
% variable

if ~twoCars
    coords(:,1)=[]; %comment this if viewing lead car only
end

plotTrails = 0; % PLOT TRAILS SWITCH

if plotTrails
    hold on
end

if ~exist('scenario','var') || ~ishandle(1)
    load('corner_oneCarRLStraightShifted.mat');
%     load('corner_oneCarRL.mat');
    scenario = drivingScenario;
    data.RoadSpecifications.applyToScenario(scenario)
    
    plot(scenario)

    v1 = vehicle(scenario,'ClassID',1);
    if twoCars
        v2 = vehicle(scenario,'ClassID',2);
    end

end

% time annotations
if exist('annot','var')
    if ~isvalid(annot)
        annot = annotation('textbox',[.2 0.75 0.5 0.2], ...
        'String','T=0.0','EdgeColor','none','FontSize',14);
    end
else
    annot = annotation('textbox',[.2 0.75 0.5 0.2], ...
        'String','T=0.0','EdgeColor','none','FontSize',14);
end


set(annot,'String','T=0.0')
drawnow

x1 = coords(:,1);
y1 = coords(:,2);
psi1 = coords(:,3);
position1 = [x1 y1 zeros(length(x1),1)];
v1.Position=position1(1,:);
v1.Yaw=psi1(1);

if twoCars
    x2 = coords(:,4);
    y2 = coords(:,5);
    psi2 = coords(:,6);
    position2 = [x2 y2 zeros(length(x2),1)];
    v2.Position=position2(1,:);
    v2.Yaw=psi2(1);
end

updatePlots(scenario)

%% Set frame of figure

% set(gcf,'Position',[3980 500 1131 905]);

%% Play simulation

% define viewing settings
realTime=true; % REAL TIME SWITCH
playbackSpeed=2; % PLAYBACK SPEED

t = out.simout.Time;

% used for real time viewing
dtq = 0.1;
tq = 0:dtq:(floor(t(end)/dtq)*dtq);
x1q=interp1(t,x1,tq);
y1q=interp1(t,y1,tq);
psi1q=interp1(t,psi1,tq);

if twoCars
    x2q=interp1(t,x2,tq);
    y2q=interp1(t,y2,tq);
    psi2q=interp1(t,psi2,tq);
end

% if viewing in real time, interpolate coordinates
if realTime
    position1f = [x1q' y1q' zeros(length(x1q),1)];
    psi1f = psi1q;
    if twoCars
        position2f = [x2q' y2q' zeros(length(x2q),1)];
        psi2f = psi2q;
    end
    tf = tq;
    sampleRate=playbackSpeed;
else
    position1f = position1;
    psi1f = psi1;
    if twoCars
        position2f = position2;
        psi2f = psi2;
    end
    tf = t;
    sampleRate=2;
end

for i=1:sampleRate:length(tf)
    v1.Position = position1f(i,:);
    v1.Yaw = psi1f(i);
    if twoCars
        v2.Position = position2f(i,:);
        v2.Yaw = psi2f(i);
    end
    updatePlots(scenario)
    set(annot,'String',['T=' num2str(round(tf(i),1))])

    if plotTrails && i>1
        hold on
        plot(position1f(i-1:i,1),position1f(i-1:i,2),'-','Color',"#0072BD",'LineWidth',1.5)
        if twoCars
            plot(position2f(i-1:i,1),position2f(i-1:i,2),'-','Color',"#D95319",'LineWidth',1.5)
        end
    end
    
    if realTime
        pause(dtq)
    else
        pause(0.001)
    end
end

%% Plot a specific time (only works with real time)

specificTime=0; % SPECIFIC TIME SWITCH

if realTime & specificTime
    
    % SEARCH TIME HERE
    tSearch=1.7;

    i = find(abs(tf-tSearch)<1e-9);

    v1.Position = position1f(i,:);
    v1.Yaw = psi1f(i);
    if twoCars
        v2.Position = position2f(i,:);
        v2.Yaw = psi2f(i);
    end
    updatePlots(scenario)
    set(annot,'String',['T=' num2str(round(tf(i),1))])

end 
