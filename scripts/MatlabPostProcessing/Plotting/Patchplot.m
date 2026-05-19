function [p] = Patchplot(gmtry,field,scale,fmin,fmax,check_type,threshold)
% [p] = Patchplot(gmtry,field,options)
%
% Routine to make patchplot of cell-centered quantity.
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
    fmin = min(min(field(1:gmtry.nCi)/scale));
end
if ~exist('fmax','var') || isempty(fmax)
    fmax = max(max(field(1:gmtry.nCi)/scale));
end
if ~exist('threshold','var') || isempty(threshold)
    threshold = 9e99;
end
if ~exist('check_type','var') || isempty(check_type)
    check_type = 'g';
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
    if isfield(gmtry,'cflags') && ~isempty(gmtry.cflags)
        X = X(:,gmtry.cflags(:,:,1)~=9);
        Y = Y(:,gmtry.cflags(:,:,1)~=9);
        f = f(gmtry.cflags(:,:,1)~=9);
    end

    S.XData = X;
    S.YData = Y;
    S.ZData = f;

elseif isunstructuredgrid(gmtry)
%     To create one polygon, specify X
%     and Y as vectors. To create multiple polygons, specify X and Y as
%     matrices where each column corresponds to a polygon. C determines the
%     polygon colors.
    S = struct([]);
    nmax = 1;
    for iCv = 1:length(gmtry.cvVol)
        S(iCv).XData = [];
        S(iCv).YData = [];
        if (length(field)==gmtry.nVx)
            S(iCv).ZData = [];
        else
            S(iCv).ZData = field(iCv);
            if check_type == 'g'
                if S(iCv).ZData > threshold && iCv <= gmtry.nCi
                    fprintf('Warning. High value of quantity at iCv number %d\n',iCv)
                    fprintf('Coordinates:\n R = %f, Z = %f \n', gmtry.cvX(iCv), gmtry.cvY(iCv))
                    fprintf('Cell volume: %f\n', gmtry.cvVol(iCv))
                end
            elseif check_type == 's'
                if S(iCv).ZData < threshold && iCv <= gmtry.nCi
                    fprintf('Warning. High value of quantity at iCv number %d\n',iCv)
                    fprintf('Coordinates:\n R = %f, Z = %f \n', gmtry.cvX(iCv), gmtry.cvY(iCv))
                    fprintf('Cell volume: %f\n', gmtry.cvVol(iCv))
                end
            else
                error('Invalid check_type. Must be `g` (>) or `s` (<)')
            end
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
        nmax = max(nmax,length(S(iCv).XData));
    end
    S0 = S;
    clear S
    S = struct;
    S.XData = [];
    S.YData = [];
    S.ZData = [];
    S.XData = zeros(nmax,length(S0));
    S.YData = S.XData;
    S.ZData = zeros(length(S0),1);
    
    for ii=1:length(S0)
        nn = length(S0(ii).XData);
        S.XData(1:nn,ii) = S0(ii).XData;
        S.YData(1:nn,ii) = S0(ii).YData;
        S.ZData(ii) = S0(ii).ZData;
        if nn<nmax
            S.XData(nn+1:nmax,ii) = S.XData(nn,ii);
            S.YData(nn+1:nmax,ii) = S.YData(nn,ii);
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
% Handle array initialisation
% Handle array initialisation
nCells = size(S.XData, 2);
nmax   = size(S.XData, 1);

Xv = S.XData(:);
Yv = S.YData(:);
Zv = zeros(size(Xv));

% Build faces
Faces = reshape(1:numel(Xv), nmax, nCells)';

% Use one patch only
hs = ishold;
hold on;
p = patch('Faces', Faces, ...
          'Vertices', [Xv Yv Zv], ...
          'FaceVertexCData', S.ZData, ...
          'FaceColor', 'flat', ...
          'EdgeColor', 'k', ...
          'LineWidth', 0.5);

colorbar
caxis([fmin fmax]);

% Highlight borders
mask_g = (check_type == 'g') & (S.ZData > threshold) & (1:nCells)' <= gmtry.nCi;
mask_s = (check_type == 's') & (S.ZData < threshold) & (1:nCells)' <= gmtry.nCi;
highlight = mask_g | mask_s;

if any(highlight)
    patch('Faces', Faces(highlight,:), ...
          'Vertices', [Xv Yv Zv], ...
          'FaceColor', 'none', ...
          'EdgeColor', 'r', ...
          'LineWidth', 2.0);
end

if ~hs
    hold off;
end
