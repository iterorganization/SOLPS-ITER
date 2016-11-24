function p = patchplot(gmtry,field,scale,fmin,fmax)
% p = patchplot(gmtry,field,options)
%
% Routine to make patchplot of cell centered quantity.
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
% - p       : handle to the patch plot object
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
    error('patchplot: fmin > fmax.');
end

% Crop and scale field
field = max(min(field/scale,fmax),fmin);

if isplasmagrid(gmtry)
    
    nx2 = size(gmtry.crx,1);
    ny2 = size(gmtry.crx,2);
    
    % Resize for patch plot
    X = reshape(gmtry.crx,nx2*ny2,4)';
    Y = reshape(gmtry.cry,nx2*ny2,4)';
    f = reshape(field,nx2*ny2,1)';
    
    % Create closed polygon from vertex coordinates
    X(3:4,:) = X(4:-1:3,:);
    Y(3:4,:) = Y(4:-1:3,:);
    
elseif istrianglegrid(gmtry)
    
    % Construct the triangles as polygons for patch
    X = zeros(3,size(gmtry.cells,1));
    Y = zeros(3,size(gmtry.cells,1));
    for j = 1:3
        for i = 1:size(gmtry.cells,1)
            X(j,i) = gmtry.nodes(gmtry.cells(i,j),1);
            Y(j,i) = gmtry.nodes(gmtry.cells(i,j),2);
        end
    end
    
    f = field';
else
    error('patchplot: wrong gmtry structure');
end

% Create patch plot
p = patch(X,Y,f);

% Set axis to fmin and fmax
caxis([fmin fmax]);