function iout = R_plot_core2_1Darray(y2,value1,value2,ny,nsep,npl,Gtitle,Ylabel,label1,label2);




global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

%axes('FontName','Times','FontSize',36);
plot(y2(2:nsep+2,npl+2),value1(2:nsep+2),'-sr','LineWidth',3);
hold all;
plot(y2(2:nsep+2,npl+2),value2(2:nsep+2),'-sb','LineWidth',3);
set(gca,'FontName','Times','FontSize',30);
xlabel('Distance from separatrix, m','FontSize',36,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',36);
title(Gtitle,'FontName','Times','FontSize',36);
legend(label1,label2);
%grid on;
%grid minor;
grid(gca,'minor');

iout = 0;