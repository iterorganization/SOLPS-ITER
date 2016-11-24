function h = plotstructure(structure,varargin)
% h = plotstructure(structure,options)
%
% Routine to plot structure (vessel, templates, ...).
% 
% Input arguments:
%
% - structure : struct containing r and z coordinates of the structure
% - options   : list of plot options compatible with Matlab plot command
%
%
% Output arguments:
%
% - h   : column vector of handles to the different parts of the structure
%
%
% Example:
%
% plotstructure(wall,'color',[0 0 0],'LineWidth',2);
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Check current status of hold
hs = ishold;

% Plot individual segments
h = zeros(length(structure),1);
for i = 1:length(structure)
    h(i) = plot(structure(i).r,structure(i).z,varargin{:}); hold on;
end

% Reset status of hold
if ~hs, hold off; end;