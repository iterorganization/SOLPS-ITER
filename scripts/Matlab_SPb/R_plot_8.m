function iout = R_plot_8(length,Plot_Flag,value1,value2,value3,value4,value5,value6,value7,value8,ny,npl,Gtitle,Ylabel,label1,label2,label3,label4,label5,label6,label7,label8);
% Plots VALUE versus major radius at outer midplane
% length is a distance from separatrix
% value is a value to be plotted
% nx and ny define grid size
% npl is a poloidal cell number
% npl=nout for outer midplane
% npl=nin for inner midplane
% npl=ntop for tokamak top
% npl=nbot for tokamak bottom
% title is a graph title

if Plot_Flag == 0
% plot all range except southern narrow cell, suitable for fluxes
    i_begin = 2;
    i_end = ny+2;
elseif Plot_Flag == 1
% plot all range except northern narrow cell, suitable for fluxes
    i_begin = 1;
    i_end = ny+1;
elseif Plot_Flag == 2
% plot all range except northern and southern narrow cells, suitable for
% sources
    i_begin = 2;
    i_end = ny+1;
elseif Plot_Flag == -1
% plot all range, suitable for main profiles such as density, temperature,
% potential etc
    i_begin = 1;
    i_end = ny+2;
    
end;
    

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);
plot(length(i_begin:i_end,npl+2),value1(i_begin:i_end,npl+2),'-sr','LineWidth',2);
hold all;
plot(length(i_begin:i_end,npl+2),value2(i_begin:i_end,npl+2),'-o','LineWidth',2);
plot(length(i_begin:i_end,npl+2),value3(i_begin:i_end,npl+2),'-*','Color',[0.45,0.1,0.05],'LineWidth',2);
plot(length(i_begin:i_end,npl+2),value4(i_begin:i_end,npl+2),'-v','Color',[0.75,0.2,0.15],'LineWidth',2);
plot(length(i_begin:i_end,npl+2),value5(i_begin:i_end,npl+2),'-h','Color',[0.15,0.05,0.5],'LineWidth',2);
plot(length(i_begin:i_end,npl+2),value6(i_begin:i_end,npl+2),'->','Color',[0.25,0.5,0.25],'LineWidth',2);
plot(length(i_begin:i_end,npl+2),value7(i_begin:i_end,npl+2),'-<','Color',[1,0.6,0],'LineWidth',2);
plot(length(i_begin:i_end,npl+2),value8(i_begin:i_end,npl+2),'-b','Color',[1,0.05,0.75],'LineWidth',2);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2,label3,label4,label5,label6,label7,label8,'interpreter','latex','FontName','Times','FontSize',24);
grid on;
grid minor;

iout = 0;