function iout = R_plot(length,value,nx,ny,npl,Gtitle,Ylabel);

% R_plot plots value versus distance along the separatrix

% Here

% length     is a distance from separatrix
% value1     is a value to be plotted
% nx and ny  define grid size
% npl        is a poloidal cell number which values are plotted at (in B2
%            notations, i.e. from -1 to nx

% npl=nout   for outer midplane
% npl=nin    for inner midplane
% npl=ntop   for tokamak top
% npl=nbot   for tokamak bottom
%%% FOR TOPOLOGIES WITH LOWER X-POINT ACTIVE
% npl=-1     for inner (bottom) target
% npl=0      for first physical cell at inner (bottom) target
% npl=nx     for outer (bottom) target
% npl=nx-1   for first physical cell at outer (bottom) target
% npl=ntt    for inner top target in Double Null topology
% npl=ntt+1  for outer top target in Double Null topology

% 
% Gtitle     is a graph title
% Ylabel     is a label for ordinate axis

% No legend is added to the graph

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
plot(length(2:ny+1,npl+2),value(2:ny+1,npl+2),'-sr','LineWidth',2);

xlabel('Distance from separatrix, m','FontSize',36,'FontName','Times');
ylabel(Ylabel,'interpreter','latex','FontSize',36,'FontName','Times');
title(Gtitle,'FontSize',36,'FontName','Times');
grid on;
grid minor;

iout = 0;