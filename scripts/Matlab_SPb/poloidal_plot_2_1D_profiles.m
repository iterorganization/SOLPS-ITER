function iout=poloidal_plot_2_1D_profiles(x2,value1,value2,...
    nb1,ne1,nb2,ne2,npl,Gtitle,Ylabel,label1,label2);

% Plots 12 VALUEs versus poloidal coordinate in the core and in any other
% region in a ix range from nb1 to ne1 and from nb2 to ne2
% x2 is a distance from outer midplane
% value is a value to be plotted
% nx and ny define grid size
% nrad is a radial cell number

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

xx=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
value=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);

xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
value(1:ne1-nb1+1)=value1(nb1+2:ne1+2);
value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value1(1,nb2+2:ne2+2);
plot(xx,value,'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
value(1:ne1-nb1+1)=value2(nb1+2:ne1+2);
value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value2(1,nb2+2:ne2+2);
plot(xx,value,'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value3(1,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value3(nb2+2:ne2+2);
% % % plot(xx,value,'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value4(nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value4(nb2+2:ne2+2);
% % % plot(xx,value,'-h','LineWidth',2,'Color',[0,0,0]);
% % % hold all;

% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value5(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value5(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'-o','LineWidth',2,'Color',[0.15,0.05,0.5]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value6(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value6(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value7(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value7(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'-<','LineWidth',2,'Color',[1,0.6,0]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value8(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value8(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'-s','LineWidth',2,'Color',[1,0.05,0.75]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value9(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value9(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'-h','LineWidth',2,'Color',[0.25,0.5,0.25]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value10(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value10(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'-o','LineWidth',2,'Color',[1,0.6,0]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value11(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value11(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'-*','LineWidth',2,'Color',[1,0.05,0.75]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value12(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value12(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'->','LineWidth',2,'Color',[0,0,1]);
% % % hold all;
% % % 
% % % xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
% % % xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
% % % value(1:ne1-nb1+1)=value12(npl+2,nb1+2:ne1+2);
% % % value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value13(npl+2,nb2+2:ne2+2);
% % % plot(xx,value,'->','LineWidth',2,'Color',[0.5,0.5,0.5]);
% % % hold all;

xlabel('Distance from outer midplane, m','FontName','Times','FontSize',36);
ylabel(Ylabel,'interpreter','latex','FontName','Times','FontSize',36);
title(Gtitle,'FontName','Times','FontSize',36);

set(gca,'FontName','Times','FontSize',30);

legend(label1,label2,'interpreter','latex','FontName','Times','FontSize',24);

grid on;
grid minor;
iout=0;
