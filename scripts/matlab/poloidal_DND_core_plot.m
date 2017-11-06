function iout=poloidal_DND_core_plot(x2,value,nc1,nc2,nc3,nc4,npl,Gtitle,Ylabel);
% Plots VALUE versus poloidal coordinate in the core
% x2 is a distance from outer midplane
% value is a value to be plotted
% nx and ny define grid size
% nrad is a radial cell number, -1 < nrad < nsep
%nc1   % number of first cell after first cut
%nc2   % number of last cell before second cut
%nc3   % number of first cell after first cut
%nc4   % number of last cell before second cut

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);
plot(x2(npl,nc1+2:nc2+2),value(npl,nc1+2:nc2+2),'-s','LineWidth',2,'Color',[1,0,0]);
hold all;
plot(x2(npl,nc3+2:nc4+2),value(npl,nc3+2:nc4+2),'-s','LineWidth',2,'Color',[1,0,0]);
hold all;
xlabel('Distance from outer midplane, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter','latex','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
grid on;
grid minor;
iout=0;