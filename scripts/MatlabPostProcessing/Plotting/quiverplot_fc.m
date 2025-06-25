function [h,vx,vy] = quiverplot_fc(gmtry,uu,vv)
% h = quiverplot(gmtry,uu,vv)
%
% Routine to make quiver plot of the velocity field (uu,vv), where uu
% is the poloidal velocity and vv the radial velocity defined in face
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

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% April 2025

% Check current status of hold
hs = ishold;

% Face vertices coordinates
vx1 = gmtry.fcVx(:,1); % first vertex of face
vx2 = gmtry.fcVx(:,2); % second vertex of face
x1 = gmtry.vxX(vx1); % x-coord of first vertex
y1 = gmtry.vxY(vx1); % y-coord of first vertex
x2 = gmtry.vxX(vx2); % x-coord of second vertex
y2 = gmtry.vxY(vx2); % y-coord of second vertex

% Compute fcEb
gmtry = calc_fcEb(gmtry);

% Normalise fcEb
norm = sqrt(gmtry.fcEb(:,1).^2 + gmtry.fcEb(:,2).^2);
fcEb(:,1)=gmtry.fcEb(:,1)./norm;
fcEb(:,2)=gmtry.fcEb(:,2)./norm;

vx = uu.*fcEb(:,1) - vv.*fcEb(:,2)*gmtry.sbf;
vy = uu.*fcEb(:,2) + vv.*fcEb(:,1)*gmtry.sbf;

% Coordinates of face centers
x_c = (x1 + x2) / 2;
y_c = (y1 + y2) / 2;

% Plot velocity field using quiver
h = quiver(x_c, y_c, vx, vy, 'k')
axis equal

% Reset status of hold
if ~hs, hold off;

end
