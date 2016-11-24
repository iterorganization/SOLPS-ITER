function h = surfplot(gmtry,field,scale,fmin,fmax)
% h = surfplot(gmtry,field,scale,fmin,fmax)
%
% Routine to make surfplot of cell centered quantity.
% 
% Input arguments:
%
% - gmtry : struct read from b2fgmtry-file
% - field : cell centered field to be plotted
% - scale : scale factor for data in field (optional)
% - fmin  : min. contour value (optional)
% - fmax  : max. contour value (optional)
%
% Output arguments:
%
% - h     : column vector of handles to the surface plot objects
%           (h(1): Core, h(2): SOL, h(3): PFR)
% 

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Set default values for some arguments, if not supplied
if ~exist('scale','var') || isempty(scale)
  scale = 1;
end
if ~exist('fmin','var') || isempty(fmin)
    fmin = min(min(field/scale));
end
if ~exist('fmax','var') || isempty(fmax)
    fmax = max(max(field/scale));
end

% Consistency checks
if fmin > fmax
    error('surfplot: fmin > fmax.');
end

% Crop and scale field
field = max(min(field/scale,fmax),fmin);

% Compute cell center coordinates
r = mean(gmtry.crx,3);
z = mean(gmtry.cry,3);


% Check current status of hold
hs = ishold;

% Core
zC = [z(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1);z(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1)];
rC = [r(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1);r(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1)];
f  = [field(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1);field(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1)];
h(1) = surf(rC,zC,f);

hold on;

% SOL
zC = z(:,gmtry.topcut(1)+1:end);
rC = r(:,gmtry.topcut(1)+1:end);
f  = field(:,gmtry.topcut(1)+1:end);
h(2) = surf(rC,zC,f);

% PFR
zC = [z(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1);z(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1)];
rC = [r(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1);r(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1)];
f  = [field(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1);field(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1)];
h(3) = surf(rC,zC,f);

% Reset status of hold
if ~hs, hold off; end;

