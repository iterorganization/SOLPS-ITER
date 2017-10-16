function iout = R_plot_core2_1Darray(y,Flux_flag,value1,value2,nsep,npl,Gtitle,Ylabel,label1,label2);




global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

%axes('FontName','Times','FontSize',36);
if Flux_flag == 0
    plot(y(1:nsep+2,npl+2),value1(1:nsep+2),'-sr','LineWidth',3);
    hold all;
    plot(y(1:nsep+2,npl+2),value2(1:nsep+2),'-sb','LineWidth',3);
elseif Flux_flag == 1
% Set Flux_flag to 1 if you want to plot e.g. poloidally integrated particle or heat flux
% For this case the plotting range (in iy space) should be shifted    plot(y(2:nsep+3,npl+2),value1(2:nsep+3),'-sr','LineWidth',3);
    plot(y(2:nsep+3,npl+2),value1(2:nsep+3),'-sr','LineWidth',3);
    hold all;
    plot(y(2:nsep+3,npl+2),value2(2:nsep+3),'-sb','LineWidth',3);
end;

set(gca,'FontName','Times','FontSize',30);
xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2);
%grid on;
%grid minor;
grid(gca,'minor');

iout = 0;
