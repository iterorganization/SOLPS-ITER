function iout = R_plot_core_midpl_1Darray(Rmaj,value,ny,nout,nsep,Gtitle,Ylabel);
% Plots VALUE versus major radius at outer midplane
% y2 is a distance from separatrix
% value is a value to be plotted
% nx and ny define grid size
% nsep is an index of cell corresponding to separatrix
% npl is a poloidal cell number
% npl=nout for outer midplane
% npl=nin for inner midplane
% npl=ntop for tokamak top
% npl=nbot for tokamak bottom
% title is a graph title

%figure;
axes('FontName','Times','FontSize',24);
plot(Rmaj(3:nsep+3,nout+2),value(2:nsep+2),'-sr','LineWidth',2);
xlabel('Major radius, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
grid on;
grid minor;

iout = 0;