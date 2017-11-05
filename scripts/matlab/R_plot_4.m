function iout = R_plot_4(y2,value1,value2,value3,value4,nx,ny,npl,Gtitle,Ylabel,label1,label2,label3,label4);
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
plot(y2(1:ny+1,npl+2),value2(1:ny+1,npl+2),'-sb','LineWidth',2);
hold all;
plot(y2(1:ny+1,npl+2),value3(1:ny+1,npl+2),'-sg','LineWidth',2);
hold all;
plot(y2(1:ny+1,npl+2),value4(1:ny+1,npl+2),'-sm','LineWidth',2);

xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2,label3,label4,'interpreter', 'latex');
grid on;
grid minor;

iout = 0;