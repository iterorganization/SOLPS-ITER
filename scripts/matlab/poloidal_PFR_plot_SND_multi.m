function iout=poloidal_PFR_plot_SND_multi(x2,value,nc1,nc2,npl,Gtitle,Ylabel);

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);
plot(x2(npl+2,nc1+2:nc2+2),value(npl+2,nc1+2:nc2+2),'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

xlabel('Distance from outer midplane, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
grid on;
grid minor;
iout=0;