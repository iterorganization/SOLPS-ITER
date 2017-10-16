%
%
%
%

% First figure
figure;

subplot(2,4,3);%,'Position',[0.05 0.45 0.2 0.4]
% Level_Te=[0.1,0.2,0.5,0.8,1.0,1.5,2.0,2.5,3.0,5.0,8.0,10.0,12.0,14.0,16.0,18.0,20.0,24.0,28.0,32.0,36.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0,120.0,150.0];
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te_log10',Level_Te,label2D,Plot2DMargins);
Level_Te_log=logspace(0,3,30);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(te),'$T_e, \; \rm eV$','Te_log10',log10(Level_Te_log),label2D,Plot2DMargins);
%legend(hcontour,label2D,'Location','SouthWest');

subplot(2,4,4);
Level_phiTe=[-50 -40 -30 -25 -20 -18 -16 -14 -12 -10 -8 -6 -4 -2 0 2 4 6 8 10 12 14 16 18 20 25 30 40 45 50]/2.0;
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,po./te,'$\varphi/T_e$','poTe',Level_phiTe,label2D,Plot2DMargins);
%legend(hcontour,label2D,'Location','SouthWest');

subplot(2,4,1);
Level_ne_log=logspace(-1,1.699,50);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(ne*1.0e-19),'$n_e, \; \rm 10^{19} \; m^{-3}$','ne_log10',log10(Level_ne_log),label2D,Plot2DMargins);
%legend(hcontour,label2D,'Location','SouthWest');

subplot(2,4,2);
Level_nN_log=logspace(-3,-1.699,30);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nN_tot*1.0e-19),'$n_{N^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nNtot_log10',log10(Level_nN_log),label2D,Plot2DMargins);
%legend(hcontour,label2D,'Location','SouthWest');

subplot(2,4,8);
plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$j_{||}$','jprll_arrows',Plot2DMargins);
legend(label2D,'Location','NorthEast');
legend('boxoff');

subplot(2,4,5);
Level_Qe=[-40000000 -20000000 -10000000 -8000000 -6000000 -4000000 -2000000 -1000000 -800000 -600000 -400000 -200000 -100000 -80000 -60000 -40000 -20000 -10000 0];
Level_Qe_log10=logspace(5,7.6989,30);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(-(she_stel+she_eir)./vol/1.0e6),'$\rm Q^{e}_{loss},\: a+i \; \rm MW/m^3$','Qe_tot_log10',log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins_whole);

subplot(2,4,6);
Level_div_f=[-5e24 -4e24 -3e24 -2e24 -1e24 -8e23 -4e23 -2e23 -1e23 -8e22 -6e22 -4e22 -2e22 -1e22 -8e21 -5e21 -2e21 -1e21 -8e20 -5e20 -2e20 -1e20 -5e19 -2e19 -1e19 0 ...
    1e19 2e19 5e19 1e20 2e20 5e20 8e20 1e21 2e21 5e21 8e21 1e22 2e22 4e22 6e22 8e22 1e23 2e23 4e23 8e23 1e24 2e24 3e24 4e24 5e24]/10.0;
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sna_eir(:,:,is_main)./vol,'$S_{D^{+}} , \rm  \; s^{-1}m^{-3}$','source01_Eirene',Level_div_f*5.0,label2D,Plot2DMargins_whole);

subplot(2,4,7);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sna_eir(:,:,is_N01)./vol,'$S_{N^{+}}, \rm  \; s^{-1}m^{-3}$','sourceN01_Eirene',Level_div_f/100.0,label2D,Plot2DMargins_whole);

print('-depsc2',[PATH_PREFIX,'Subplots.eps']);