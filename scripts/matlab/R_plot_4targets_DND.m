function iout = R_plot_4targets_DND(y2,value,nx,ny,ntt,Ylabel,Gtitle);
% Plots VALUE along all 4 targets in the DND topologgy
% y2 is a distance from separatrix
% value is a value to be plotted
% nx and ny define grid size
% ntt is a poloidal position of top target on computational grid
% title is a graph title

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);
plot(y2(2:ny+1,1),value(2:ny+1,1),'-o','LineWidth',2,'Color',[1,0,0]);
hold all;
plot(y2(2:ny+1,nx+2),value(2:ny+1,nx+2),'-s','LineWidth',2,'Color',[0,0,1]);
hold all;
plot(y2(2:ny+1,ntt+2+2),value(2:ny+1,ntt+2+2),'-+','LineWidth',2,'Color',[0.75,0,1]);
hold all;
plot(y2(2:ny+1,ntt+2),value(2:ny+1,ntt+2),'-*','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;
xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'interpreter', 'latex','FontSize',30,'FontName','Times');
title('Targets','FontSize',30,'FontName','Times');
legend('inner bottom target','outer bottom target','outer top target','inner top target','FontName','Times','FontSize',22,'Location','NorthEast');
grid on;
grid minor;

iout = 0;