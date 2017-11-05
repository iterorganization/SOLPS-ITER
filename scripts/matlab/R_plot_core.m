function iout = R_plot_core(y2,value,nx,ny,nsep,npl,Gtitle,Ylabel);



global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
plot(y2(2:nsep+2,npl),value(2:nsep+2,npl),'-sr','LineWidth',2);
xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
grid on;
grid minor;

iout = 0;