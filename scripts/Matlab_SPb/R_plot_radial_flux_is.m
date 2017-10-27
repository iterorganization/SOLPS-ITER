function iout=R_plot_radial_flux_is(y,F,F_mdf,F_Dgradn,F_nvAN,F_nvExB,F_PSch,F_jAN,F_jvispar,F_jvisper,F_jvisq,F_jinert,npl,nsep,is,Gtitle);

global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);

plot(y(2:nsep+3,npl),F(2:nsep+3,is),'-o','LineWidth',2,'Color',[1,0,0]);
hold all;

plot(y(2:nsep+3,npl),F_mdf(2:nsep+3,is),'-o','LineWidth',2,'Color',[0,0,1]);
hold all;

plot(y(2:nsep+3,npl),F_Dgradn(2:nsep+3,is),'-s','LineWidth',2,'Color',[0.75,0,1]);
hold all;

plot(y(2:nsep+3,npl),F_nvAN(2:nsep+3,is),'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
hold all;

plot(y(2:nsep+3,npl),F_nvExB(2:nsep+3,is),'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
hold all;

% The sign of Pfirsch-Schlueter fluxes is negative due to some unknown
% reasons. To be more correct, they appear in the particle balance and in
% the output with opposite signs.
plot(y(2:nsep+3,npl),-F_PSch(2:nsep+3,is),'-+','LineWidth',2,'Color',[0.75,0.6,0.15]);
hold all;

if is==2 

plot(y(2:nsep+3,npl),F_jAN(2:nsep+3),'-h','LineWidth',2,'Color',[0.15,0.05,0.5]);
hold all;

plot(y(2:nsep+3,npl),F_jvispar(2:nsep+3),'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
hold all;

plot(y(2:nsep+3,npl),F_jvisper(2:nsep+3),'-<','LineWidth',2,'Color',[1,0.6,0]);
hold all;

plot(y(2:nsep+3,npl),F_jvisq(2:nsep+3),'-v','LineWidth',2,'Color',[0.2,0.5,0.8]);
hold all;

plot(y(2:nsep+3,npl),F_jinert(2:nsep+3),'-^','LineWidth',2,'Color',[0.4,0.2,0.8]);
hold all;

end;


title(Gtitle,'FontName','Times','FontSize',24);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',24);
ylabel('Particle flux, s^{-1}','FontName','Times','FontSize',24);

legend('\Gamma','\Gamma^{mdf}','D\nabla n','nu^{AN}','(ExB)n/B^2','PSch','j^{AN}/e','j^{vis||}/e','j^{visper}/e','j^{visq}/e','j^{inert}/e','Location','Best');

grid on;
grid minor;
iout=0;