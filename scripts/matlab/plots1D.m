%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCE !D PLOTS OF MANY DIFFERENT TYPES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================


% Plot electron and main ion density at outer midplane (see also comments
% inside R_polt_2.m)
iout=R_plot_2(y2,ne,na(:,:,is_main),nx,ny,nout,'Outer midplane density','$\rm n,\:\:  (m^{-3})$','n_e','n_{i main}');
% Then save the produced figure in EPS format
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_ni_midpl.eps']);

if strncmp(Plasma_Composition,'D_T',3) 
% If plasma contains Deuterium and Tritium, then plot electron density
% together with both species density
    iout=R_plot_3(y2,ne,na(:,:,is_D01),na(:,:,is_T01),nx,ny,nout,'Outer midplane density','$\rm n,\:\:  (m^{-3})$','n_e','n_{D+}','n_{T+}');
    set(gcf,'PaperPositionMode','auto');
    print('-depsc2','-r600',[PATH_PREFIX,'ne_nD_nT_midpl.eps']);
end

% Plot electron and ion temperatures at outer midplane, then save in EPS format
iout=R_plot_2(y2,te,ti,nx,ny,nout,'Outer midplane temperature','T,  (eV)','T_e','T_i');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Te_Ti_midpl.eps']);

% Plot Z effective at outer midplane, then save in EPS format
iout=R_plot(y2,Zeff,nx,ny,nout,'Outer midplane Zeff','$\rm Z_{eff}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Zeff_midpl.eps']);

% Plot electron density along targets, all targets on the same graph
iout=R_plot_targets(y2,ne,0,nx,ny,ntt,nc2,nc3,'$\rm n_e,  m^{-3}$','Electron density on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_targets.eps']);

% Plot electron temperature along targets, all targets on the same graph
iout=R_plot_targets(y2,te,0,nx,ny,ntt,nc2,nc3,'$\rm T_e,  eV$','Electron temperature on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Te_targets.eps']);

% Plot ion temperature along targets, all targets on the same graph
iout=R_plot_targets(y2,ti,0,nx,ny,ntt,nc2,nc3,'$\rm T_i,  eV$','Ion temperature on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Ti_targets.eps']);

% Plot ion saturation current along targets, all targets on the same graph
iout=R_plot_targets(y2,jsat,0,nx,ny,ntt,nc2,nc3,'$\rm j_{sat},  A/m^2$','Saturation current on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'jsat_targets.eps']);

% Plot current density along targets, all targets on the same graph
iout=R_plot_targets(y2,jx./hz./hy*qe,1,nx,ny,ntt,nc2,nc3,'$\rm j_{\perp},  A/m^2$','Current density on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'jperp_targets.eps']);

% Plot potential (in units of electron temperature) along targets, all targets on the same graph
iout=R_plot_targets(y2,po./te,0,nx,ny,ntt,nc2,nc3,'$\varphi/T_e$','Potential in units of electron temperature on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'phiTe_targets.eps']);

% Plot potential (in Volts) along targets, all targets on the same graph
iout=R_plot_targets(y2,po,0,nx,ny,ntt,nc2,nc3,'$\varphi,  \rm V$','Potential on targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'phi_targets.eps']);

% Plot heat flux density to targets, all targets on the same graph
iout=R_plot_targets(y2,fhtotX./hy./hz,0,nx,ny,ntt,nc2,nc3,'$\rm q_{tot},  W/m^2$','Heat flux density to the targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'qtot_targets.eps']);

% Plot ExB (radial) flux along targets, all targets on the same graph
iout=R_plot_targets(y1,fnay_nuExB(:,:,2),2,nx,ny,ntt,nc2,nc3,'$\frac{\sqrt{g}}{h_y}n_iu_y^{\rm ExB},  \rm s^{-1}$','Main ion radial ExB flux near targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gammay_ExB_targets.eps']);

% Plot diffusive (radial) flux along targets, all targets on the same graph
iout=R_plot_targets(y1,fnay_Dgradn(:,:,2),2,nx,ny,ntt,nc2,nc3,'$-\frac{\sqrt{g}}{h_y}D\nabla_y n_i,  \rm s^{-1}$','Main ion radial diffusive flux near targets');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gammay_Dnabla_n_targets.eps']);

% Plot total radial heat flux in the core (in different forms)
iout = R_plot_core2_1Darray(y2,Fhey_core,Fhiy_core,ny,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e NOMDF','Q_i NOMDF');
iout = R_plot_core2_1Darray(y2,Fhey_mdf_core,Fhiy_mdf_core,ny,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e MDF','Q_i MDF');
iout = R_plot_core2_1Darray(y2,Fhey_52uExB_core,Fhiy_52uExB_core,ny,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e 5/2','Q_i 5/2');
%iout = R_plot_core2_1Darray(y2,Fhi_mdfY_plusExB,Fhi_NEOY,ny,nsep,nout,'Ion heat fluxes through flux surface','Q_{tot},  W','Q_i 5/2','Q_iNEO');


% Plot radial distribution of all species density at outer midplane 
iout=R_plot_densities_multi_ns(y2,ne,na,ns,ny,nout,'Outer midplane densities',SYMBOL,COLOUR,label);

% Plot total radial fluxes of all species
iout=R_plot_core_multi_ns(y2,ne,Fnay_mdf_core,ns,nout,nsep,'Particle fluxes, s^{-1}',SYMBOL,COLOUR,label);

% Plot total radial flux components of species is

% is = 2, main ions
iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core,nout,nsep,2,[label{is_main},' total flux components']);

if exist('is_C04','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_C04,[label{is_C04},' total flux components']);
end;

if exist('is_C05','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_C05,[label{is_C05},' total flux components']);
end;

if exist('is_C06','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_C06,[label{is_C06},' total flux components']);
end;

if exist('is_N04','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N04,[label{is_N04},' total flux components']);
end;

if exist('is_N05','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N05,[label{is_N05},' total flux components']);
end;

if exist('is_N06','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N06,[label{is_N06},' total flux components']);
end;

if exist('is_N07','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N07,[label{is_N07},' total flux components']);
end;

if exist('is_He01','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_He01,[label{is_He01},' total flux components']);
end;

if exist('is_He02','var')
     iout=R_plot_radial_flux_is(y2,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_He02,[label{is_He02},' total flux components']);
end;

% Plot poloidal flux components of species 
if  exist('is_C06','var')
     iout=poloidal_plot_poloidal_flux_is(x2,fnax,fnax_mdf,fnax_Dgradn,fnax_nuAN,fnax_nuExB,fnax_PSch,fnax_nupar,fnax_uDPC,nc1,nc2,nc3,nc4,4,is_C06,[label{is_C06},' poloidal flux components']);
end;

% Plot poloidal flux components of species 
if  exist('is_N07','var')
     iout=poloidal_plot_poloidal_flux_is(x2,fnax,fnax_mdf,fnax_Dgradn,fnax_nuAN,fnax_nuExB,fnax_PSch,fnax_nupar,fnax_uDPC,nc1,nc2,nc3,nc4,4,is_N06,[label{is_N06},' poloidal flux components']);
end;

% Plot poloidal distributions of electron density in the core for different flux surfaces
iout=poloidal_plot_multline(x2,ne,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Electron density in the CORE','$n_e, \;\; \rm m^{-3}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_CORE_multline.eps']);

% Plot poloidal distributions of main ion (is=is_main) density in the core for different flux surfaces
iout=poloidal_plot_multline(x2,na(:,:,is_main),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Main ion density in the CORE','$n_{i main}, \;\; \rm m^{-3}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'nD_CORE_multline.eps']);

if  exist('is_C01','var')
      % Plot poloidal distributions of C01 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_C01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_C01},' ion density in the CORE'],['$n_{',label{is_C01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nC1_CORE_multline.eps']);
end;

if  exist('is_C02','var')
      % Plot poloidal distributions of C02 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_C02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_C02},' ion density in the CORE'],['$n_{',label{is_C02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nC2_CORE_multline.eps']);
end;

if  exist('is_C03','var')
      % Plot poloidal distributions of C03 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_C03),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_C03},' ion density in the CORE'],['$n_{',label{is_C03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nC3_CORE_multline.eps']);
end;


if  exist('is_C04','var')
      % Plot poloidal distributions of C04 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_C04),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_C04},' ion density in the CORE'],['$n_{',label{is_C04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nC4_CORE_multline.eps']);
end;

if  exist('is_C05','var')
      % Plot poloidal distributions of C05 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_C05),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_C05},' ion density in the CORE'],['$n_{',label{is_C05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nC5_CORE_multline.eps']);
end;

if  exist('is_C06','var')
      % Plot poloidal distributions of C06 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_C06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_C06},' ion density in the CORE'],['$n_{',label{is_C06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nC6_CORE_multline.eps']);
end;

if  exist('is_N01','var')
      % Plot poloidal distributions of C01 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N01},' ion density in the CORE'],['$n_{',label{is_N01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN1_CORE_multline.eps']);
end;

if  exist('is_N02','var')
      % Plot poloidal distributions of C02 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N02},' ion density in the CORE'],['$n_{',label{is_N02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN2_CORE_multline.eps']);
end;

if  exist('is_N03','var')
      % Plot poloidal distributions of C03 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N03),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N03},' ion density in the CORE'],['$n_{',label{is_N03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN3_CORE_multline.eps']);
end;


if  exist('is_N04','var')
      % Plot poloidal distributions of C04 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N04),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N04},' ion density in the CORE'],['$n_{',label{is_N04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN4_CORE_multline.eps']);
end;

if  exist('is_N05','var')
      % Plot poloidal distributions of C05 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N05),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N05},' ion density in the CORE'],['$n_{',label{is_N05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN5_CORE_multline.eps']);
end;

if  exist('is_N06','var')
      % Plot poloidal distributions of C06 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N06},' ion density in the CORE'],['$n_{',label{is_N06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN6_CORE_multline.eps']);
end;

if  exist('is_N07','var')
      % Plot poloidal distributions of C06 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N07),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N07},' ion density in the CORE'],['$n_{',label{is_N07},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN7_CORE_multline.eps']);
end;

if  exist('is_He01','var')
      % Plot poloidal distributions of He01 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_He01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_He01},' ion density in the CORE'],['$n_{',label{is_He01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nHe01_CORE_multline.eps']);
end;

if  exist('is_He02','var')
      % Plot poloidal distributions of He02 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_He02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_He02},' ion density in the CORE'],['$n_{',label{is_He02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nHe02_CORE_multline.eps']);
end;

% Plot poloidal distributions of electron in the core for different flux surfaces
iout=poloidal_plot_multline(x2,te,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Electron temperature in the CORE','$T_e, \;\; \rm eV$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Te_CORE_multline.eps']);


iout=poloidal_plot_multline(x2,ti,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Ion temperature in the CORE','$T_i, \;\; \rm eV$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Ti_CORE_multline.eps']);
iout=poloidal_plot_multline(x2,po,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Potential in the CORE','$\varphi, \;\; \rm V$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'po_CORE_multline.eps']);
iout=poloidal_plot_multline(x2,ua(:,:,2)/1000,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Main ion parallel velocity in the CORE','$u_{||}^{D^+}, \;\; \rm km/s$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'uaD_CORE_multline.eps']);
iout=poloidal_plot_multline(x2,pas,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Total pressure in the CORE','$p_{tot}, \;\; \rm Pa$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ptot_CORE_multline.eps']);

%iout=poloidal_plot_multline(x2,fnax_nupar(:,:,2)+fnax_nuExB(:,:,2)+fnax_dia(:,:,2),nx,ny,0,nc2,nc3+1,nx,nsep+1,ny-nsep,'Poloidal particle flux in the inner SOL','$\Gamma_i, \;\;  \rm s^{-1}$');

iout=poloidal_plot_multline(x1,fnax_nupar(:,:,is_main)+fnax_nuExB(:,:,is_main)+fnax_dia(:,:,is_main)+fnax_Dgradn(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Poloidal main ion particle flux in the SOL','$\Gamma_i, \;\;  \rm s^{-1}$');

iout=poloidal_plot_multline(x2,ux_ExB(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Main ion ExB velocity in the SOL','$u_{ExB}, \;\;  \rm m/s}$');
iout=poloidal_plot_multline(x2,ux_dia(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Main ion grad-B drift velocity  in the SOL','$u_{\nabla B}, \;\;  \rm m/s$');
iout=poloidal_plot_multline(x2,Bx./B.*ua(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Poloidal projection of main ion parallel velocity in the SOL','$b_xu_{||}, \;\;  \rm m/s$');

%iout=poloidal_plot_multline(x2,ne,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'Electrons density in the outer SOL right','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,2),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'Main ion density in the outer SOL right','$n_{D^{+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,3),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{0} ion density in the outer SOL right','$n_{C^{0}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,4),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{+} ion density in the outer SOL right','$n_{C^{+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,5),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{2+} ion density in the outer SOL right','$n_{C^{2+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,6),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{3+} ion density in the outer SOL right','$n_{C^{3+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,7),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{4+} ion density in the outer SOL right','$n_{C^{4+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,8),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{5+} ion density in the outer SOL right','$n_{C^{5+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,9),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{6+} ion density in the outer SOL right','$n_{C^{6+}}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,1),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'D^{0} density in the outer SOL right','$n^{D0}, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,te,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'Electrons temperature in the outer SOL right','$T_e, \;\; \rm eV$');
%iout=poloidal_plot_multline(x2,ti,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'Ions temperature in the outer SOL right','$T_i, \;\; \rm eV$');
%iout=poloidal_plot_multline(x2,po,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'Potential in the outer SOL right','$\varphi, \;\; \rm V$');

%iout=poloidal_plot_multline(x2,ne,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'Electrons density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,2),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'Main ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,3),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{0} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,4),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{+} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,5),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{2+} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,6),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{3+} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,7),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{4+} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,8),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{5+} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,9),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{6+} ion density in the outer SOL left','$n_e, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,na(:,:,1),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'D^{0} density in the outer SOL left','$n_a, \;\;  \rm m^{-3}$');
%iout=poloidal_plot_multline(x2,te,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'Electrons temperature in the outer SOL left','$T_e, \;\; \rm eV$');
%iout=poloidal_plot_multline(x2,ti,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'Ions temperature in the outer SOL left','$T_i, \;\; \rm eV$');
%iout=poloidal_plot_multline(x2,po,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'Potential in the outer SOL left','$\varphi, \;\; \rm V$');

%iout=poloidal_plot_multline(x2,ua(:,:,3),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{0} ion velocity in the outer SOL right','$u_{C^%{0}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,4),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{+} ion velocity in the outer SOL right','$u_{C^{+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,5),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{2+} ion velocity in the outer SOL right','$u_{C^{2+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,6),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{3+} ion velocity in the outer SOL right','$u_{C^{3+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,7),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{4+} ion velocity in the outer SOL right','$u_{C^{4+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,8),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{5+} ion velocity in the outer SOL right','$u_{C^{5+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,9),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{6+} ion velocity in the outer SOL right','$u_{C^{6+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,1),nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'D^{0} velocity in the outer SOL right','$u^{D0}, \;\;  \rm m/s$');

%iout=poloidal_plot_multline(x2,ua(:,:,3),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{0} ion velocity in the outer SOL left','$u_{C^{0}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,4),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{+} ion velocity in the outer SOL left','$u_{C^{+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,5),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{2+} ion velocity in the outer SOL left','$u_{C^{2+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,6),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{3+} ion velocity in the outer SOL left','$u_{C^{3+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,7),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{4+} ion velocity in the outer SOL left','$u_{C^{4+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,8),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{5+} ion velocity in the outer SOL left','$u_{C^{5+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,9),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{6+} ion velocity in the outer SOL left','$u_{C^{6+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,1),nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'D^{0} velocity in the outer SOL left','$u^{D0}, \;\;  \rm m/s$');


%iout=poloidal_plot_multline(x2,ua(:,:,3)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{0} Mach number in the outer SOL right','$u_{C^{0}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,4)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{+} Mach numbe in the outer SOL right','$u_{C^{+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,5)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{2+} Mach number in the outer SOL right','$u_{C^{2+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,6)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{3+} Mach number in the outer SOL right','$u_{C^{3+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,7)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{4+} Mach number in the outer SOL right','$u_{C^{4+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,8)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{5+} Mach number in the outer SOL right','$u_{C^{5+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,9)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'C^{6+} Mach number in the outer SOL right','$u_{C^{6+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,1)./cs,nx,ny,ntt+1,ntt+2,ntt+3,nx,nsep2+1,ny-nsep2,'D^{0} Mach number in the outer SOL right','$u^{D0}, \;\;  \rm m/s$');

%iout=poloidal_plot_multline(x2,ua(:,:,3)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{0} Mach number in the outer SOL left','$u_{C^{0}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,4)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{+} Mach number in the outer SOL left','$u_{C^{+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,5)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{2+} Mach number in the outer SOL left','$u_{C^{2+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,6)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{3+} Mach number in the outer SOL left','$u_{C^{3+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,7)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{4+} Mach number in the outer SOL left','$u_{C^{4+}}, \;\;  \rm m/s}$');
%iout=poloidal_plot_multline(x2,ua(:,:,8)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{5+} Mach number in the outer SOL left','$u_{C^{5+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,9)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'C^{6+} Mach number in the outer SOL left','$u_{C^{6+}}, \;\;  \rm m/s$');
%iout=poloidal_plot_multline(x2,ua(:,:,1)./cs,nx,ny,-1,ntt-2,ntt-1,ntt,nsep2+1,ny-nsep2,'D^{0} Mach number in the outer SOL left','$u^{D0}, \;\;  \rm m/s$');



%iout=R_plot_2targets_SND(y2,fhtotX./hy./hz,nx,ny,'$\rm q_{tot},  W/m^2$');
%iout=R_plot_targets(y1,fnay_nuExB(:,:,2),2,nx,ny,ntt,nc2,nc3,'$\frac{\sqrt{g}}{h_y}n_iu_y^{\rm ExB},  \rm s^{-1}$','Main ion radial ExB flux near targets');



iout = R_plot_core2_1Darray(y2,Ey,Ey_neo,ny,nsep,nout,'Radial electric field','E, V/m','E_{rad}','E_{rad}^{NEO}');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Ey_midpl.eps']);

%poloidal_DND_core_plot8(x2,smo(:,:,2),smogp(:,:,2),smoch(:,:,2),smotf(:,:,2),smocf(:,:,2),smovv(:,:,2),smovh(:,:,2),smoii(:,:,2),nc1,nc2,nc3,nc4,2,'momentum source components in the CORE, y = 2','$S_m \; kg\cdot m^2 / s^2$','\rm total','\nabla p + E','mn\nu(u_a-u_b)','n\nabla T$','\rm centrif','visc_1','visc_2','ion-ion');
poloidal_DND_core_plot12(x2,smo(:,:,2),div_fmo_x(:,:,2),div_fmo_y(:,:,2),smodt(:,:,2),smogp(:,:,2),smoch(:,:,2),smotf(:,:,2),smocf(:,:,2),smovv(:,:,2),smovh(:,:,2),smoii(:,:,2),smoat(:,:,2),nc1,nc2,nc3,nc4,2,'momentum balance components in the CORE, y = 2','$S_m \; kg\cdot m^2 / s^2$','\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','\nabla p + E','mn\nu(u_a-u_b)','n\nabla T$','\rm centrif','visc_1','visc_2','ion-ion','Eirene');

