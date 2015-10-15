function iout = R_plot_2(length,value1,value2,nx,ny,npl,Gtitle,Ylabel,label1,label2);

% R_plot_2 produces 2 radial curves on the same plot

% Here

% length     is a distance from separatrix
% value1     is a first value to be plotted
% value2     is a second value to be plotted
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

% label1     is a label for the first value in legend
% label2     is a label for the second value in legend

%figure;
global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);
%axes('FontName','Times','FontSize',24);
plot(length(1:ny+1,npl+2),value1(1:ny+1,npl+2),'-sr','LineWidth',2);
hold all;
plot(length(1:ny+1,npl+2),value2(1:ny+1,npl+2),'-sb','LineWidth',2);
set(gca,'FontName','Times','FontSize',30);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',36);
ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',36);
title(Gtitle,'FontName','Times','FontSize',36);
legend(label1,label2,'interpreter', 'latex');
grid on;
grid minor;

iout = 0;