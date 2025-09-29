function [h,vx,vy] = quiverplot_fc(gmtry,uu,vv)
% h = quiverplot_fc(gmtry,uu,vv)
%
% Routine to make quiver plot of a face-centered quantity (e.g. fna, fhe,
% etc...) on cell faces. This routine quivers the quantity on all the
% faces. If quivers on boundary faces only is wanted, use quiverplot_bfc.
%
% Input arguments:
%
% - gmtry  : struct read from b2fgmtry-file
% - uu     : poloidal component (face centered)
% - vv     : radial   component (face centered)
%
% Output arguments:
%
% - h      : handle to the quiver plot
% - vx     : poloidal component of the quiver
% - vy     : radial component of the quiver
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
