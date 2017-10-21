function iout=poloidal_DND_core_plot(x2,value,nb1,ne1,nb2,ne2,npl,Gtitle,Ylabel);
% Plots VALUE versus poloidal coordinate in the core and in any other
% region in a ix range from nb1 to ne1 and from nb2 to ne2
% x2 is a distance from outer midplane
% value is a value to be plotted
% nx and ny define grid size
% nrad is a radial cell number, -1 < nrad < nsep


global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

xx=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
value=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);

xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
value(1:ne1-nb1+1)=value1(npl+2,nb1+2:ne1+2);
value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value1(npl+2,nb2+2:ne2+2);
plot(xx,value,'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

set(gca,'FontName','Times','FontSize',30);

xlabel('Distance from outer midplane, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter','latex','FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
grid on;
grid minor;
iout=0;
