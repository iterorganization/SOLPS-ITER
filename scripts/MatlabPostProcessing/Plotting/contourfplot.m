function [Ch] = contourfplot(gmtry,field,scale,fmin,fmax,ncont)
% [Ch] = contourfplot(gmtry,field,scale,ncont,fmin,fmax)
%
% Routine to make contourfplot of cell centered quantity.
% 
% Input arguments:
%
% - gmtry : struct read from b2fgmtry-file
% - field : cell centered field to be plotted
% - scale : scale factor for data in field (optional)
% - ncont : number of contour levels (optional)
% - fmin  : min. contour value (optional)
% - fmax  : max. contour value (optional)
%
% Output arguments:
%
% - Ch  : struct, length 3 (1 = Core, 2 = SOL, 3 = PFR), with fields
%         * Ch(i).C: matrix with contour levels (see CONTOURC)
%         * Ch(i).h: handles to the CONTOURGROUP objects
% 
% Example:
%
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Set default values for some arguments, if not supplied
if ~exist('scale','var') || isempty(scale)
  scale = 1;
end
if ~exist('ncont','var') || isempty(ncont)
    ncont = 50;
end
if ~exist('fmin','var') || isempty(fmin)
    fmin = min(min(field/scale));
end
if ~exist('fmax','var') || isempty(fmax)
    fmax = max(max(field/scale));
end


% Consistency checks
if fmin > fmax
    error('contourfplot: fmin > fmax.');
end

% Try: fort.44 arrays don't include guard cells, so copy data into guard
% cell
if (size(field,1) == size(gmtry.crx,1) - 2) & ...
        (size(field,2) == size(gmtry.crx,2) - 2)
    fieldtmp = zeros(size(field,1)+2,size(field,2)+2);
    fieldtmp(2:end-1,2:end-1) = field;
    fieldtmp(1,2:end-1)   = fieldtmp(2,2:end-1);
    fieldtmp(end,2:end-1) = fieldtmp(end-1,2:end-1);
    fieldtmp(:,1)   = fieldtmp(:,2);
    fieldtmp(:,end) = fieldtmp(:,end-1);
    field = fieldtmp;
end

% Compute cell center coordinates
r = mean(gmtry.crx,3);
z = mean(gmtry.cry,3);

% Determine contour levels
if fmin > 0
    fcont = [0,fmin:(fmax-fmin)/ncont:fmax];
elseif fmax < 0
    fcont = [fmin:(fmax-fmin)/ncont:fmax,0];
else
    fcont = [(fmin:(fmax-fmin)/ncont:fmax)];
end

% Rescale field
field = field/scale;


% Check current status of hold
hs = ishold;

% Init output
Ch = struct('C',[],'h',[]);

% SOL
zC = z(:,gmtry.topcut(1)+1:end);
rC = r(:,gmtry.topcut(1)+1:end);
f  = field(:,gmtry.topcut(1)+1:end);
[Ch(2).C,Ch(2).h] = contourf(rC,zC,f,fcont);

hold on;


% Core
zC = [z(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1);z(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1)];
rC = [r(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1);r(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1)];
f  = [field(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1);field(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1)];
[Ch(1).C,Ch(1).h] = contourf(rC,zC,f,fcont);


% PFR
zC = [z(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1);z(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1)];
rC = [r(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1);r(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1)];
f  = [field(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1);field(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1)];
[Ch(3).C,Ch(3).h] = contourf(rC,zC,f,fcont);


% Reset status of hold
if ~hs, hold off; end;

caxis([fmin,fmax]);



