function iout=poloidal_plot_current_components(x2,j,j_prll,j_AN,j_in,j_inert,j_dia,j_visper,j_vispar,j_visq,j_stoch,nb1,ne1,nb2,ne2,npl,Gtitle);

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',30);

xx=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_prll1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_AN1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_in1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_inert1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_dia1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_visper1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_visq1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_vispar1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
j_stoch1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);


xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
j1(1:ne1-nb1+1)=j(npl+2,nb1+2:ne1+2);
j1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j(npl+2,nb2+2:ne2+2);
j_prll1(1:ne1-nb1+1)=j_prll(npl+2,nb1+2:ne1+2);
j_prll1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_prll(npl+2,nb2+2:ne2+2);
j_AN1(1:ne1-nb1+1)=j_AN(npl+2,nb1+2:ne1+2);
j_AN1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_AN(npl+2,nb2+2:ne2+2);
j_in1(1:ne1-nb1+1)=j_in(npl+2,nb1+2:ne1+2);
j_in1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_in(npl+2,nb2+2:ne2+2);
j_inert1(1:ne1-nb1+1)=j_inert(npl+2,nb1+2:ne1+2);
j_inert1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_inert(npl+2,nb2+2:ne2+2);
j_dia1(1:ne1-nb1+1)=j_dia(npl+2,nb1+2:ne1+2);
j_dia1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_dia(npl+2,nb2+2:ne2+2);

j_visper1(1:ne1-nb1+1)=j_visper(npl+2,nb1+2:ne1+2);
j_visper1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_visper(npl+2,nb2+2:ne2+2);

j_visq1(1:ne1-nb1+1)=j_visq(npl+2,nb1+2:ne1+2);
j_visq1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_visq(npl+2,nb2+2:ne2+2);
j_vispar1(1:ne1-nb1+1)=j_vispar(npl+2,nb1+2:ne1+2);
j_vispar1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_vispar(npl+2,nb2+2:ne2+2);
j_stoch1(1:ne1-nb1+1)=j_stoch(npl+2,nb1+2:ne1+2);
j_stoch1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=j_stoch(npl+2,nb2+2:ne2+2);
%fna_jin1(1:ne1-nb1+1)=fna_jin(npl+2,nb1+2:ne1+2);
%fna_jin1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_jin(npl+2,nb2+2:ne2+2);
%fna_jAN1(1:ne1-nb1+1)=fna_jAN(npl+2,nb1+2:ne1+2);
%fna_jAN1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_jAN(npl+2,nb2+2:ne2+2);

plot(xx,j1,'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

plot(xx,j_prll1,'-o','LineWidth',2,'Color',[0,0,1]);
hold all;

plot(xx,j_AN1,'-s','LineWidth',2,'Color',[0.75,0,1]);
hold all;

plot(xx,j_in1,'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

plot(xx,j_inert1,'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

plot(xx,j_dia1,'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
hold all;

plot(xx,j_visper1,'-+','LineWidth',2,'Color',[0.75,0.6,0.15]);
hold all;

plot(xx,j_visq1,'-^','LineWidth',2,'Color',[0,0,0]);
hold all;

plot(xx,j_vispar1,'-v','LineWidth',2,'Color',[1,0.05,0.75]);
hold all;

plot(xx,j_stoch1,'-h','LineWidth',2,'Color',[0.15,0.05,0.5]);
hold all;

%plot(xx,fna_jin1,'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
%hold all;

%plot(xx,fna_jAN1,'-<','LineWidth',2,'Color',[1,0.6,0]);
%hold all;

title(Gtitle,'FontName','Times','FontSize',30);
xlabel('Distance from origin (in poloidal direction), m','FontName','Times','FontSize',30);
ylabel('Particle flux, s^{-1}','FontName','Times','FontSize',30);

legend('j','j_{||}','j_{AN}','j_{in}','j_{inert}','j_{dia}','j_{vis \perp}','j_{vis  q}','j_{vis||}','j^{stoch}','Location','NorthWestOutside');
grid on;
grid minor;
iout=0;