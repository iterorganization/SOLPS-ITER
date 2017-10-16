function iout = R_plot_core_1Darray(y,Flux_flag,value,nsep,npl,Gtitle,Ylabel);



global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
if Flux_flag == 0
    plot(y(1:nsep+2,npl+2),value(1:nsep+2),'-sr','LineWidth',3);
    hold all;
elseif Flux_flag == 1
% Set Flux_flag to 1 if you want to plot e.g. poloidally integrated particle or heat flux
% For this case the plotting range (in iy space) should be shifted
    plot(y(2:nsep+3,npl+2),value(2:nsep+3),'-sr','LineWidth',3);
    hold all;
end;

set(gca,'FontName','Times','FontSize',30);
xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
grid on;
grid minor;

iout = 0;
