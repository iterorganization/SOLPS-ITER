%set(0,'DefaultFigureWindowStyle','docked')
%format compact

Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0,60.0,80.0,100.0]; 
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ne*1.0e-19,'$n_e, \; \rm 10^{19} \; m^{-3}$','ne',Level_ne,label2D,Plot2DMargins);

if exist('is_D01','var')  
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_D01-1)*1.0e-19,['$n_{',label{is_D01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nD00',Level_ne,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_D01)*1.0e-19,['$n_{',label{is_D01},'}, \; \rm 10^{19} \; m^{-3}$'],'nD01',Level_ne,label2D,Plot2DMargins);
end;

if exist('is_T01','var')  
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_T01-1)*1.0e-19,['$n_{',label{is_T01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nD00',Level_ne,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_T01)*1.0e-19,['$n_{',label{is_T01},'}, \; \rm 10^{19} \; m^{-3}$'],'nD01',Level_ne,label2D,Plot2DMargins);
end;

if EIRENE_flag==1
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,nD2*1.0e-19,'$n_{D_2}, \; \rm 10^{19} \; m^{-3}$','nD2',Level_ne,label2D,Plot2DMargins);
end;


if exist('is_C01','var')
    Level_nC=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5,0.8,1.0,1.5,2.0]; 

    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C01-1)*1.0e-19,['$n_{',label{is_C01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nC00',Level_nC,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C01)*1.0e-19,['$n_{',label{is_C01},'}, \; \rm 10^{19} \; m^{-3}$'],'nC01',Level_nC,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C02)*1.0e-19,['$n_{',label{is_C02},'}, \; \rm 10^{19} \; m^{-3}$'],'nC02',Level_nC,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C03)*1.0e-19,['$n_{',label{is_C03},'}, \; \rm 10^{19} \; m^{-3}$'],'nC03',Level_nC,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C04)*1.0e-19,['$n_{',label{is_C04},'}, \; \rm 10^{19} \; m^{-3}$'],'nC04',Level_nC,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C05)*1.0e-19,['$n_{',label{is_C05},'}, \; \rm 10^{19} \; m^{-3}$'],'nC05',Level_nC,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C06)*1.0e-19,['$n_{',label{is_C06},'}, \; \rm 10^{19} \; m^{-3}$'],'nC06',Level_nC,label2D,Plot2DMargins);

    Level_nCtot=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(na(:,:,3)+na(:,:,4)+na(:,:,5)+na(:,:,6)+na(:,:,7)+na(:,:,8)+na(:,:,9))*1.0e-19,'$n_{C^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nCtot',Level_nCtot,label2D,Plot2DMargins);
end;

if exist('is_N01','var')
    Level_nN=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5,0.8,1.0,1.5,2.0]; 

    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N01-1)*1.0e-19,['$n_{',label{is_N01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nN00',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N01)*1.0e-19,['$n_{',label{is_N01},'}, \; \rm 10^{19} \; m^{-3}$'],'nN01',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N02)*1.0e-19,['$n_{',label{is_N02},'}, \; \rm 10^{19} \; m^{-3}$'],'nn02',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N03)*1.0e-19,['$n_{',label{is_N03},'}, \; \rm 10^{19} \; m^{-3}$'],'nN03',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N04)*1.0e-19,['$n_{',label{is_N04},'}, \; \rm 10^{19} \; m^{-3}$'],'nN04',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N05)*1.0e-19,['$n_{',label{is_N05},'}, \; \rm 10^{19} \; m^{-3}$'],'nN05',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N06)*1.0e-19,['$n_{',label{is_N06},'}, \; \rm 10^{19} \; m^{-3}$'],'nN06',Level_nN,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_N07)*1.0e-19,['$n_{',label{is_N07},'}, \; \rm 10^{19} \; m^{-3}$'],'nN07',Level_nN,label2D,Plot2DMargins);

    Level_nCtot=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(na(:,:,3)+na(:,:,4)+na(:,:,5)+na(:,:,6)+na(:,:,7)+na(:,:,8)+na(:,:,9))*1.0e-19,'$n_{N^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nNtot',Level_nCtot,label2D,Plot2DMargins);
end;

Level_Zeff=[1.0,1.05,1.1,1.15,1.2,1.25,1.3,1.35,1.4,1.45,1.5,1.55,1.6,1.65,1.7,1.75,1.8,1.85,1.9,1.95,2.0,2.05,2.1,2.15,2.2,2.25,2.3,2.35,2.4,2.45,2.5,2.55,2.6,2.65,2.7,2.75,2.8,2.85,2.9,2.95,3.0]; 
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,Zeff,'$Z_{eff}$','Zeff',Level_Zeff,label2D,Plot2DMargins);


if exist('is_D01','var')
    Level_uaD=[-6e4 -5e4 -4e4 -3e4 -2e4 -1.6e4 -1.2e4 -0.8e4 -0.4e4 -0.2e4 -0.1e4 -0.6e3 -0.4e3 -0.2e3 -0.1e3 0 0.1e3 0.2e3 0.1e4 0.2e4 0.4e4 0.8e4 1.2e4 1.6e4 2e4 3e4 4e4 5e4 6e4];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_D01),['$u_{',label{is_D01},'}, \; m/s$'],'uD01',Level_uaD,label2D,Plot2DMargins);
    Level_MachD=[-3.0 -2.5 -2.0 -1.5 -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_D01)./cs_mi,['$M_{',label{is_D01},'}, $'],'MD01',Level_MachD,label2D,Plot2DMargins);
    plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_D01),['$u_{',label{is_D01},'}$'],'uD01_arrows',Plot2DMargins);
end;

if exist('is_T01','var')
    Level_uaT=[-6e4 -5e4 -4e4 -3e4 -2e4 -1.6e4 -1.2e4 -0.8e4 -0.4e4 -0.2e4 -0.1e4 -0.6e3 -0.4e3 -0.2e3 -0.1e3 0 0.1e3 0.2e3 0.1e4 0.2e4 0.4e4 0.8e4 1.2e4 1.6e4 2e4 3e4 4e4 5e4 6e4];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_T01),['$u_{',label{is_T01},'}, \; m/s$'],'uT01',Level_uaD,label2D,Plot2DMargins);
    Level_MachT=[-3.0 -2.5 -2.0 -1.5 -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_T01)./cs_mi,['$M_{',label{is_T01},'}, $'],'MT01',Level_MachT,label2D,Plot2DMargins);
    plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_T01),['$u_{',label{is_T01},'}$'],'uT01_arrows',Plot2DMargins);
end;


% Level_Mach=[-3.0 -2.5 -2.0 -1.5 -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0];
% plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,2)./cs_mi,'$M_{D^{+}}, $','MD01',Level_Mach,label2D,Plot2DMargins);



Level_potential=[-200,-150,-100,-50,-20,-10,-5,0,5,10,15,20,25,30,35,40,45,50,60,70,80,90,100,110,120,130,140,150,200];
%Level_potential=[-200,-150,-100,-50,-20,-10,-5,0,5,10,15,20,25,30,35,40,45,50,60,70,80,90,100];
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,po,'$\varphi, \; \rm V$','po',Level_potential,label2D,Plot2DMargins);

Level_phiTe=[-3,-2,-1,0,1,2,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,3.0,3.1,3.2,3.5,4,5,10,15,20,25,30,35,40];
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,po./te,'$\varphi/T_e$','poTe',Level_phiTe,label2D,Plot2DMargins);


Level_Te=[0.1,0.2,0.5,0.8,1.0,1.5,2.0,2.5,3.0,5.0,8.0,10.0,12.0,14.0,16.0,18.0,20.0,24.0,28.0,32.0,36.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0,120.0,150.0];
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te',Level_Te,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ti,'$T_i, \; \rm eV$','Ti',Level_Te,label2D,Plot2DMargins);


Level_Te=[0.1,0.2,0.5,0.8,1.0,1.2,1.5,2.0,2.5,3.0,5.0,8.0,10.0];
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te1',Level_Te,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ti,'$T_i, \; \rm eV$','Ti1',Level_Te,label2D,Plot2DMargins);

Level_Te=[0.1,0.2,0.5,0.8,1.0,1.2,1.5,2.0,2.5,3.0,5.0,8.0,10.0,20.0,30.0,40.0];
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te2',Level_Te,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ti,'$T_i, \; \rm eV$','Ti2',Level_Te,label2D,Plot2DMargins);

iout= plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,pas/1000,'$p_{tot},  kPa$','p_tot',[0 100 150 200 250 300 350 400 450 500 550 600 800 1000 1200 1400 1600 1800 2000 2200 2500 2800 3000]/1000,label2D,Plot2DMargins);


% In this block only main ions are proceeded
Level_div_f=[-5e24 -4e24 -3e24 -2e24 -1e24 -8e23 -4e23 -2e23 -1e23 -8e22 -6e22 -4e22 -2e22 0 2e22 4e22 6e22 8e22 1e23 2e23 4e23 8e23 1e24 2e24 3e24 4e24 5e24];

iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f,['${\rm div} \: \Gamma^{(main \; ions)}, \rm \; s^{-1}m^{-3}$'],'div_f01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_x+div_fvp_x+div_fDgrn_x,'${\rm div} \: (nu_{x}^{E\times B}+nb_xu_{||}-D\nabla_x n), \rm  \; s^{-1}m^{-3} \; (main \; ions)$','div_f_x01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_y,'${\rm div} \: nu_{y}^{E\times B}, \rm  \;  s^{-1}m^{-3} \; (main \; ions)$','div_fvey01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_x,'${\rm div} \: nu_{x}^{E\times B}, \rm \; s^{-1}m^{-3}  \; (main \; ions)$','div_fvex01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fDgrn_y,'${\rm div} \: \left(-D\nabla_y n\right), \rm  \; s^{-1}m^{-3} \; (main \; ions)$','div_fDgrn_y01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fvp_x,'${\rm div} \: nb_xu_{||}, \rm  \; s^{-1}m^{-3}  \; (main \; ions)$','div_fvpx01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fDgrn_x,'${\rm div} \: \left(D\nabla_x n\right), \rm  \; s^{-1}m^{-3}  \; (main \; ions)$','div_fDgrn_x01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sna(:,:,is_main)./vol,'${\rm main \:ion \: source} , \rm  \; s^{-1}m^{-3}$','source01',Level_div_f,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,snadt(:,:,is_main)./vol,'$\frac{\partial n}{\partial t} \; {\rm for \: main \: ions} , \rm  \; s^{-1}m^{-3}$','dndt01',Level_div_f,label2D,Plot2DMargins);
% End of the block devoted to main ions


Level_Ex=[-2000,-1800,1600,-1400,-1200,-1000,-800,-600,-400,-200,0,200,400,600,800,1000];
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_x,'$E_x, \; \rm V/m$','Ex',Level_Ex,label2D,Plot2DMargins);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_x,'$E_x, \; \rm V/m$','Ex_sign',[-2000 -10 0 10 1000],label2D,Plot2DMargins);

Level_Ey=[-20.0,-16.0,12.0,-8.0,-6.0,-5.0,-4.0,-2.0,-1.4,-1.0,-0.8,-0.6,-0.4,-0.2,0.0,0.2,0.4,0.6,0.8,1.0,1.4,2.0,4.0,6.0,8.0,10.0];
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_y*1.0e-3,'$E_y, \; \rm kV/m$','Ey',Level_Ey,label2D,Plot2DMargins);

plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_x,'$E_x$','Ex_arrows',Plot2DMargins);

Level_jx=[-2.5e4,-2e4,-1e4,-9e3,-8e3,-7e3,-6e3,-5e3,-4e3,-3e3,-2e3,-1e3,0.0,1e3,2e3,3e3,4e3,5e3];
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jxc_dens,'$j_x, \; \rm A/m^{2}$','jx',Level_jx,label2D,Plot2DMargins);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$B_{pol}\:j_{||} / B, \; \rm A/m^{2}$','jprll',Level_jx,label2D,Plot2DMargins);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sigxc_luc_Ebx,'$b_x\:\sigma_{||}^{\rm luciani}E_{||}, \; \rm A/m^{2}$','sigxc_luc_Ebx',Level_jx,label2D,Plot2DMargins);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sigxc_Ebx,'$b_x\:\sigma_{||}^{\rm CL}E_{||}, \; \rm A/m^{2}$','sigxc_Ebx',Level_jx,label2D,Plot2DMargins);
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$b_x\:j_{||}, \; \rm A/m^{2}$','jprll_sign',[-2.5e4, 10.0 0 10.0 5.0e3],label2D,Plot2DMargins);

plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(jx_prllc_dens-sigxc_luc_Ebx)./(abs(jx_prllc_dens)+abs(jx_prllc_dens)),'$(j_{||}-\:\sigma_{||}E_{||})\; / \; (\left|j_{||}\right|+\left|\:\sigma_{||}E_{||}\right|)$','jprll-sigmE',[-0.2,-0.15,-0.12,-0.1,-0.08,-0.05,-0.03,-0.02,-0.01,0,0.01,0.02,0.03,0.05,0.08,0.1,0.12,0.15,0.2],label2D,Plot2DMargins);

Level_jy=[-8e3,-7e3,-6e3,-5e3,-4e3,-3e3,-2e3,-1.6e3,-1.2e3,-8e2,-4e2,-3e2,-2e2,-1e2,-50,-25,0.0,25,50,100,200,300,4e2,8e2,1e3,2e3,3e3,4e3,5e3];
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jyc_dens,'$j_y, \; \rm A/m^{2}$','jy',Level_jy,label2D,Plot2DMargins);

plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$j_{||}$','jprll_arrows',Plot2DMargins);

Level_div_j_dia=[-50000 -40000 -30000 -20000 -10000 -5000 -4000 -3000 -2000 -1000 0 1000 2000 3000 4000 5000 10000];
Level_div_j_tot=[-200 -160 -120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120 160 200];
Level_div_j_small=[-10000 -8000 -6000 -4000 -2000 -1000 -800 -600 -400 -200 0 200 400 600 800 1000 2000 4000 6000 8000 10000];
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_dia+div_j_inert,'${\rm div} j_{\nabla B},  A/m^3$','div_j_dia',Level_div_j_dia,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_prll,'${\rm div} j_{prll},  A/m^3$','div_j_prll',Level_div_j_dia,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j,'${\rm div} j_{tot},  A/m^3$','div_j_tot',Level_div_j_tot,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_dia+div_j_inert+div_j_prll,'${\rm div} \left(j_{dia}+j_{inert}+j_{prll}\right),  A/m^3$','div_j_dia_prll',Level_div_j_small,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_vispar+div_j_visper+div_j_visq,'${\rm div} \left(j_{vispar}+j_{visper}+j_{visq}\right),  A/m^3$','div_j_vis',Level_div_j_small,label2D,Plot2DMargins);
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_AN,'${\rm div} \left(j_{AN}\right),  A/m^3$','div_j_AN',Level_div_j_small,label2D,Plot2DMargins);

Level_Qe=[-40000000 -20000000 -10000000 -8000000 -6000000 -4000000 -2000000 -1000000 -800000 -600000 -400000 -200000 -100000 -80000 -60000 -40000 -20000 -10000 0];
if EIRENE_flag
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(she_stel+she_eir)./vol,'$\rm {Q_e}_{loss},\: atoms\:and\:ions \; \rm W/m^3$','Qe_tot',Level_Qe,label2D,Plot2DMargins);
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(she_eir)./vol,'$\rm {Q_e}_{loss},\: atoms, \; \rm W/m^3$','Qe_eir',Level_Qe,label2D,Plot2DMargins);
end;
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(she_stel)./vol,'$\rm {Q_e}_{loss},\: ions, \; \rm W/m^3$','Qe_stel',Level_Qe,label2D,Plot2DMargins);


Level_Qrad=[-10000000 -8000000 -6000000 -4000000 -2000000 -1000000 -800000 -600000 -400000 -200000 -100000 -80000 -60000 -40000 -20000 -10000 0];

if exist('is_C01','var')   
    if EIRENE_flag
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-(Qrad(:,:,is_C01)+Qrad(:,:,is_C02)+Qrad(:,:,is_C03)+Qrad(:,:,is_C04)+Qrad(:,:,is_C05))./vol,...
            '$\rm {Q_e}_{rad},\:all\:carbon\:ions \; \rm W/m^3$','QradCtot',Level_Qe,label2D,Plot2DMargins);
    else
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-(Qrad(:,:,is_C01-1)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01))./vol,...
            '$\rm {Q_e}_{rad},\:all\:carbon\:ions \; \rm W/m^3$','QradCtot',Level_Qe,label2D,Plot2DMargins);
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-Qrad(:,:,is_C01-1)./vol,['$\rm ',label{is_C01-1},'\: radiation\:losses, \; \rm W/m^3$'],'QradC0',Level_Qrad,label2D,Plot2DMargins);
    end;
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-Qrad(:,:,is_C01)./vol,['$\rm ',label{is_C01},'\: radiation\:losses, \; \rm W/m^3$'],'QradC1',Level_Qrad,label2D,Plot2DMargins);
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-Qrad(:,:,is_C02)./vol,['$\rm ',label{is_C02},'\: radiation\:losses, \; \rm W/m^3$'],'QradC2',Level_Qrad,label2D,Plot2DMargins);
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-Qrad(:,:,is_C03)./vol,['$\rm ',label{is_C03},'\: radiation\:losses, \; \rm W/m^3$'],'QradC3',Level_Qrad,label2D,Plot2DMargins);
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-Qrad(:,:,is_C04)./vol,['$\rm ',label{is_C04},'\: radiation\:losses, \; \rm W/m^3$'],'QradC4',Level_Qrad,label2D,Plot2DMargins);
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-Qrad(:,:,is_C05)./vol,['$\rm ',label{is_C05},'\: radiation\:losses, \; \rm W/m^3$'],'QradC5',Level_Qrad,label2D,Plot2DMargins);
end;
