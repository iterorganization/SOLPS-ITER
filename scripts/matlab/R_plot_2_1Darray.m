function iout = R_plot_2_1Darray(y2,value1,value2,ny,npl,Gtitle,Ylabel,label1,label2);



global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
plot(y2(2:ny+2,npl+2),value1(2:ny+2),'-sr','LineWidth',2);
hold all;
plot(y2(2:ny+2,npl+2),value2(2:ny+2),'-sb','LineWidth',2);
xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2);
grid on;
grid minor;

iout = 0;