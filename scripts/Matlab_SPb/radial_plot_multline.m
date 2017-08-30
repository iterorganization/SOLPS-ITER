function iout=radial_plot_multlinei(length,Plot_Flag,value,ny,npl,nlines,Gtitle,Ylabel);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
npli=0;

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


if npl + npli <= ny && npli <= nlines - 1
% #1
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[1,0,0]);
     hold all;
end;
npli=npli+1;


if npl + npli <= ny && npli <= nlines - 1
% #2
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0,0,1]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #3
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.45,0.1,0.05]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #4
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.75,0.2,0.15]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #5
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0,0,0]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #6
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.15,0.05,0.5]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #7
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.25,0.5,0.25]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #8
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[1,0.6,0]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #9
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[1,0.05,0.75]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #10
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.25,0.5,0.25]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #11
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0,0,1]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #12
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.5,0.5,1]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #13
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.0,0.5,1]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #14
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[1.0,0.5,1]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #15
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.6,0.05,0.4]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #16
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.35,0.65,0.15]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #17
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.8,0.2,0.8]);
     hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
% #18
     plot(length(i_begin:i_end,npl+2),value(i_begin:i_end,npl+2),'-o','LineWidth',2,'Color',[0.2,0.2,0.5]);
     hold all;
end;
npli=npli+1;


set(gca,'FontName','Times','FontSize',30);

xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend('ix','ix+1','ix+2','ix+3','ix+4','ix+5','ix+6','ix+7','ix+8','Location','NorthEastOutside');
grid on;
grid minor;
iout=0;
