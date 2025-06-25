function Patchplot3(gmtry,field,scale,fmin,fmax,threshold,check_type)
% Patchplot3(gmtry,field,options)
%
% Routine to make patchplot of cell centered quantity + guard cells values.
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

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% May 2025

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
if ~exist('check_type','var') || isempty(check_type)
    check_type = 'g';
    if ~isempty(threshold)
        fprintf('WARNING: threshold set but type of check not specified.')
        fprintf(' Assuming quantity > threshold as check.\n')
    end
end
if ~exist('threshold','var') || isempty(threshold)
    threshold = 9e99;
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
                if S(iCv).ZData > threshold
                    fprintf('Warning. High value of quantity at iCv number %d\n',iCv)
                    fprintf('Coordinates:\n R = %f, Z = %f \n', gmtry.cvX(iCv), gmtry.cvY(iCv))
                    fprintf('Cell volume: %f\n', gmtry.cvVol(iCv))
                end
            elseif check_type == 's'
                if S(iCv).ZData < threshold
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
            if (gmtry.cvVxP(iCv,2)==2 && i==2) % it is a guard cell
                all_vertices = gmtry.cvVx(gmtry.cvVxP(iCv,1):gmtry.cvVxP(iCv,1)+gmtry.cvVxP(iCv,2)-1);
                x1 = gmtry.vxX(all_vertices(1));
                x2 = gmtry.vxX(all_vertices(2));
                y1 = gmtry.vxY(all_vertices(1));
                y2 = gmtry.vxY(all_vertices(2));
                P1 = [x1, y1];
                P2 = [x2, y2];
                P3 = [gmtry.cvX(iCv), gmtry.cvY(iCv)];
                v_seg = P2 - P1;
                v_seg_unit = v_seg / norm(v_seg); 
                v_P3_to_seg = P3 - P1;
                projection = dot(v_P3_to_seg, v_seg_unit) * v_seg_unit;
                normal = v_P3_to_seg - projection;
                n = normal / norm(normal);
                shift = 1e-2;
                t = [shift * n(1), shift * n(2)];
                sx1 = x1 + t(1);
                sx2 = x2 + t(1);
                sy1 = y1 + t(2);
                sy2 = y2 + t(2);
                S(iCv).XData = [x1;x2;sx2;sx1];
                S(iCv).YData = [y1;y2;sy2;sy1];
                if (length(field)==gmtry.nVx)
                    S(iCv).ZData = [S(iCv).ZData;field(iVx)];
                end
                continue
            else
                iVx = gmtry.cvVx(gmtry.cvVxP(iCv,1)+i-1);
                S(iCv).XData = [S(iCv).XData;gmtry.vxX(iVx)];
                S(iCv).YData = [S(iCv).YData;gmtry.vxY(iVx)];
                if (length(field)==gmtry.nVx)
                    S(iCv).ZData = [S(iCv).ZData;field(iVx)];
                end
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
nCells = size(S.XData, 2);
p = gobjects(nCells,1);

% Create patch plot
for i = 1:nCells
    p(i) = patch(S.XData(:,i), S.YData(:,i), S.ZData(i)); % Usa colormap di default
end

% Modify border color if ZData goes above threshold
for i = 1:nCells
    if S.ZData(i) > threshold && check_type == 'g'
        set(p(i), 'EdgeColor', 'r', 'LineWidth', 2.5);
    elseif S.ZData(i) < threshold && check_type == 's'
        set(p(i), 'EdgeColor', 'g', 'LineWidth', 2.5)
    end
end
colorbar
% Set axis to fmin and fmax
caxis([fmin fmax]);

% Reset status of hold
if ~hs
    hold off
end

end