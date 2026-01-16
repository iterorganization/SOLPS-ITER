function [Ch,seph,strh] = contourfplot_c(structure,gmtry,field,varargin)
% [Ch,seph,strh] = contourfplot_c(structure,gmtry,field,scale,ncont,fmin,fmax)
%
% Routine to make contourfplot of cell centered quantity.
% 
% Input arguments:
%
% - structure : struct with r and z coordinates of structure
% - gmtry     : struct read from b2fgmtry-file
% - field     : cell centered field to be plotted
% - scale     : scale factor for data in field (optional)
% - ncont     : number of contour levels (optional)
% - fmin      : min. contour value (optional)
% - fmax      : max. contour value (optional)
%
% Output arguments:
%
% - Ch   : handle to the contourfplot
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
Ch   = contourfplot(gmtry,field,varargin{:});
seph = plotsep(gmtry,'color',[1 1 1]);
strh = plotstructure(structure,'color',[0 0 0],'LineWidth',2);
hold off;

% Make contours invisible
for i = 1:length(Ch)
    set(Ch(i).h,'LineStyle','none');
end

% Set labels etc.
xlabel('R (m)','fontsize',18);
ylabel('Z (m)','fontsize',18);
set(gca,'fontsize',18);
colorbar('EastOutside');
axis tight;
axis equal;
box on;