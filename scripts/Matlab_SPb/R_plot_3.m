function iout = R_plot_3(length,Plot_Flag,value1,value2,value3,ny,npl,Gtitle,Ylabel,label1,label2,label3);

% R_plot_3 produces 3 radial curves on the same plot

% Here

% length     is a distance from separatrix
% value1     is a first value to be plotted
% value2     is a second value to be plotted
% value3
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
% label3

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

if Plot_Flag == 0
% plot all range except southern narrow cell, suitable for fluxes
    i_begin = 2;
    i_end = ny+2;
elseif Plot_Flag == 1
% plot all range except northern narrow cell, suitable for fluxes
    i_begin = 1;
    i_end = ny+1;
elseif Plot_Flag == 2
% plot all range except northern and southern narrow cells, suitable for
% sources
    i_begin = 2;
    i_end = ny+1;
elseif Plot_Flag == -1
% plot all range, suitable for main profiles such as density, temperature,
% potential etc
    i_begin = 1;
    i_end = ny+2;
    
end;

plot(length(i_begin:i_end,npl+2),value1(i_begin:i_end,npl+2),'-sr','LineWidth',2);
hold all;
plot(length(i_begin:i_end,npl+2),value2(i_begin:i_end,npl+2),'-sb','LineWidth',2);
plot(length(i_begin:i_end,npl+2),value3(i_begin:i_end,npl+2),'-s','Color',[0.45,0.1,0.05],'LineWidth',2);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',36);
ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',36);
title(Gtitle,'FontName','Times','FontSize',36);
legend(label1,label2,label3,'interpreter', 'latex');
grid on;
grid minor;

iout = 0;