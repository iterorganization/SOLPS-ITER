function h = quiverplot_cv(gmtry,uu,vv)
% h = quiverplot(gmtry,uu,vv)
%
% Routine to make quiver plot of the velocity field (uu,vv), where uu
% is the poloidal velocity and vv the radial velocity defined in cell
% centers of gmtry.
%
% Input arguments:
%
% - gmtry  : struct read from b2fgmtry-file
% - uu     : poloidal velocity component (cell centered)
% - vv     : radial velocity component (cell centered)
%
% Output arguments:
%
% - h      : handle to the quiver plot
%
% Example:
%
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Check current status of hold
hs = ishold;

% Cell center coordinates
xc = mean(gmtry.crx,3);
yc = mean(gmtry.cry,3);

% Poloidal and radial unit vectors in cell centers
[epx,epy,erx,ery] = mshproj(gmtry);

% Project velocities onto Cartesian directions
vx = uu.*epx + vv.*erx;
vy = uu.*epy + vv.*ery;


% Quiver plot
h = quiver(xc,yc,vx,vy);


% Reset status of hold
if ~hs, hold off; end;
