function iout = R_plot_core8_1Darray(y,Flux_flag,value1,value2,value3,value4,value5,value6,value7,value8,nsep,npl,Gtitle,Ylabel,label1,label2,label3,label4,label5,label6,label7,label8);




global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

%axes('FontName','Times','FontSize',36);
if Flux_flag == 0
    plot(y(2:nsep+2,npl+2),value1(2:nsep+2),'-sr','LineWidth',3);
    hold all;
    plot(y(2:nsep+2,npl+2),value2(2:nsep+2),'-sb','LineWidth',3);
    plot(y(2:nsep+2,npl+2),value3(2:nsep+2),'-c','Color',[0.75,0.2,0.15],'LineWidth',3);
    plot(y(2:nsep+2,npl+2),value4(2:nsep+2),'-h','Color',[0.25,0.5,0.25],'LineWidth',3);
    plot(y(2:nsep+2,npl+2),value5(2:nsep+2),'-v','Color',[1,0.6,0],'LineWidth',3);
    plot(y(2:nsep+2,npl+2),value6(2:nsep+2),'-^','Color',[1,0.05,0.75],'LineWidth',3);
    plot(y(2:nsep+2,npl+2),value7(2:nsep+2),'->','Color',[0.2,0.45,0.9],'LineWidth',3);
    plot(y(2:nsep+2,npl+2),value8(2:nsep+2),'-<','Color',[0.35,0.65,0.15],'LineWidth',3);
elseif Flux_flag == 1
% Set Flux_flag to 1 if you want to plot e.g. poloidally integrated particle or heat flux
% For this case the plotting range (in iy space) should be shifted    plot(y(2:nsep+3,npl+2),value1(2:nsep+3),'-sr','LineWidth',3);
    plot(y(2:nsep+3,npl+2),value1(2:nsep+3),'-sr','LineWidth',3);
    hold all;
    plot(y(2:nsep+3,npl+2),value2(2:nsep+3),'-sb','LineWidth',3);
    plot(y(2:nsep+3,npl+2),value3(2:nsep+3),'-*','Color',[0.75,0.2,0.15],'LineWidth',3);
    plot(y(2:nsep+3,npl+2),value4(2:nsep+3),'-h','Color',[0.25,0.5,0.25],'LineWidth',3);
    plot(y(2:nsep+3,npl+2),value5(2:nsep+3),'-v','Color',[1,0.6,0],'LineWidth',3);
    plot(y(2:nsep+3,npl+2),value6(2:nsep+3),'-^','Color',[1,0.05,0.75],'LineWidth',3);
    plot(y(2:nsep+3,npl+2),value7(2:nsep+3),'->','Color',[0.2,0.45,0.9],'LineWidth',3);
    plot(y(2:nsep+3,npl+2),value8(2:nsep+3),'-<','Color',[0.35,0.65,0.15],'LineWidth',3);
end;

set(gca,'FontName','Times','FontSize',30);
xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2,label3,label4,label5,label6,label7,label8);
%grid on;
%grid minor;
grid(gca,'minor');

iout = 0;
