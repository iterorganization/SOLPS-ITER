function iout=R_plot_densities_multi_ns(y2,ne,na,ns,ny,npl,Gtitle,SYMBOL,COLOUR,LABEL);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

is=1;
while is <= ns
     semilogy(y2(1:ny+2,npl+2),na(1:ny+2,npl+2,is),SYMBOL{is},'LineWidth',2,'Color',COLOUR{is});
     hold all;
     is=is+1;
end;

semilogy(y2(1:ny+2,npl+2),ne(1:ny+2,npl+2),'-o','LineWidth',2,'Color',[0.75,0.0,0.75]);
hold all;

xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel('n,  m^{-3}','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
legend(LABEL{1:ns+1},'interpreter','latex','Location','NorthEastOutside');
grid on;
grid minor;
iout=0;