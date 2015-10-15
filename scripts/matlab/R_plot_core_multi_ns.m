function iout=R_plot_core_multi_ns(y2,ne,value,ns,nout,nsep,Gtitle,SYMBOL,COLOUR,LABEL);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

is=1;
while is <= ns
     plot(y2(1:nsep+2,nout+2),value(:,is),SYMBOL{is},'LineWidth',2,'Color',COLOUR{is});
     hold all;
     is=is+1;
end;

xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel('n,  m^{-3}','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(LABEL{1:ns},'interpreter','latex','Location','NorthEastOutside');
grid on;
grid minor;
iout=0;