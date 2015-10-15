function iout=poloidal_core_plot_SND_multi(x2,value,nc1,nc2,npl,Gtitle,Ylabel);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
plot(x2(npl+2,nc1+2:nc2+2),value(npl+2,nc1+2:nc2+2),'-o','LineWidth',2,'Color',[1,0,0]);
hold all;
plot(x2(npl+1,nc1+2:nc2+2),value(npl+1,nc1+2:nc2+2),'-s','LineWidth',2,'Color',[0,0,1]);
hold all;
plot(x2(npl,nc1+2:nc2+2),value(npl,nc1+2:nc2+2),'-*','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;
plot(x2(npl-1,nc1+2:nc2+2),value(npl-1,nc1+2:nc2+2),'-h','LineWidth',2,'Color',[0.75,0.2,0.15]);
hold all;
plot(x2(npl-2,nc1+2:nc2+2),value(npl-2,nc1+2:nc2+2),'-^','LineWidth',2,'Color',[0,0,0]);
hold all;
plot(x2(npl-3,nc1+2:nc2+2),value(npl-3,nc1+2:nc2+2),'->','LineWidth',2,'Color',[0.15,0.05,0.5]);
hold all;
plot(x2(npl-4,nc1+2:nc2+2),value(npl-4,nc1+2:nc2+2),'-<','LineWidth',2,'Color',[0.25,0.5,0.25]);
hold all;
plot(x2(npl-5,nc1+2:nc2+2),value(npl-5,nc1+2:nc2+2),'-v','LineWidth',2,'Color',[1,0.6,0]);
hold all;
plot(x2(npl-6,nc1+2:nc2+2),value(npl-6,nc1+2:nc2+2),'-+','LineWidth',2,'Color',[1,0.05,0.75]);
hold all;

xlabel('Distance from outer midplane, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend('iy','iy-1','iy-2','iy-3','iy-4','iy-5','iy-6','iy-7','iy-8','Location','NorthEastOutside');
grid on;
grid minor;
iout=0;