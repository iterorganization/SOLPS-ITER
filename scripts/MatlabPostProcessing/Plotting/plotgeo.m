function h = plotgeo(geo)
% h = plotgeo(geo,options)
%
% Routine to plot grid from carre output (.geo file).
%
% Input arguments:
%
% - geo     : struct read from .geo-file
% - options : list of plot options compatible with Matlab plot command
%
% Output arguments:
%
% - h       : struct with vectors of handles to the plot objects

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% July 2019

% Check current status of hold
hs = ishold;

% Init output
h  = struct('h',[]);
        
% Plot all cells as individual polygons
nx = size(geo.crxs,1);
ny = size(geo.crxs,2);
for j = 1:ny
    for i = 1:nx
        k = i + (j-1)*nx;
        rco    = [geo.crxs(i,j,2),geo.crxs(i,j,3),geo.crxs(i,j,5),geo.crxs(i,j,4),geo.crxs(i,j,2)];
        zco    = [geo.crys(i,j,2),geo.crys(i,j,3),geo.crys(i,j,5),geo.crys(i,j,4),geo.crys(i,j,2)];
        if (geo.cflags(i,j,1) == 1 )
            h(k).h = plot(rco,zco, 'b');hold on;
        elseif (geo.cflags(i,j,1) == 3)
            h(k).h = plot(rco,zco, 'r');hold on;
        else
            h(k).h = plot(rco,zco, 'k');hold on;
        end
    end
end


% Reset status of hold
if ~hs, hold off; end;



