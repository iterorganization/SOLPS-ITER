function [p,seph,strh] = patchplot_c(structure,gmtry,field,varargin)
% [p,seph,strh] = patchplot_c(structure,gmtry,field,scale,fmin,fmax)
%
% Routine to make patchplot of cell centered quantity.
% 
% Input arguments:
%
% - structure : struct with r and z coordinates of structure
% - gmtry     : struct read from b2fgmtry-file
% - field     : cell centered field to be plotted
% - scale     : scale factor for data in field (optional)
% - fmin      : min. contour value (optional)
% - fmax      : max. contour value (optional)
%
% Output arguments:
%
% - p    : handle to the patch plot
% - seph : handle to separatrix plot
% - strh : handle to the structure plot
%
% Example:
%
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

figure; hold on;
p    = patchplot(gmtry,field,varargin{:});
seph = plotsep(gmtry,'color',[1 1 1]);
strh = plotstructure(structure,'color',[0 0 0],'LineWidth',2);
hold off;

% Set labels etc.
xlabel('R (m)','fontsize',18);
ylabel('Z (m)','fontsize',18);
set(gca,'fontsize',18);
colorbar('Eastoutside');
axis tight;
axis equal;
box on;