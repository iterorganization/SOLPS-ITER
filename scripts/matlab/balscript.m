% balscript controls the balance routines. This should be modified by the user 
% to suit their needs.

MDSNUMBER = 62165; %58804; %58743; %59781; % 60234
% REVERSE=true if the right-most end of the balance volume is upstream of
% the left-most end, otherwise REVERSE=false:
REVERSE = false;
ISPLOT = 4;

% Get geometry information for this simulation:
geomb2 = b2getgeom(MDSNUMBER);

% Lay out the window into which plots will go:
figure('windowstyle','docked');
axgrid = subplot(2,3,[1,4]); box on; hold on;
axbal(1) = subplot(2,3,2); box on; hold on; % For integrated balance
axbal(2) = subplot(2,3,5); box on; hold on; % For decomposition of integrated balance
axbal(3) = subplot(2,3,3); box on; hold on; % For poloidal balance
axbal(4) = subplot(2,3,6); box on; hold on; % For decomposition of poloidal balance

% Specify the volume where balance is to be performed by creating a matrix of 
% size nx*ny which is true inside the volume:
indbal = false(geomb2.nx,geomb2.ny);
% indbal(122:151,geomb2.sep+2:geomb2.ny-1) = true; % Lower outer SOL only right up to x-point
indbal(123:151,2:geomb2.ny-1) = true; % Lower outer SOL+PFR up to 1 cell before x-point
% indbal(60:88,2:geomb2.ny-1) = true; % Upper outer SOL+PFR up to 1 cell before x-point
% indbal(43:57,2:geomb2.ny-1) = true; % Upper inner SOL+PFR up to 1 cell before x-point
% indbal(2:16,2:geomb2.ny-1) = true; % Lower inner SOL+PFR up to 1 cell before x-point
% indbal(75:97,2:geomb2.ny-1) = true;

% Specify the rings on which poloidal balance is to be performed:
iyplot = geomb2.sep+2;

% Plot the grid showing where balance will be performed:
balgrid(geomb2,indbal,iyplot,axgrid,REVERSE);

% Total pressure balance:
balmom(MDSNUMBER,indbal,iyplot,geomb2,axbal,REVERSE);