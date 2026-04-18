function [h,vx,vy] = quiverplot_bfc(gmtry,uu,vv,scalefactor)
% h = quiverplot_bfc(gmtry,uu,vv)
%
% Routine to make quiver plot of a face-centered quantity (e.g. fna, fhe,
% etc...) on cell faces. This routine quivers the quantity on the boundary
% faces only. If quivers on all faces is wanted, use quiverplot_fc.
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

if ~exist('scalefactor','var') || isempty(scalefactor)
    scalefactor = 1;
    fprintf('\n quiverplot_bfc - scalefactor not specified. Using default 1. \n')
end

% Check current status of hold
hs = ishold;

% Face vertices coordinates
vx1 = [];
vx2 = [];
boundfacelist = [];
for iFc = 1:gmtry.nFc
    if gmtry.fcCv(iFc,2)>gmtry.nCi
        vx1 = [vx1, gmtry.fcVx(iFc,1)]; % first vertex of face
        vx2 = [vx2, gmtry.fcVx(iFc,2)]; % second vertex of face
        if gmtry.fcCv(iFc,1) > gmtry.nCi || gmtry.fcCv(iFc,2) > gmtry.nCi
            boundfacelist = [boundfacelist, iFc];
        end
    end
end

x1 = gmtry.vxX(vx1); % x-coord of first vertex
y1 = gmtry.vxY(vx1); % y-coord of first vertex
x2 = gmtry.vxX(vx2); % x-coord of second vertex
y2 = gmtry.vxY(vx2); % y-coord of second vertex


% Compute fcEb
gmtry = calc_fcEb(gmtry);

% Normalise fcEb

normm = sqrt(gmtry.fcEb(boundfacelist,1).^2 + gmtry.fcEb(find(boundfacelist),2).^2);
fcEb(:,1)=gmtry.fcEb(boundfacelist,1)./normm;
fcEb(:,2)=gmtry.fcEb(boundfacelist,2)./normm;

vx = uu(boundfacelist).*fcEb(:,1) - vv(boundfacelist).*fcEb(:,2)*gmtry.sbf;
vy = uu(boundfacelist).*fcEb(:,2) + vv(boundfacelist).*fcEb(:,1)*gmtry.sbf;

% Coordinates of face centers
x_c = (x1 + x2) / 2;
y_c = (y1 + y2) / 2;

% Plot velocity field using quiver
h = quiver(x_c, y_c, vx, vy, 'k');
h.AutoScale = 'on';
h.AutoScaleFactor = scalefactor;   % default is 1
axis equal

% Reset status of hold
if ~hs, hold off;

end