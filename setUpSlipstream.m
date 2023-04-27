% setUpSlipstream - configures slipstream lookup tables

%% initial setup

ssSwitch=1; % SLIPSTREAM SWITCH

W=data.ActorSpecifications(1,1).Width;

% only want slipstream if these two conditions are met
tolpsi = 10 * pi/180; % within 10 degrees
toly = 1.2*W /2; % for half the car

%% define power function

% power coefficients
ssCoeffs = [-0.7575 -1.5225 1.0325];
ssCoeffs1 = [-1.7834 -0.0672 2.3614];

x=1:0.5:55;
xLead=x;
yLead= ssCoeffs(1) .* x .^ ssCoeffs(2) + ssCoeffs(3);

xFollow=x;
yFollow = ssCoeffs1(1) .* x .^ ssCoeffs1(2) + ssCoeffs1(3);

x0=-2.4591;y0=0.84;
x1=2.5111;y1=0.685;

m=(y1-y0)/(x1-x0);
c=y0-m*x0;

% lookup table variables
xLead(yLead<y0)=[];
yLead(yLead<y0)=[];
xLead=[0 -x0 xLead];
yLead=[c y0 yLead];
yLead(yLead>1)=1;

xFollow(yFollow<y1)=[];
yFollow(yFollow<y1)=[];
xFollow=[0 x1 xFollow 60];
yFollow=[c y1 yFollow 1];

%% alignment multiplier 

dyNorm = 0:0.1:1;
ry = fliplr(dyNorm);
dyNorm = [dyNorm 1.1];
ry = [ry 0];


%% test plot

% plot(xLead,yLead);
% hold on
% plot(xFollow,yFollow)
% hold off

%% test plot velocity data 
% 
% time_tmp=out.simout1.Time;
% xdot_tmp=out.simout1.Data;
% 
% hold on
% plot(time_tmp,xdot_tmp,'--')

% legend('Lead car','Following car','Lead car w/o slipstream','Following car w/o slipstream')
% xlabel('Time')
% ylabel('Velocity')
