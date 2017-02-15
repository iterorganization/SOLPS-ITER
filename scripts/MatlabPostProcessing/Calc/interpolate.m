function fieldI = interpolate(gmtry,field,rcoI,zcoI)
% fieldI = interpolate(gmtry,field,rcoI,zcoI)
%
% Interpolate field in the points specified by arrays rcoI and zcoI.
% rcoI and zcoI must have the same size.
% fieldI is an array with interpolated values with size of rcoI.
% 
% gmtry is either a gmtry-struct (read from a b2fgmtry-file), or a
% triangles-struct (read from fort.33, fort.34, fort.35 files). 
%
% field is assumed to be defined in cell centers (in case of a plasma 
% grid), or in triangle centers (in case of a triangle grid).
%
% The routine is a simple wrapper routine for the Matlab routine griddata.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

if isplasmagrid(gmtry)
    % Assume gmtry is a plasma grid, and field defined in cell centers
    rco = mean(gmtry.crx,3);
    zco = mean(gmtry.cry,3);
    % Set grid edge, to avoid extrapolating beyond this edge below
    if gmtry.nncut == 0
        % Contourclockwise for outer grid boundary, clockwise for core boundary
        rpol = [rco(end,1:end)';rco(end:-1:1,end);rco(1,end:-1:1)';rco(1:end,1)];
        zpol = [zco(end,1:end)';zco(end:-1:1,end);zco(1,end:-1:1)';zco(1:end,1)];
    elseif gmtry.nncut == 1
        % Contourclockwise for outer grid boundary, clockwise for core boundary
        rpol = [rco(end,1:end)';rco(end:-1:1,end);rco(1,end:-1:1)';...           % Outer target, outer wall, inner target
                rco(1:gmtry.leftcut+1,1);rco(gmtry.rightcut+2:end,1);...         % Inner PFR, outer PFR
                NaN;
                rco(gmtry.leftcut+2:gmtry.rightcut+1,1);rco(gmtry.leftcut+2,1)]; % Core
        zpol = [zco(end,1:end)';zco(end:-1:1,end);zco(1,end:-1:1)';...           % Outer target, outer wall, inner target
                zco(1:gmtry.leftcut+1,1);zco(gmtry.rightcut+2:end,1);...         % Inner PFR, outer PFR
                NaN;
                zco(gmtry.leftcut+2:gmtry.rightcut+1,1);zco(gmtry.leftcut+2,1)]; % Core
    else
        error('interpolate: wrong number of cuts');
    end
elseif istrianglegrid(gmtry)
    % Assume gmtry is a triangle grid, and field defined in centers of
    % gravity of the triangles
    rco = mean([gmtry.nodes(gmtry.cells(:,1),1),...
                gmtry.nodes(gmtry.cells(:,2),1),...
                gmtry.nodes(gmtry.cells(:,3),1)],2);
    zco = mean([gmtry.nodes(gmtry.cells(:,1),2),...
                gmtry.nodes(gmtry.cells(:,2),2),...
                gmtry.nodes(gmtry.cells(:,3),2)],2);
    % Todo: identify outer contours of the triangle grid, to avoid
    % extrapolation beyond this point
    disp ('interpolate: warning, may extrapolate...');
    rpol = [-1e30  1e30  1e30 -1e30 -1e30];
    zpol = [-1e30 -1e30  1e30  1e30 -1e30];
else
    error('interpolate: wrong gmtry structure');
end

% Interpolate to rcoI, zcoI
fieldI = griddata(rco,zco,field,rcoI,zcoI);

% Check whether points rcoI and zcoI are actually inside any of the
% cells/triangles. If not, return 0;
ingrid = inpolygon(rcoI,zcoI,rpol,zpol);
fieldI(~ingrid) = 0;
