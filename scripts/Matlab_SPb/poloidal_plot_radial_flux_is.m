function iout=poloidal_plot_poloidal_flux_is(x2,f,f_mdf,f_Dgradn,f_nvAN,f_nvExB,f_PSch,f_nupar,f_nuDPC,nb1,ne1,nb2,ne2,npl,is,Gtitle);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

xx=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
value1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);

xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);

value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f_mdf(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-o','LineWidth',2,'Color',[0,0,1]);
hold all;

value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f_Dgradn(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-s','LineWidth',2,'Color',[0.75,0,1]);
hold all;

value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f_nvAN(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f_nvExB(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
hold all;

% The sign of Pfirsch-Schlueter fluxes is negative due to some unknown
% reasons. To be more correct, they appear in the particle balance and in
% the output with opposite signs.
value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=-f_PSch(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-+','LineWidth',2,'Color',[0.75,0.6,0.15]);
hold all;


value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f_nupar(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'-h','LineWidth',2,'Color',[0.15,0.05,0.5]);
hold all;

value1(1:ne1-nb1+1)=value(npl+2,nb1+2:ne1+2);
value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=f_nuDPC(npl+2,nb2+2:ne2+2,is);
plot(xx,value1,'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
hold all;

set(gca,'FontName','Times','FontSize',30);

title(Gtitle,'FontName','Times','FontSize',24);
xlabel('Distance from origin in poloidal direction, m','FontName','Times','FontSize',24);
ylabel('Particle flux, s^{-1}','FontName','Times','FontSize',24);

legend('\Gamma','\Gamma^{mdf}','D\nabla n','nu^{AN}','(ExB)n/B^2','PSch','nu_{||}','nu_{DPC}','Location','Best');

grid on;
grid minor;
iout=0;
