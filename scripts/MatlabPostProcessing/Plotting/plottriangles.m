function h = plottriangles(tri,varargin)
% h = plottriangles(triangles,options)
%
% Routine to plot triangle grid. Interface to Matlab triplot command.
%
% Input arguments:
%
% - triangles : struct read from fort.33, fort.34, fort.35 files
%               (function read_triangle_mesh.m)
% - options   : list of plot options compatible with Matlab triplot command
%
% Output arguments:
%
% - h       : handle to the plot object
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

h = triplot(tri.cells,tri.nodes(:,1),tri.nodes(:,2),varargin{:});
