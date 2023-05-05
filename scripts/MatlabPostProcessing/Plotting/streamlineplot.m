function h = streamlineplot(gmtry,uu,vv,startx,starty)
% h = streamlineplot(gmtry,uu,vv,startx,starty)
%
% Routine to make streamline plot of the velocity field (uu,vv), where uu
% is the poloidal velocity and vv the radial velocity defined in cell
% centers of gmtry.
%
% If starting points are not supplied, 15 streamlines starting at the
% separatrix are followed.
%
% Input arguments:
%
% - gmtry  : struct read from b2fgmtry-file
% - uu     : poloidal velocity component (cell centered)
% - vv     : radial velocity component (cell centered)
% - startx : vector with R-coords of streamlines to be followed (optional)
% - starty : vector with Z-coords of streamlines to be followed (optional)
%
% Output arguments:
%
% - h      : handle to the streamline plot
%
% Example:
%
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% If start positions are not supplied, launch 15 streamlines spread around
% separatrix
if ~exist('startx','var') || isempty(startx)
    d   = (size(gmtry.vol,1)-2)/16;
    xsep = floor([d:d:size(gmtry.vol,1)]);
    ysep = gmtry.topcut+2;
    startx  = 0.5*(gmtry.crx(xsep,ysep,1) + gmtry.crx(xsep,ysep,2));
    starty  = 0.5*(gmtry.cry(xsep,ysep,1) + gmtry.cry(xsep,ysep,2));
end


% Check current status of hold
hs = ishold;

% Create Cartesian mesh for streamline plot
xmin = min(min(min(gmtry.crx)));
xmax = max(max(max(gmtry.crx)));
ymin = min(min(min(gmtry.cry)));
ymax = max(max(max(gmtry.cry)));
xI   = [xmin:(xmax-xmin)/200:xmax];
yI   = [ymin:(ymax-ymin)/400:ymax]';


% Compute poloidal and radial unit vectors in cell centers
[epx,epy,erx,ery] = mshproj(gmtry);

% Project velocities onto Cartesian directions
vx = uu.*epx + vv.*erx;
vy = uu.*epy + vv.*ery;

% Interpolate flow field to Cartesian mesh
vxI = interpolate(gmtry,vx,repmat(xI,length(yI),1),repmat(yI,1,length(xI)));
vyI = interpolate(gmtry,vy,repmat(xI,length(yI),1),repmat(yI,1,length(xI)));

% Streamline plot
h = streamline(xI,yI,vxI,vyI,startx,starty); hold on;
plot(startx,starty,'ro');


% Reset status of hold
if ~hs, hold off; end;
