function iout=R_plot_core_multi_ns(y,Flux_flag,value,ns,nout,nsep,Gtitle,Ylabel,SYMBOL,COLOUR,LABEL);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

is=1;
while is <= ns
     if Flux_flag == 0
         % value is defined at the cell center
         plot(y(1:nsep+2,nout+2),value(1:nsep+2,is),SYMBOL{is},'LineWidth',2,'Color',COLOUR{is});
     else
         % value is defined at the cell face like e.g particle flux or current
         plot(y(2:nsep+3,nout+2),value(2:nsep+3,is),SYMBOL{is},'LineWidth',2,'Color',COLOUR{is}); 
     end;
     hold all;
     is=is+1;
end;

xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter','latex','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(LABEL{1:ns},'interpreter','latex','Location','NorthEastOutside');
grid on;
grid minor;
iout=0;