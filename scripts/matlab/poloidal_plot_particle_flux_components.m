function iout=poloidal_plot_particle_flux_components(x2,fna,fna_mdf,fna_Dgradna,fna_Dgradpa,fna_vaecrb,fna_PSch,fna_vadiana,fna_cvlana,fna_jvispar,fna_jin,fna_jAN,fna_bxuana,fna_udpc,nb1,ne1,nb2,ne2,npl,Gtitle);

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);

xx=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_mdf1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_Dgradna1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_Dgradpa1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_vaecrb1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_PSch1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_vadiana1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_cvlana1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_jvispar1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_jin1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_jAN1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_bxuana1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
fna_udpc1=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);

xx(1:ne1-nb1+1)=x2(npl+2,nb1+2:ne1+2);
xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+2,nb2+2:ne2+2);
fna1(1:ne1-nb1+1)=fna(npl+2,nb1+2:ne1+2);
fna1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna(npl+2,nb2+2:ne2+2);
fna_mdf1(1:ne1-nb1+1)=fna_mdf(npl+2,nb1+2:ne1+2);
fna_mdf1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_mdf(npl+2,nb2+2:ne2+2);
fna_Dgradna1(1:ne1-nb1+1)=fna_Dgradna(npl+2,nb1+2:ne1+2);
fna_Dgradna1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_Dgradna(npl+2,nb2+2:ne2+2);
fna_Dgradpa1(1:ne1-nb1+1)=fna_Dgradpa(npl+2,nb1+2:ne1+2);
fna_Dgradpa1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_Dgradpa(npl+2,nb2+2:ne2+2);
fna_vaecrb1(1:ne1-nb1+1)=fna_vaecrb(npl+2,nb1+2:ne1+2);
fna_vaecrb1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_vaecrb(npl+2,nb2+2:ne2+2);

% The sign of Pfirsch-Schlueter fluxes is negative due to some unknown
% reasons. To be more correct, they appear in the particle balance and in
% the output with opposite signs.
fna_PSch1(1:ne1-nb1+1)=-fna_PSch(npl+2,nb1+2:ne1+2);
fna_PSch1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=-fna_PSch(npl+2,nb2+2:ne2+2);

fna_vadiana1(1:ne1-nb1+1)=fna_vadiana(npl+2,nb1+2:ne1+2);
fna_vadiana1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_vadiana(npl+2,nb2+2:ne2+2);
fna_cvlana1(1:ne1-nb1+1)=fna_cvlana(npl+2,nb1+2:ne1+2);
fna_cvlana1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_cvlana(npl+2,nb2+2:ne2+2);
fna_jvispar1(1:ne1-nb1+1)=fna_jvispar(npl+2,nb1+2:ne1+2);
fna_jvispar1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_jvispar(npl+2,nb2+2:ne2+2);
fna_jin1(1:ne1-nb1+1)=fna_jin(npl+2,nb1+2:ne1+2);
fna_jin1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_jin(npl+2,nb2+2:ne2+2);
fna_jAN1(1:ne1-nb1+1)=fna_jAN(npl+2,nb1+2:ne1+2);
fna_jAN1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_jAN(npl+2,nb2+2:ne2+2);
fna_bxuana1(1:ne1-nb1+1)=fna_bxuana(npl+2,nb1+2:ne1+2);
fna_bxuana1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_bxuana(npl+2,nb2+2:ne2+2);
fna_udpc1(1:ne1-nb1+1)=fna_udpc(npl+2,nb1+2:ne1+2);
fna_udpc1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=fna_udpc(npl+2,nb2+2:ne2+2);

plot(xx,fna1,'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

plot(xx,fna_mdf1,'-o','LineWidth',2,'Color',[0,0,1]);
hold all;

plot(xx,fna_Dgradna1,'-s','LineWidth',2,'Color',[0.75,0,1]);
hold all;

plot(xx,fna_Dgradpa1,'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

plot(xx,fna_vaecrb1,'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
hold all;

plot(xx,fna_PSch1,'-+','LineWidth',2,'Color',[0.75,0.6,0.15]);
hold all;

plot(xx,fna_vadiana1,'-^','LineWidth',2,'Color',[0,0,0]);
hold all;

plot(xx,fna_cvlana1,'-v','LineWidth',2,'Color',[1,0.05,0.75]);
hold all;

plot(xx,fna_jvispar1,'-h','LineWidth',2,'Color',[0.15,0.05,0.5]);
hold all;

plot(xx,fna_jin1,'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
hold all;

plot(xx,fna_jAN1,'-<','LineWidth',2,'Color',[1,0.6,0]);
hold all;

plot(xx,fna_bxuana1,'-<','LineWidth',2,'Color',[0.2,0.5,0.8]);
hold all;

plot(xx,fna_udpc1,'-<','LineWidth',2,'Color',[0.4,0.2,0.8]);
hold all;

title(Gtitle,'FontName','Times','FontSize',24);
xlabel('Distance from origin, m','FontName','Times','FontSize',24);
ylabel('Particle flux, s^{-1}','FontName','Times','FontSize',24);

legend('\Gamma','\Gamma^{mdf}','D\nabla n','D\nabla p','(ExB)n/B^2','PSch','n u^{dia}','nu^{AN}','j^{vis||}/e','j^{in}/e','j^{AN}/e','nb_xu_{||}','nu^{dpc}','Location','NorthWestOutside');
grid on;
grid minor;
iout=0;