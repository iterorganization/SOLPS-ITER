function iout=R_plot_particle_flux_components(y2,fna,fna_mdf,fna_Dgradna,fna_Dgradpa,fna_vaecrb,fna_PSch,fna_vadiana,fna_cvlana,fna_jvispar,fna_jin,fna_jAN,fna_bxuana,fna_udpc,ny,npl,Gtitle);

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);




plot(y2(1:ny+2,npl+2),fna(1:ny+2,npl+2),'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

plot(y2(1:ny+2,npl+2),fna_mdf(1:ny+2,npl+2),'-o','LineWidth',2,'Color',[0,0,1]);
hold all;

plot(y2(1:ny+2,npl+2),fna_Dgradna(1:ny+2,npl+2),'-s','LineWidth',2,'Color',[0.75,0,1]);
hold all;

plot(y2(1:ny+2,npl+2),fna_Dgradpa(1:ny+2,npl+2),'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

plot(y2(1:ny+2,npl+2),fna_vaecrb(1:ny+2,npl+2),'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
hold all;


% The sign of Pfirsch-Schlueter fluxes is negative due to some unknown
% reasons. To be more correct, they appear in the particle balance and in
% the output with opposite signs.
plot(y2(1:ny+2,npl+2),-fna_PSch(1:ny+2,npl+2),'-+','LineWidth',2,'Color',[0.75,0.6,0.15]);
hold all;

plot(y2(1:ny+2,npl+2),fna_vadiana(1:ny+2,npl+2),'-^','LineWidth',2,'Color',[0,0,0]);
hold all;

plot(y2(1:ny+2,npl+2),fna_cvlana(1:ny+2,npl+2),'-v','LineWidth',2,'Color',[1,0.05,0.75]);
hold all;

plot(y2(1:ny+2,npl+2),fna_jvispar(1:ny+2,npl+2),'-h','LineWidth',2,'Color',[0.15,0.05,0.5]);
hold all;

plot(y2(1:ny+2,npl+2),fna_jin(1:ny+2,npl+2),'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
hold all;

plot(y2(1:ny+2,npl+2),fna_jAN(1:ny+2,npl+2),'-<','LineWidth',2,'Color',[1,0.6,0]);
hold all;

plot(y2(1:ny+2,npl+2),fna_bxuana(1:ny+2,npl+2),'-v','LineWidth',2,'Color',[0.2,0.5,0.8]);
hold all;

plot(y2(1:ny+2,npl+2),fna_udpc(1:ny+2,npl+2),'-^','LineWidth',2,'Color',[0.4,0.2,0.8]);
hold all;

title(Gtitle,'FontName','Times','FontSize',24);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',24);
ylabel('Particle flux, s^{-1}','FontName','Times','FontSize',24);

legend('\Gamma','\Gamma^{mdf}','D\nabla n','D\nabla p','(ExB)n/B^2','PSch','n u^{dia}','nu^{AN}','j^{vis||}/e','j^{in}/e','j^{AN}/e','nb_xu_{||}','nu^{dpc}','Location','NorthWestOutside');
grid on;
grid minor;
iout=0;