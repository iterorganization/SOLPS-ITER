function p = Patchplot(gmtry,field,scale,fmin,fmax)
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
    
    % Eliminate guard cells 
    if isfield(gmtry,'cflags') & ~isempty(gmtry.cflags)
        X = X(:,gmtry.cflags(:,:,1)~=9);
        Y = Y(:,gmtry.cflags(:,:,1)~=9);
        f = f(gmtry.cflags(:,:,1)~=9);
    end
    
    S.XData = X;
    S.YData = Y;
    S.ZData = f;
    
elseif isunstructuredgrid(gmtry)
    
    S = struct([]);
    for iCv = 1:length(gmtry.cvVol)
        S(iCv).XData = [];
        S(iCv).YData = [];
        if (length(field)==gmtry.nVx)
            S(iCv).ZData = [];
        else
            S(iCv).ZData = field(iCv);
        end
        iVx1 = gmtry.cvVx(gmtry.cvVxP(iCv,1));
        for i = 1:gmtry.cvVxP(iCv,2)
            iVx = gmtry.cvVx(gmtry.cvVxP(iCv,1)+i-1);
            
            S(iCv).XData = [S(iCv).XData;gmtry.vxX(iVx)];
            S(iCv).YData = [S(iCv).YData;gmtry.vxY(iVx)];
            if (length(field)==gmtry.nVx)
                S(iCv).ZData = [S(iCv).ZData;field(iVx)];
            end
        end
        S(iCv).XData = [S(iCv).XData;gmtry.vxX(iVx1)];
        S(iCv).YData = [S(iCv).YData;gmtry.vxY(iVx1)];
        if (length(field)==gmtry.nVx)
        	S(iCv).ZData = [S(iCv).ZData;field(iVx1)];
        end
        if (gmtry.isClassicalGrid==1)
            S(iCv).XData(end-2:end-1) = [S(iCv).XData(end-1);S(iCv).XData(end-2)];
            S(iCv).YData(end-2:end-1) = [S(iCv).YData(end-1);S(iCv).YData(end-2)]; 
            if (length(field)==gmtry.nVx)
                S(iCv).ZData(end-2:end-1) = [S(iCv).ZData(end-1);S(iCv).ZData(end-2)]; 
            end
        end
    end
 
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
    
    S.XData = X;
    S.YData = Y;
    S.ZData = f;
else
    error('patchplot: wrong gmtry structure');
end

% Check current status of hold
hs = ishold;
hold on;

% Create patch plot
for i = 1:length(S)
    p(i) = patch(S(i).XData,S(i).YData,S(i).ZData);
end

% Set axis to fmin and fmax
caxis([fmin fmax]);

% Reset status of hold
if ~hs, hold off; end;