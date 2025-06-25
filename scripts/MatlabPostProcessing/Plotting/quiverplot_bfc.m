function quiverplot_bfc(gmtry,uu,vv)
% h = quiverplot(gmtry,uu,vv)
%
% Routine to make quiver plot of the velocity field (uu,vv), where uu
% is the poloidal velocity and vv the radial velocity defined in boundary
% face centers of gmtry.
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
vx1 = [];
vx2 = [];
for iFc = 1:gmtry.nFc
    if (gmtry.fcLbl(iFc)<0) % assumption: all the boundary faces have fcLbl < 0! Should be generalised.
        vx1 = [vx1, gmtry.fcVx(iFc,1)]; % first vertex of face
        vx2 = [vx2, gmtry.fcVx(iFc,2)]; % second vertex of face
    end
end

x1 = gmtry.vxX(vx1); % x-coord of first vertex
y1 = gmtry.vxY(vx1); % y-coord of first vertex
x2 = gmtry.vxX(vx2); % x-coord of second vertex
y2 = gmtry.vxY(vx2); % y-coord of second vertex


% Compute fcEb
gmtry = calc_fcEb(gmtry);

% Normalise fcEb
norm = sqrt(gmtry.fcEb(find(gmtry.fcLbl<0),1).^2 + gmtry.fcEb(find(gmtry.fcLbl<0),2).^2);
fcEb(:,1)=gmtry.fcEb(find(gmtry.fcLbl<0),1)./norm;
fcEb(:,2)=gmtry.fcEb(find(gmtry.fcLbl<0),2)./norm;

vx = uu(find(gmtry.fcLbl<0)).*fcEb(:,1) - vv(find(gmtry.fcLbl<0)).*fcEb(:,2)*gmtry.sbf;
vy = uu(find(gmtry.fcLbl<0)).*fcEb(:,2) + vv(find(gmtry.fcLbl<0)).*fcEb(:,1)*gmtry.sbf;

% Coordinates of face centers
x_c = (x1 + x2) / 2;
y_c = (y1 + y2) / 2;

% Plot velocity field using quiver
h = quiver(x_c, y_c, vx, vy, 'k')
axis equal

% Reset status of hold
if ~hs, hold off;

end
