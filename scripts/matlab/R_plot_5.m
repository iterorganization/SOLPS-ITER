function iout = R_plot_5(y2,value1,value2,value3,value4,value5,nx,ny,npl,Gtitle,Ylabel,label1,label2,label3,label4,label5);
% Plots VALUE versus major radius at outer midplane
% y2 is a distance from separatrix
% value is a value to be plotted
% nx and ny define grid size
% npl is a poloidal cell number
% npl=nout for outer midplane
% npl=nin for inner midplane
% npl=ntop for tokamak top
% npl=nbot for tokamak bottom
% title is a graph title

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);
plot(y2(1:ny+1,npl+2),value1(1:ny+1,npl+2),'-sr','LineWidth',2);
hold all;
plot(y2(1:ny+1,npl+2),value2(1:ny+1,npl+2),'-ob','LineWidth',2);
plot(y2(1:ny+1,npl+2),value3(1:ny+1,npl+2),'-*','Color',[0.45,0.1,0.05],'LineWidth',2);
plot(y2(1:ny+1,npl+2),value4(1:ny+1,npl+2),'-v','Color',[0.75,0.2,0.15],'LineWidth',2);
plot(y2(1:ny+1,npl+2),value5(1:ny+1,npl+2),'-h','Color',[0.15,0.05,0.5],'LineWidth',2);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2,label3,label4,label5,'interpreter','latex','FontName','Times','FontSize',24);
grid on;
grid minor;

iout = 0;