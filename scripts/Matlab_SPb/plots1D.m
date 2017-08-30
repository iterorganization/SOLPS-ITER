%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCE 1D PLOTS OF MANY DIFFERENT TYPES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================


% Plot electron and main ion density at outer midplane (see also comments
% inside R_polt_2.m)
label01 = 'n_e';
label02 = 'n_{i main}';
%global N_ne_midpl;
if exp_data_flag && exist('N_ne_midpl','var')
    iout=R_plot_2(y2,-1,ne,na(:,:,is_main),ny,nout,'Outer midplane density','n, (m^{-3})',label01,label02,0);
    v = axis;
    legend_label=cell(2+N_ne_midpl,1);
    legend_label{1}=label01;
    legend_label{2}=label02;
    for i = 1:N_ne_midpl
        plot(exp_data_ne_midpl(:,2*i-1),exp_data_ne_midpl(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{i});
        legend_label{2+i}=legend_exp_ne_midpl{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else
    iout=R_plot_2(y2,-1,ne,na(:,:,is_main),ny,nout,'Outer midplane density','n,  (m^{-3})',label01,label02,1);

end;
% Then save the produced figure in EPS format
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_ni_midpl.eps']);
print('-dpng','-r600',[PATH_PREFIX,'ne_ni_midpl.png']);

if strncmp(Plasma_Composition,'D_T',3) 
% If plasma contains Deuterium and Tritium, then plot electron density
% together with both species density
    iout=R_plot_3(y2,-1,ne,na(:,:,is_D01),na(:,:,is_T01),ny,nout,'Outer midplane density','$\rm n,\:\:  (m^{-3})$','n_e','n_{D+}','n_{T+}');
    set(gcf,'PaperPositionMode','auto');
    print('-depsc2','-r600',[PATH_PREFIX,'ne_nD_nT_midpl.eps']);
%     print('-dpng','-r600',[PATH_PREFIX,'ne_nD_nT_midpl.png']);
end

% Plot electron and ion temperatures at outer midplane, then save in EPS format
label01 = 'T_e';
label02 = 'T_i';
%global N_Te_midpl;
%global N_Ti_midpl;
if exp_data_flag && exist('N_Te_midpl','var') && exist('N_Ti_midpl','var')
    iout=R_plot_2(y2,-1,te,ti,ny,nout,'Outer midplane temperature','T,  (eV)',label01,label02,0);
    v = axis;
    legend_label=cell(2+N_Te_midpl+N_Ti_midpl,1);
    legend_label{1}=label01;
    legend_label{2}=label02;
    for i = 1:N_Te_midpl
        plot(exp_data_Te_midpl(:,2*i-1),exp_data_Te_midpl(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{i});
        legend_label{2+i}=legend_exp_Te_midpl{i};
    end;
    for i = 1:N_Ti_midpl
        plot(exp_data_Ti_midpl(:,2*i-1),exp_data_Ti_midpl(:,2*i),'Marker',Marker_exp{N_Te_midpl+i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{2+i});
        legend_label{2+N_Te_midpl+i}=legend_exp_Ti_midpl{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else
    iout=R_plot_2(y2,-1,te,ti,ny,nout,'Outer midplane temperature','T,  (eV)','T_e','T_i',1);
end;
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Te_Ti_midpl.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Te_Ti_midpl.png']);

% Plot Z effective at outer midplane, then save in EPS format
iout=R_plot(y2,-1,Zeff,ny,nout,'Outer midplane Zeff','$\rm Z_{eff}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Zeff_midpl.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Zeff_midpl.png']);

% Plot electron density along targets, all targets on the same graph
%global N_ne_inner_bottom
if exp_data_flag && exist('N_ne_inner_bottom','var') && exist('N_ne_outer_bottom','var') && exist('N_ne_inner_top','var') && exist('N_ne_outer_top','var')
    iout=R_plot_targets(y2,ne,0,nx,ny,ntt,nc2,nc3,'$\rm n_e, \;  m^{-3}$','Electron density at targets',0);
    v = axis;
    if ntt==nc2 || ntt==nc3 % Single null topology - only two targets exist
        N_targets = 2
    else
        N_targets = 4
    end;
    legend_label=cell(N_targets+N_ne_inner_bottom+N_ne_outer_bottom+N_ne_inner_top+N_ne_outer_top,1);
    legend_label{1}='inner bottom target';
    legend_label{2}='outer bottom target';
    if N_targets == 4
        legend_label{3}='outer top target';
        legend_label{4}='inner top target';
    end;
    for i = 1:N_ne_inner_bottom
        plot(exp_data_ne_inner_bottom(:,2*i-1),exp_data_ne_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{1});
        legend_label{N_targets+i}=legend_exp_ne_inner_bottom{i};
    end;
    for i = 1:N_ne_outer_bottom
        plot(exp_data_ne_outer_bottom(:,2*i-1),exp_data_ne_outer_bottom(:,2*i),'Marker',Marker_exp{i+N_ne_inner_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{4});
        legend_label{N_targets+N_ne_inner_bottom+i}=legend_exp_ne_outer_bottom{i};
    end;
    for i = 1:N_ne_inner_top
        plot(exp_data_ne_inner_top(:,2*i-1),exp_data_ne_inner_top(:,2*i),'Marker',Marker_exp{i+N_ne_inner_bottom+N_ne_outer_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{6});
        legend_label{N_targets+N_ne_inner_bottom+N_ne_outer_bottom+i}=legend_exp_ne_inner_top{i};
    end;
    for i = 1:N_ne_outer_top
        plot(exp_data_ne_outer_top(:,2*i-1),exp_data_ne_outer_top(:,2*i),'Marker',Marker_exp{i+N_ne_inner_bottom+N_ne_outer_bottom+N_ne_inner_top},'MarkerSize',12,'LineStyle','none','Color',Color_exp{7});
        legend_label{N_targets+N_ne_inner_bottom+N_ne_outer_bottom+N_ne_inner_top+i}=legend_exp_ne_outer_top{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else  
    iout=R_plot_targets(y2,ne,0,nx,ny,ntt,nc2,nc3,'$\rm n_e, \; m^{-3}$','Electron density at targets',1);
end;
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'ne_targets.png']);

% Plot electron temperature along targets, all targets on the same graph
if exp_data_flag && exist('N_Te_inner_bottom','var') && exist('N_Te_outer_bottom','var') && exist('N_Te_inner_top','var') && exist('N_Te_outer_top','var')
    iout=R_plot_targets(y2,te,0,nx,ny,ntt,nc2,nc3,'$\rm T_e, \; eV$','Electron temperature at targets',0);
    v = axis;
    if ntt==nc2 || ntt==nc3 % Single null topology - only two targets exist
        N_targets = 2
    else
        N_targets = 4
    end;
    legend_label=cell(N_targets+N_Te_inner_bottom+N_Te_outer_bottom+N_Te_inner_top+N_Te_outer_top,1);
    legend_label{1}='inner bottom target';
    legend_label{2}='outer bottom target';
    if N_targets == 4
        legend_label{3}='outer top target';
        legend_label{4}='inner top target';
    end;
    for i = 1:N_Te_inner_bottom
        plot(exp_data_Te_inner_bottom(:,2*i-1),exp_data_Te_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{1});
        legend_label{N_targets+i}=legend_exp_Te_inner_bottom{i};
    end;
    for i = 1:N_Te_outer_bottom
        plot(exp_data_Te_outer_bottom(:,2*i-1),exp_data_Te_outer_bottom(:,2*i),'Marker',Marker_exp{i+N_Te_inner_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{4});
        legend_label{N_targets+N_Te_inner_bottom+i}=legend_exp_Te_outer_bottom{i};
    end;
    for i = 1:N_Te_inner_top
        plot(exp_data_Te_inner_top(:,2*i-1),exp_data_Te_inner_top(:,2*i),'Marker',Marker_exp{i+N_Te_inner_bottom+N_Te_outer_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{6});
        legend_label{N_targets+N_Te_inner_bottom+N_Te_outer_bottom+i}=legend_exp_Te_inner_top{i};
    end;
    for i = 1:N_Te_outer_top
        plot(exp_data_Te_outer_top(:,2*i-1),exp_data_Te_outer_top(:,2*i),'Marker',Marker_exp{i+N_Te_inner_bottom+N_Te_outer_bottom+N_Te_inner_top},'MarkerSize',12,'LineStyle','none','Color',Color_exp{7});
        legend_label{N_targets+N_Te_inner_bottom+N_Te_outer_bottom+N_Te_inner_top+i}=legend_exp_Te_outer_top{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else  
    iout=R_plot_targets(y2,te,0,nx,ny,ntt,nc2,nc3,'$\rm T_e, \; eV$','Electron temperature at targets',1);
end;
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Te_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Te_targets.png']);
%print('-djpeg','-r600',[PATH_PREFIX,'Te_targets.jpg']);

% Plot ion temperature along targets, all targets on the same graph
iout=R_plot_targets(y2,ti,0,nx,ny,ntt,nc2,nc3,'$\rm T_i,  eV$','Ion temperature at targets',1);
%print('-depsc2','-r600',[PATH_PREFIX,'Te_targets.eps']);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Ti_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Ti_targets.png']);

% Plot ion saturation current along targets, all targets on the same graph
if exp_data_flag && exist('N_jsat_inner_bottom','var') && exist('N_jsat_outer_bottom','var') && exist('N_jsat_inner_top','var') && exist('N_jsat_outer_top','var')
    iout=R_plot_targets(y2,jsat,0,nx,ny,ntt,nc2,nc3,'$\rm j_{sat},  A/m^2$','Saturation current at targets',0);
    v = axis;
    if ntt==nc2 || ntt==nc3 % Single null topology - only two targets exist
        N_targets = 2
    else
        N_targets = 4
    end;
    legend_label=cell(N_targets+N_jsat_inner_bottom+N_jsat_outer_bottom+N_jsat_inner_top+N_jsat_outer_top,1);
    legend_label{1}='inner bottom target';
    legend_label{2}='outer bottom target';
    if N_targets == 4
        legend_label{3}='outer top target';
        legend_label{4}='inner top target';
    end;
    for i = 1:N_jsat_inner_bottom
        plot(exp_data_jsat_inner_bottom(:,2*i-1),exp_data_jsat_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{1});
        legend_label{N_targets+i}=legend_exp_jsat_inner_bottom{i};
    end;
    for i = 1:N_jsat_outer_bottom
        plot(exp_data_jsat_outer_bottom(:,2*i-1),exp_data_jsat_outer_bottom(:,2*i),'Marker',Marker_exp{i+N_jsat_inner_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{4});
        legend_label{N_targets+N_jsat_inner_bottom+i}=legend_exp_jsat_inner_bottom{i};
    end;
    for i = 1:N_jsat_inner_top
        plot(exp_data_jsat_inner_top(:,2*i-1),exp_data_jsat_inner_top(:,2*i),'Marker',Marker_exp{i+N_jsat_inner_bottom+N_jsat_outer_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{6});
        legend_label{N_targets+N_jsat_inner_bottom+N_jsat_outer_bottom+i}=legend_exp_jsat_inner_bottom{i};
    end;
    for i = 1:N_jsat_outer_top
        plot(exp_data_jsat_outer_top(:,2*i-1),exp_data_jsat_outer_top(:,2*i),'Marker',Marker_exp{i+N_jsat_inner_bottom+N_jsat_outer_bottom+N_jsat_inner_top},'MarkerSize',12,'LineStyle','none','Color',Color_exp{7});
        legend_label{N_targets+N_jsat_inner_bottom+N_jsat_outer_bottom+N_jsat_inner_top+i}=legend_exp_jsat_inner_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else
    iout=R_plot_targets(y2,jsat,0,nx,ny,ntt,nc2,nc3,'$\rm j_{sat},  A/m^2$','Saturation current at targets',0);
end;    
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'jsat_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'jsat_targets.png']);

% Plot current density along targets, all targets on the same graph
if exp_data_flag && exist('N_jx_inner_bottom','var') && exist('N_jx_outer_bottom','var') && exist('N_jx_inner_top','var') && exist('N_jx_outer_top','var')
    iout=R_plot_targets(y2,jx./hz./hy*qe,1,nx,ny,ntt,nc2,nc3,'$\rm j_{\perp},  A/m^2$','Current density at targets',0);
    v = axis;
    if ntt==nc2 || ntt==nc3 % Single null topology - only two targets exist
        N_targets = 2
    else
        N_targets = 4
    end;
    legend_label=cell(N_targets+N_jx_inner_bottom+N_jx_outer_bottom+N_jx_inner_top+N_jx_outer_top,1);
    legend_label{1}='inner bottom target';
    legend_label{2}='outer bottom target';
    if N_targets == 4
        legend_label{3}='outer top target';
        legend_label{4}='inner top target';
    end;
    for i = 1:N_jx_inner_bottom
        plot(exp_data_jx_inner_bottom(:,2*i-1),exp_data_jx_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{1});
        legend_label{N_targets+i}=legend_exp_jx_inner_bottom{i};
    end;
    for i = 1:N_jx_outer_bottom
        plot(exp_data_jx_outer_bottom(:,2*i-1),exp_data_jx_outer_bottom(:,2*i),'Marker',Marker_exp{i+N_jx_inner_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{4});
        legend_label{N_targets+N_jx_inner_bottom+i}=legend_exp_jx_inner_bottom{i};
    end;
    for i = 1:N_jx_inner_top
        plot(exp_data_jx_inner_top(:,2*i-1),exp_data_jx_inner_top(:,2*i),'Marker',Marker_exp{i+N_jx_inner_bottom+N_jx_outer_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{6});
        legend_label{N_targets+N_jx_inner_bottom+N_jx_outer_bottom+i}=legend_exp_jx_inner_bottom{i};
    end;
    for i = 1:N_jx_outer_top
        plot(exp_data_jx_outer_top(:,2*i-1),exp_data_jx_outer_top(:,2*i),'Marker',Marker_exp{i+N_jx_inner_bottom+N_jx_outer_bottom+N_jx_inner_top},'MarkerSize',12,'LineStyle','none','Color',Color_exp{7});
        legend_label{N_targets+N_jx_inner_bottom+N_jx_outer_bottom+N_jx_inner_top+i}=legend_exp_jx_inner_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else
    iout=R_plot_targets(y2,jx./hz./hy*qe,1,nx,ny,ntt,nc2,nc3,'$\rm j_{\perp},  A/m^2$','Current density at targets',1);
end;
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'jperp_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'jperp_targets.png']);

% Plot particle flux density along targets, all targets on the same graph
iout=R_plot_targets(y2,(fnax_Dgradn(:,:,2)+fnax_nuExB(:,:,2)+fnax_nupar(:,:,2))./hz./hy,1,nx,ny,ntt,nc2,nc3,'$\rm \Gamma_\perp,  m^{-2}s^{-1}$','Main ion particle flux density at targets',1);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gamma_x_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Gamma_x_targets.png']);

if exist('is_N01','var')
    iout=R_plot_targets(y2,fnax_mdf_N_ch./hz./hy,1,nx,ny,ntt,nc2,nc3,'$\rm \Gamma_\perp,  m^{-2}s^{-1}$','Nitrogen ion flux density at targets',1);
    set(gcf,'PaperPositionMode','auto');
    print('-depsc2','-r600',[PATH_PREFIX,'Gamma_x_targets_nitrogen.eps']);
    %print('-dpng','-r600',[PATH_PREFIX,'Gamma_x_targets_nitrogen.png']);
end;

% Plot potential (in units of electron temperature) along targets, all targets on the same graph
iout=R_plot_targets(y2,po./te,0,nx,ny,ntt,nc2,nc3,'$\varphi/T_e$','Potential in units of electron temperature at targets',1);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'phiTe_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'phiTe_targets.png']);

% Plot potential (in Volts) along targets, all targets on the same graph
if exp_data_flag && exist('N_po_inner_bottom','var') && exist('N_po_outer_bottom','var') && exist('N_po_inner_top','var') && exist('N_po_outer_top','var')
    iout=R_plot_targets(y2,po,0,nx,ny,ntt,nc2,nc3,'$\varphi,  \rm V$','Potential at targets',0);
    v = axis;
    if ntt==nc2 || ntt==nc3 % Single null topology - only two targets exist
        N_targets = 2
    else
        N_targets = 4
    end;
    legend_label=cell(N_targets+N_po_inner_bottom+N_po_outer_bottom+N_po_inner_top+N_po_outer_top,1);
    legend_label{1}='inner bottom target';
    legend_label{2}='outer bottom target';
    if N_targets == 4
        legend_label{3}='outer top target';
        legend_label{4}='inner top target';
    end;
    for i = 1:N_po_inner_bottom
        plot(exp_data_po_inner_bottom(:,2*i-1),exp_data_po_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{1});
        legend_label{N_targets+i}=legend_exp_po_inner_bottom{i};
    end;
    for i = 1:N_po_outer_bottom
        plot(exp_data_po_outer_bottom(:,2*i-1),exp_data_po_outer_bottom(:,2*i),'Marker',Marker_exp{i+N_po_inner_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{4});
        legend_label{N_targets+N_po_inner_bottom+i}=legend_exp_po_inner_bottom{i};
    end;
    for i = 1:N_po_inner_top
        plot(exp_data_po_inner_top(:,2*i-1),exp_data_po_inner_top(:,2*i),'Marker',Marker_exp{i+N_po_inner_bottom+N_po_outer_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{6});
        legend_label{N_targets+N_po_inner_bottom+N_po_outer_bottom+i}=legend_exp_po_inner_bottom{i};
    end;
    for i = 1:N_po_outer_top
        plot(exp_data_po_outer_top(:,2*i-1),exp_data_po_outer_top(:,2*i),'Marker',Marker_exp{i+N_po_inner_bottom+N_po_outer_bottom+N_po_inner_top},'MarkerSize',12,'LineStyle','none','Color',Color_exp{7});
        legend_label{N_targets+N_po_inner_bottom+N_po_outer_bottom+N_po_inner_top+i}=legend_exp_po_inner_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else
    iout=R_plot_targets(y2,po,0,nx,ny,ntt,nc2,nc3,'$\varphi,  \rm V$','Potential at targets',1);
end;    
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'phi_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'phi_targets.png']);

% Plot heat flux density to targets, all targets on the same graph
if exp_data_flag && exist('N_fhtotX_inner_bottom','var') && exist('N_fhtotX_outer_bottom','var') && exist('N_fhtotX_inner_top','var') && exist('N_fhtotX_outer_top','var')
    iout=R_plot_targets(y2,fhtotX./hy./hz,0,nx,ny,ntt,nc2,nc3,'$\rm q_{tot},  W/m^2$','Heat flux density to the targets',0);
    v = axis;
    if ntt==nc2 || ntt==nc3 % Single null topology - only two targets exist
        N_targets = 2
    else
        N_targets = 4
    end;
    legend_label=cell(N_targets+N_fhtotX_inner_bottom+N_fhtotX_outer_bottom+N_fhtotX_inner_top+N_fhtotX_outer_top,1);
    legend_label{1}='inner bottom target';
    legend_label{2}='outer bottom target';
    if N_targets == 4
        legend_label{3}='outer top target';
        legend_label{4}='inner top target';
    end;
    for i = 1:N_fhtotX_inner_bottom
        plot(exp_data_fhtotX_inner_bottom(:,2*i-1),exp_data_fhtotX_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',Color_exp{1});
        legend_label{N_targets+i}=legend_exp_fhtotX_inner_bottom{i};
    end;
    for i = 1:N_fhtotX_outer_bottom
        plot(exp_data_fhtotX_outer_bottom(:,2*i-1),exp_data_fhtotX_outer_bottom(:,2*i),'Marker',Marker_exp{i+N_fhtotX_inner_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{4});
        legend_label{N_targets+N_fhtotX_inner_bottom+i}=legend_exp_fhtotX_inner_bottom{i};
    end;
    for i = 1:N_fhtotX_inner_top
        plot(exp_data_fhtotX_inner_top(:,2*i-1),exp_data_fhtotX_inner_top(:,2*i),'Marker',Marker_exp{i+N_fhtotX_inner_bottom+N_fhtotX_outer_bottom},'MarkerSize',12,'LineStyle','none','Color',Color_exp{6});
        legend_label{N_targets+N_fhtotX_inner_bottom+N_fhtotX_outer_bottom+i}=legend_exp_fhtotX_inner_bottom{i};
    end;
    for i = 1:N_fhtotX_outer_top
        plot(exp_data_fhtotX_outer_top(:,2*i-1),exp_data_fhtotX_outer_top(:,2*i),'Marker',Marker_exp{i+N_fhtotX_inner_bottom+N_fhtotX_outer_bottom+N_fhtotX_inner_top},'MarkerSize',12,'LineStyle','none','Color',Color_exp{7});
        legend_label{N_targets+N_fhtotX_inner_bottom+N_fhtotX_outer_bottom+N_fhtotX_inner_top+i}=legend_exp_fhtotX_inner_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(legend_label);
else
    iout=R_plot_targets(y2,fhtotX./hy./hz,0,nx,ny,ntt,nc2,nc3,'$\rm q_{tot},  W/m^2$','Heat flux density to the targets',1);
end;
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'qtot_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'qtot_targets.png']);



% Plot ExB (radial) flux along targets, all targets on the same graph
iout=R_plot_targets(y1,fnay_nuExB(:,:,2),2,nx,ny,ntt,nc2,nc3,'$\frac{\sqrt{g}}{h_y}n_iu_y^{\rm ExB},  \rm s^{-1}$','Main ion radial ExB flux near targets',1);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gammay_ExB_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Gammay_ExB_targets.png']);

% Plot diffusive (radial) flux along targets, all targets on the same graph
iout=R_plot_targets(y1,fnay_Dgradn(:,:,2),2,nx,ny,ntt,nc2,nc3,'$-\frac{\sqrt{g}}{h_y}D\nabla_y n_i,  \rm s^{-1}$','Main ion radial diffusive flux near targets',1);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gammay_Dnabla_n_targets.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Gammay_Dnabla_n_targets.png']);

% Plot total radial heat flux in the core (in different forms)
iout = R_plot_core2_1Darray(y1_shift,1,Fhey_core,Fhiy_core,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e NOMDF','Q_i NOMDF');
iout = R_plot_core2_1Darray(y1_shift,1,Fhey_mdf_core,Fhiy_mdf_core,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e MDF','Q_i MDF');
iout = R_plot_core2_1Darray(y1_shift,1,Fhey_52uExB_core,Fhiy_52uExB_core,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e 5/2','Q_i 5/2');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Q_52_midpl.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Q_52_midpl.png']);
%iout = R_plot_core2_1Darray(y2,Fhi_mdfY_plusExB,Fhi_NEOY,ny,nsep,nout,'Ion heat fluxes through flux surface','Q_{tot},  W','Q_i 5/2','Q_iNEO');

iout = R_plot_core5_1Darray(y1_shift,1,Fhey_mdf_core,Fhey_52uExB_core,Fhey_ke_gTy_core,Fhey_32GammaT_core,Fhey_PSchy_core,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_e MDF','Q_e 5/2','Q_e -\chi_e n\nabla T_e','Q_e 3/2 \Gamma_e T_e','Q_e PSch');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Qe_components_midpl.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Qe_components_midpl.png']);
iout = R_plot_core5_1Darray(y1_shift,1,Fhiy_mdf_core,Fhiy_52uExB_core,Fhiy_ki_gTy_core,Fhiy_32GammaT_core,Fhiy_PSchy_core,nsep,nout,'Heat fluxes through flux surface','Q_{tot},  W','Q_i MDF','Q_i 5/2','Q_i -\chi_i n\nabla T_i','Q_i 3/2 \Gamma_i T_i','Q_i PSch');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Qi_components_midpl.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Qi_components_midpl.png']);

iout = R_plot_core8_1Darray(y1_shift,1,Jy,Jy_in,Jy_inert,Jy_visper,Jy_vispar,Jy_visq,Jy_AN,Jy_dia,nsep,nout,'Current through flux surface','J_y,  s^{-1}','J_{tot}','J_{Ion-Neut}','J_{inert}','J_{visper}','J_{vispar}','J_{visq}','J_{AN}','J_{dia}');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Jy_integr.eps']);


% Plot radial distribution of all species density at outer midplane 
iout=R_plot_densities_multi_ns(y2,ne,na,ns,ny,nout,'Outer midplane densities',SYMBOL,COLOUR,label);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'na_all_logplot_midpl.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'na_all_logplot_midpl.png']);

% Plot total radial fluxes of all species
iout=R_plot_core_multi_ns(y1_shift,1,Fnay_mdf_core,ns,nout,nsep,'Particle fluxes, s^{-1}','$\Gamma, \; s^{-1}$',SYMBOL,COLOUR,label);
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Radial_fluxes.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'Radial_fluxes.png']);

% Plot total radial flux components of species is

% is = 2, main ions
iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core,nout,nsep,is_main,[label{is_main},' total flux components']);

% This part is specific for certain case
 if EIRENE_flag == 1  %&& Mesh == 'upgrade_96x36'
     iout = R_plot_core4_1Darray(y1_shift,0,Snay_core(:,is_main),Snay_core_eir(:,is_main),Snay_core_sral(:,is_main),dFnay_mdf_core_dy(:,is_main),nsep,nout,...
         'Main ion source (poloidally integrated)','S,  s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
 end;
 
% 
%     npl=70;
%     iout = R_plot_4(y2,2,sna(:,:,is_main)./vol,sna_eir(:,:,is_main)./vol,sna_sral(:,:,is_main)./vol,div_f,ny,npl,['Main ion source in CORE and SOL, above X-point, LFS, ix=' num2str(npl+2,'%0.3i')],'S,  m^{-3}s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
% 
%     npl=75;
%     iout = R_plot_4(y2,2,sna(:,:,is_main)./vol,sna_eir(:,:,is_main)./vol,sna_sral(:,:,is_main)./vol,div_f,ny,npl,['Main ion source in CORE and PFR, below X-point, LFS, ix=' num2str(npl+2,'%0.3i')],'S,  m^{-3}s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
% 
%     npl=20;
%     iout = R_plot_4(y2,2,sna(:,:,is_main)./vol,sna_eir(:,:,is_main)./vol,sna_sral(:,:,is_main)./vol,div_f,ny,npl,['Main ion source in CORE and PFR, below X-point, HFS, ix=' num2str(npl+2,'%0.3i')],'S,  m^{-3}s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
% 
%     npl=27;
%     iout = R_plot_4(y2,2,sna(:,:,is_main)./vol,sna_eir(:,:,is_main)./vol,sna_sral(:,:,is_main)./vol,div_f,ny,npl,['Main ion source in CORE and SOL, above X-point, HFS, ix=' num2str(npl+2,'%0.3i')],'S,  m^{-3}s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
% 
%     npl=nin;
%     iout = R_plot_4(y2,2,sna(:,:,is_main)./vol,sna_eir(:,:,is_main)./vol,sna_sral(:,:,is_main)./vol,div_f,ny,npl,['Main ion source in CORE and SOL, inner midplane, ix=' num2str(npl+2,'%0.3i')],'S,  m^{-3}s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
% 
%     npl=nout;
%     iout = R_plot_4(y2,2,sna(:,:,is_main)./vol,sna_eir(:,:,is_main)./vol,sna_sral(:,:,is_main)./vol,div_f,ny,npl,['Main ion source in CORE and SOL, outer midplane, ix=' num2str(npl+2,'%0.3i')],'S,  m^{-3}s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
% end;

if exist('is_C04','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_C04,[label{is_C04},' total flux components']);
     iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_C04),Snay_core_sral(:,is_C04),dFnay_mdf_core_dy(:,is_C04),nsep,nout,...
         'C{\rm +4} ion source (poloidally integrated)','S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');     
end;

if exist('is_C05','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_C05,[label{is_C05},' total flux components']);
end;


if exist('is_C06','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_C06,[label{is_C06},' total flux components']);
end;

if exist('is_N01','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N01,[label{is_N01},' total flux components']);
%      if EIRENE_flag
%           iout = R_plot_core4_1Darray(y1_shift,0,Snay_core(:,is_N01),Snay_core_eir(:,is_N01),Snay_core_sral(:,is_N01),dFnay_mdf_core_dy(:,is_N01),nsep,nout,...
%          'N^{+1} source (poloidally integrated)','S,  s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
%      end;
end;

if exist('is_N02','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N02,[label{is_N02},' total flux components']);
%      if EIRENE_flag
%           iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_N02),Snay_core_sral(:,is_N02),dFnay_mdf_core_dy(:,is_N02),nsep,nout,...
%          [label{is_N02},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');
%      end;
end;

if exist('is_N03','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N03,[label{is_N03},' total flux components']);
%      if EIRENE_flag
%          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_N03),Snay_core_sral(:,is_N03),dFnay_mdf_core_dy(:,is_N03),nsep,nout,...
%          [label{is_N03},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
%      end;
end;

if exist('is_N04','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N04,[label{is_N04},' total flux components']);
%      if EIRENE_flag
%           iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_N04),Snay_core_sral(:,is_N04),dFnay_mdf_core_dy(:,is_N04),nsep,nout,...
%          [label{is_N04},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
%      end;
end;

if exist('is_N05','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N05,[label{is_N05},' total flux components']);
%      if EIRENE_flag
%          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_N05),Snay_core_sral(:,is_N05),dFnay_mdf_core_dy(:,is_N05),nsep,nout,...
%          [label{is_N05},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
%      end;
end;

if exist('is_N06','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N06,[label{is_N06},' total flux components']);
%      if EIRENE_flag
%          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_N06),Snay_core_sral(:,is_N06),dFnay_mdf_core_dy(:,is_N06),nsep,nout,...
%          [label{is_N06},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');  
%      end;
end;

if exist('is_N07','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_N07,[label{is_N07},' total flux components']);
%      if EIRENE_flag
%          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_N07),Snay_core_sral(:,is_N07),dFnay_mdf_core_dy(:,is_N07),nsep,nout,...
%          [label{is_N07},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');   
%      end;
     iout = R_plot_core_1Darray(y1_shift,1,Fnay_mdf_N_ch,nsep,nout,'Net nitrogen flux through flux surface','\Gamma_{tot}^{\rm N},  s^{-1}');
     set(gcf,'PaperPositionMode','auto');
     print('-depsc2','-r600',[PATH_PREFIX,'GammmaN_CORE.eps']);
end;

if exist('is_Ne01','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne01,[label{is_Ne01},' total flux components']);
     if EIRENE_flag
          iout = R_plot_core4_1Darray(y1_shift,0,Snay_core(:,is_Ne01),Snay_core_eir(:,is_Ne01),Snay_core_sral(:,is_Ne01),dFnay_mdf_core_dy(:,is_Ne01),nsep,nout,...
         'Ne^{+1} source (poloidally integrated)','S,  s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
     end;
end;

if exist('is_Ne02','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne02,[label{is_Ne02},' total flux components']);
     if EIRENE_flag
          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne02),Snay_core_sral(:,is_Ne02),dFnay_mdf_core_dy(:,is_Ne02),nsep,nout,...
         [label{is_Ne02},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');
     end;
end;

if exist('is_Ne03','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne03,[label{is_Ne03},' total flux components']);
     if EIRENE_flag
         iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne03),Snay_core_sral(:,is_Ne03),dFnay_mdf_core_dy(:,is_Ne03),nsep,nout,...
         [label{is_Ne03},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
     end;
end;

if exist('is_Ne04','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne04,[label{is_Ne04},' total flux components']);
     if EIRENE_flag
          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne04),Snay_core_sral(:,is_Ne04),dFnay_mdf_core_dy(:,is_Ne04),nsep,nout,...
         [label{is_Ne04},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
     end;
end;

if exist('is_Ne05','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne05,[label{is_Ne05},' total flux components']);
     if EIRENE_flag
         iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne05),Snay_core_sral(:,is_Ne05),dFnay_mdf_core_dy(:,is_Ne05),nsep,nout,...
         [label{is_Ne05},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
     end;
end;

if exist('is_Ne06','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne06,[label{is_Ne06},' total flux components']);
     if EIRENE_flag
         iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne06),Snay_core_sral(:,is_Ne06),dFnay_mdf_core_dy(:,is_Ne06),nsep,nout,...
         [label{is_Ne06},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');  
     end;
end;

if exist('is_Ne07','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne07,[label{is_Ne07},' total flux components']);
     if EIRENE_flag
          iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne07),Snay_core_sral(:,is_Ne07),dFnay_mdf_core_dy(:,is_Ne07),nsep,nout,...
         [label{is_Ne07},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
     end;
end;

if exist('is_Ne08','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne08,[label{is_Ne08},' total flux components']);
     if EIRENE_flag
         iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne08),Snay_core_sral(:,is_Ne08),dFnay_mdf_core_dy(:,is_Ne08),nsep,nout,...
         [label{is_Ne08},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma'); 
     end;
end;

if exist('is_Ne09','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne09,[label{is_Ne09},' total flux components']);
     if EIRENE_flag
         iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne09),Snay_core_sral(:,is_Ne09),dFnay_mdf_core_dy(:,is_Ne09),nsep,nout,...
         [label{is_Ne09},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');  
     end;
end;

if exist('is_Ne10','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_Ne10,[label{is_Ne10},' total flux components']);
     if EIRENE_flag
         iout = R_plot_core3_1Darray(y1_shift,0,Snay_core(:,is_Ne10),Snay_core_sral(:,is_Ne10),dFnay_mdf_core_dy(:,is_Ne10),nsep,nout,...
         [label{is_Ne10},' ion source (poloidally integrated)'],'S,  s^{-1}','S_{npc9}','S_{sral}','{\rm div} \Gamma');   
     end;
     iout = R_plot_core_1Darray(y1_shift,1,Fnay_mdf_Ne_ch,nsep,nout,'Net neon flux through flux surface','\Gamma_{tot}^{\rm Ne},  s^{-1}');
end;


if exist('is_He01','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_He01,[label{is_He01},' total flux components']);
     if EIRENE_flag
          iout = R_plot_core4_1Darray(y1_shift,0,Snay_core(:,is_He01),Snay_core_eir(:,is_He01),Snay_core_sral(:,is_He01),dFnay_mdf_core_dy(:,is_He01),nsep,nout,...
         'He^{+1} source (poloidally integrated)','S,  s^{-1}','S_{npc9}','S_{EIR}','S_{sral}','{\rm div} \Gamma');
     end;
end;

if exist('is_He02','var')
     iout=R_plot_radial_flux_is(y1_shift,Fnay_core,Fnay_mdf_core,Fnay_Dgradn_core,Fnay_nuAN_core,Fnay_nuExB_core,Fnay_PSch_core,Fnay_jAN_core,Fnay_jvispar_core,Fnay_jvisper_core,Fnay_jvisq_core,Fnay_jinert_core, ...
         nout,nsep,is_He02,[label{is_He02},' total flux components']);
     iout = R_plot_core_1Darray(y1_shift,1,Fnay_mdf_He_ch,nsep,nout,'Net helium flux through flux surface','\Gamma_{tot}^{\rm He},  s^{-1}');
end;


% Plot poloidal flux components of species 
if  exist('is_C06','var')
     iout=poloidal_plot_poloidal_flux_is(x2,fnax,fnax_mdf,fnax_Dgradn,fnax_nuAN,fnax_nuExB,fnax_PSch,fnax_nupar,fnax_uDPC,nc1,nc2,nc3,nc4,4,is_C06,[label{is_C06},' poloidal flux components']);
end;

% Plot poloidal flux components of species 
if  exist('is_N07','var')
     iout=poloidal_plot_poloidal_flux_is(x2,fnax,fnax_mdf,fnax_Dgradn,fnax_nuAN,fnax_nuExB,fnax_PSch,fnax_nupar,fnax_uDPC,nc1,nc2,nc3,nc4,4,is_N06,[label{is_N07},' poloidal flux components']);
end;

% Plot poloidal distributions of electron density in the core for different flux surfaces
iout=poloidal_plot_multline(x2,ne,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Electron density in the CORE','$n_e, \;\; \rm m^{-3}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_CORE_multline.eps']);

% Plot poloidal distributions of main ion (is=is_main) density in the core for different flux surfaces
iout=poloidal_plot_multline(x2,na(:,:,is_main),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Main ion density in the CORE','$n_{i main}, \;\; \rm m^{-3}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'nD_CORE_multline.eps']);

iout=poloidal_plot_4_1D_profiles(x1,Fnax_tot_D01_intx_CORE_PFR,Fnax_nuExB_D01_intx_CORE_PFR,Fnax_nupar_D01_intx_CORE_PFR,Fnax_Dgradn_D01_intx_CORE_PFR,0,nc1-1,nc4+2,nx,nsep,'Total D01 fluxes in PFR','$\Gamma, s^{-1}$','total','ExB','nu_{||}','-D\nabla n');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'GammaDtot_PFR.eps']);
iout=poloidal_plot_4_1D_profiles(x2,Fnax_tot_D01_intx_SOL,Fnax_nuExB_D01_intx_SOL,Fnax_nupar_D01_intx_SOL,Fnax_Dgradn_D01_intx_SOL,0,nc2,nc3,nx,nsep+2,'Total D01 fluxes in SOL','$\Gamma, s^{-1}$','total','ExB','nu_{||}','-D\nabla n');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'GammaDtot_SOL.eps']);

iout=poloidal_plot_multline(x1,fnax_mdf(:,:,is_D01)+fnax_dia(:,:,is_D01)+fnax_PSch(:,:,is_D01),nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Main ion poloidal flux in the SOL','$\left<\Gamma_{x}\right>, \;\; \rm s^{-1}$');


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
      % Plot poloidal distributions of N01 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N01},' ion density in the CORE'],['$n_{',label{is_N01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN1_CORE_multline.eps']);
      % Plot poloidal distributions of N01 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N01},' ion parallel velosity in the CORE'],['$u_{',label{is_N01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN1_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N01),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N01},' ion density in the SOL'],['$n_{',label{is_N01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN1_SOL_multline.eps']);      
end;

if  exist('is_N02','var')
      % Plot poloidal distributions of N02 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N02},' ion density in the CORE'],['$n_{',label{is_N02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN2_CORE_multline.eps']);
      % Plot poloidal distributions of N02 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N02},' ion parallel velosity in the CORE'],['$u_{',label{is_N02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN2_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N02),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N02},' ion density in the SOL'],['$n_{',label{is_N02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN2_SOL_multline.eps']);      
end;

if  exist('is_N03','var')
      % Plot poloidal distributions of N03 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N03),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N03},' ion density in the CORE'],['$n_{',label{is_N03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN3_CORE_multline.eps']);
      % Plot poloidal distributions of N03 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N03),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N03},' ion parallel velosity in the CORE'],['$u_{',label{is_N03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN3_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N03),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N03},' ion density in the SOL'],['$n_{',label{is_N03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN3_SOL_multline.eps']);      
end;


if  exist('is_N04','var')
      % Plot poloidal distributions of N04 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N04),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N04},' ion density in the CORE'],['$n_{',label{is_N04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN4_CORE_multline.eps']);
      % Plot poloidal distributions of N04 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N04),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N04},' ion parallel velosity in the CORE'],['$u_{',label{is_N04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN4_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N04),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N04},' ion density in the SOL'],['$n_{',label{is_N04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN4_SOL_multline.eps']);      
end;

if  exist('is_N05','var')
      % Plot poloidal distributions of N05 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N05),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N05},' ion density in the CORE'],['$n_{',label{is_N05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN5_CORE_multline.eps']);
      % Plot poloidal distributions of N05 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N05),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N05},' ion parallel velosity in the CORE'],['$u_{',label{is_N05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN5_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N05),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N05},' ion density in the SOL'],['$n_{',label{is_N05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN5_SOL_multline.eps']);      
end;

if  exist('is_N06','var')
      % Plot poloidal distributions of N06 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N06},' ion density in the CORE'],['$n_{',label{is_N06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN6_CORE_multline.eps']);
      % Plot poloidal distributions of N06 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N06},' ion parallel velosity in the CORE'],['$u_{',label{is_N06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN6_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N06),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N06},' ion density in the SOL'],['$n_{',label{is_N06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN6_SOL_multline.eps']);      
end;

if  exist('is_N07','var')
      % Plot poloidal distributions of N07 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_N07),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N07},' ion density in the CORE'],['$n_{',label{is_N07},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN7_CORE_multline.eps']);
      % Plot poloidal distributions of N07 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_N07),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_N07},' ion parallel velosity in the CORE'],['$u_{',label{is_N07},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN7_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,na(:,:,is_N07),nx,ny,-1,nc2,nc3,nx,nsep+1,18,[label{is_N07},' ion density in the SOL'],['$n_{',label{is_N07},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nN7_SOL_multline.eps']);      
      
      iout=poloidal_plot_multline(x2,nN_tot,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Total nitrogen density in the CORE','$n_N, \;\; \rm m^{-3}$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNtot_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,uaN_ch_avr,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Species averaged nitrogen parallel velocity in the CORE','$\left<u_N\right>, \;\; \rm m/s$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNtot_CORE_multline.eps']);
      iout=poloidal_plot_multline(x2,nN_tot,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Total nitrogen density in the SOL','$n_N, \;\; \rm m^{-3}$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNtot_SOL_multline.eps']);
      iout=poloidal_plot_multline(x2,uaN_ch_avr,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Species averaged nitrogen parallel velocity in the SOL','$\left<u_N\right>, \;\; \rm m/s$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uaN_ch_avr_SOL_multline.eps']);
      iout=poloidal_plot_multline(x1,fnax_mdf_N_ch+fnax_dia_N_ch+fnax_PSch_N_ch,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Species averaged nitrogen poloidal flux in the SOL','$\left<\Gamma_{xN}\right>, \;\; \rm s^{-1}$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'\Gamma_N_ch_avr_SOL_multline.eps']);
      iout=poloidal_plot_multline(x2,nN_tot,nx,ny,-1,nc1-1,nc4+1,nx,-1,nsep+2,'Total nitrogen density in the PFR','$n_N, \;\; \rm m^{-3}$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNtot_PFR_multline.eps']);
      
      iout=poloidal_plot_4_1D_profiles(x1,Fnax_tot_N_ch_intx_CORE_PFR,Fnax_nuExB_N_ch_intx_CORE_PFR,Fnax_nupar_N_ch_intx_CORE_PFR,Fnax_Dgradn_N_ch_intx_CORE_PFR,0,nc1-1,nc4+2,nx,nsep,'Total N fluxes in PFR','$\Gamma, s^{-1}$','total','ExB','nu_{||}','-D\nabla n');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'GammaNtot_PFR.eps']);
      iout=poloidal_plot_4_1D_profiles(x2,Fnax_tot_N_ch_intx_SOL,Fnax_nuExB_N_ch_intx_SOL,Fnax_nupar_N_ch_intx_SOL,Fnax_Dgradn_N_ch_intx_SOL,0,nc2,nc3,nx,nsep+2,'Total N fluxes in SOL','$\Gamma, s^{-1}$','total','ExB','nu_{||}','-D\nabla n');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'GammaNtot_SOL.eps']);
      
      poloidal_DND_core_plot4(x2,smotf_ii_gradTi_N_ch,smochi_N_ch,smogpi_N_ch,Eforce_N_ch,0,nc2,nc3,nx-1,nsep+2,'Nitrogen force balance, y = nsep + 2','$S_{mo}, N/m^3$','1.56 \Sigma Z^2n \nabla T_i','0.51m_in_N(u_N-u_D)/\tau_{DN}','-\nabla p','\Sigma nZe E_{||}');
      poloidal_DND_core_plot4(x2,smotf_ii_gradTi_N_ch,smochi_N_ch,smogpi_N_ch,Eforce_N_ch,0,nc2,nc3,nx-1,nsep+16,'Nitrogen force balance, y = nsep + 16','$S_{mo}, N/m^3$','1.56 \Sigma Z^2n \nabla T_i','0.51m_in_N(u_N-u_D)/\tau_{DN}','-\nabla p','\Sigma nZe E_{||}');
      iout=poloidal_DND_core_plot8(x2,ua(:,:,is_main),ua(:,:,is_N01),ua(:,:,is_N02),ua(:,:,is_N03),ua(:,:,is_N04),ua(:,:,is_N05),ua(:,:,is_N06),ua(:,:,is_N07),-1,nc2,nc3,nx,nsep+2,'Nitrogen parallel velocity, y = nsep + 2','$u, \; m/s$','D^{+}','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN_SOL_nsep2.eps']);
      iout=poloidal_DND_core_plot8(x2,ua(:,:,is_main),ua(:,:,is_N01),ua(:,:,is_N02),ua(:,:,is_N03),ua(:,:,is_N04),ua(:,:,is_N05),ua(:,:,is_N06),ua(:,:,is_N07),-1,nc2,nc3,nx,nsep+16,'Nitrogen parallel velocity, y = nsep + 16','$u, \; m/s$','D^{+}','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uN_SOL_nsep16.eps']);
end;

if  exist('is_He01','var')
      % Plot poloidal distributions of He01 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_He01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_He01},' ion density in the CORE'],['$n_{',label{is_He01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nHe01_CORE_multline.eps']);
      % Plot poloidal distributions of N06 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_He01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_He01},' ion parallel velosity in the CORE'],['$u_{',label{is_He01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uHe01_CORE_multline.eps']);
end;

if  exist('is_He02','var')
      % Plot poloidal distributions of He02 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_He02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_He02},' ion density in the CORE'],['$n_{',label{is_He02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nHe02_CORE_multline.eps']);
      % Plot poloidal distributions of N06 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_He02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_He02},' ion parallel velosity in the CORE'],['$u_{',label{is_He02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uHe02_CORE_multline.eps']);
end;

if  exist('is_Ne01','var')
      % Plot poloidal distributions of Ne01 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne01},' ion density in the CORE'],['$n_{',label{is_Ne01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe01_CORE_multline.eps']);
      % Plot poloidal distributions of Ne01 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne01),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne01},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne01},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe01_CORE_multline.eps']);
end;

if  exist('is_Ne02','var')
      % Plot poloidal distributions of N02 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne02},' ion density in the CORE'],['$n_{',label{is_Ne02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe02_CORE_multline.eps']);
      % Plot poloidal distributions of N02 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne02),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne02},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne02},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe02_CORE_multline.eps']);
end;

if  exist('is_Ne03','var')
      % Plot poloidal distributions of Ne03 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne03),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne03},' ion density in the CORE'],['$n_{',label{is_Ne03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe3_CORE_multline.eps']);
      % Plot poloidal distributions of Ne03 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne03),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne03},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne03},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe03_CORE_multline.eps']);
end;


if  exist('is_Ne04','var')
      % Plot poloidal distributions of Ne04 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne04),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne04},' ion density in the CORE'],['$n_{',label{is_Ne04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe04_CORE_multline.eps']);
      % Plot poloidal distributions of Ne04 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne04),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne04},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne04},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe04_CORE_multline.eps']);
end;

if  exist('is_Ne05','var')
      % Plot poloidal distributions of Ne05 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne05),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne05},' ion density in the CORE'],['$n_{',label{is_Ne05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe05_CORE_multline.eps']);
      % Plot poloidal distributions of Ne05 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne05),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne05},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne05},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe05_CORE_multline.eps']);
end;

if  exist('is_Ne06','var')
      % Plot poloidal distributions of Ne06 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne06},' ion density in the CORE'],['$n_{',label{is_Ne06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe06_CORE_multline.eps']);
      % Plot poloidal distributions of Ne06 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne06},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne06},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe06_CORE_multline.eps']);
end;

if  exist('is_Ne07','var')
      % Plot poloidal distributions of Ne07 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne07),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne07},' ion density in the CORE'],['$n_{',label{is_Ne07},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe07_CORE_multline.eps']);
      % Plot poloidal distributions of Ne07 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne07),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne07},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne07},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe07_CORE_multline.eps']);
end;

if  exist('is_Ne08','var')
      % Plot poloidal distributions of Ne08 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne08),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne08},' ion density in the CORE'],['$n_{',label{is_Ne08},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe08_CORE_multline.eps']);
      % Plot poloidal distributions of Ne08 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne08),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne08},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne08},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe08_CORE_multline.eps']);
end;

if  exist('is_Ne09','var')
      % Plot poloidal distributions of Ne09 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne09),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne09},' ion density in the CORE'],['$n_{',label{is_Ne09},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe09_CORE_multline.eps']);
      % Plot poloidal distributions of Ne09 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne06),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne09},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne09},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe09_CORE_multline.eps']);
end;


if  exist('is_Ne10','var')
      % Plot poloidal distributions of Ne107 density in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,na(:,:,is_Ne10),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne10},' ion density in the CORE'],['$n_{',label{is_Ne10},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNe10_CORE_multline.eps']);
      % Plot poloidal distributions of Ne10 velosity in the core for different flux surfaces
      iout=poloidal_plot_multline(x2,ua(:,:,is_Ne10),nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,[label{is_Ne10},' ion parallel velosity in the CORE'],['$u_{',label{is_Ne10},'}, \;\; \rm m^{-3}$']);
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'uNe10_CORE_multline.eps']);
      
      iout=poloidal_plot_multline(x2,nNe_tot,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'Total neon density in the CORE','$n_Ne, \;\; \rm m^{-3}$');
      set(gcf,'PaperPositionMode','auto');
      print('-depsc2','-r600',[PATH_PREFIX,'nNetot_CORE_multline.eps']);
end;


% Plot poloidal distributions of electron temperature in the core for different flux surfaces
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

iout=poloidal_plot_multline(x2,div_fvp_x,nx,ny,nc1,nc2,nc3,nc4,-1,nsep+2,'{\rm div} nu_{||} in the CORE','${\rm div} nu_{||}, \;\; \rm m^{-3}s^{-1}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'div_fvpx01_CORE_multline.eps']);

% Plot poloidal distributions of electron density in the SOL for different flux surfaces
iout=poloidal_plot_multline(x2,ne,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Electron density in the SOL','$n_e, \;\; \rm m^{-3}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ne_SOL_multline.eps']);


% Plot poloidal distributions of main ion (is=is_main) density in the SOL for different flux surfaces
iout=poloidal_plot_multline(x2,na(:,:,is_main),nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Main ion density in the SOL','$n_{i main}, \;\; \rm m^{-3}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'nD_SOL_multline.eps']);

iout=poloidal_plot_multline(x2,te,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Electron temperature in the SOL','$T_e, \;\; \rm eV$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Te_SOL_multline.eps']);


iout=poloidal_plot_multline(x2,ti,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Ion temperature in the SOL','$T_i, \;\; \rm eV$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Ti_SOLE_multline.eps']);
iout=poloidal_plot_multline(x2,po,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Potential in the SOL','$\varphi, \;\; \rm V$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'po_SOL_multline.eps']);
iout=poloidal_plot_multline(x2,ua(:,:,2)/1000,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Main ion parallel velocity in the SOL','$u_{||}^{D^+}, \;\; \rm km/s$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'uaD_SOL_multline.eps']);
iout=poloidal_plot_multline(x2,pas,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Total pressure in the SOL','$p_{tot}, \;\; \rm Pa$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'ptot_SOL_multline.eps']);
iout=poloidal_plot_multline(x2,qe*na(:,:,is_main).*ti,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Main ion pressure in the SOL','$p_{tot}, \;\; \rm Pa$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'pmain_SOL_multline.eps']);
iout=poloidal_plot_multline(x1,fnax_phys(:,:,is_main),nx,ny,0,nc2,nc3,nx,nsep+1,18,'Main ion flux in the SOL','$f_{main}, \;\; \rm s^{-1}$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gamma_main_SOL_multline.eps']);

iout=poloidal_plot_multline(x2,E_x,nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Poloidal E-field in the SOL','$E_{x}, \;\; \rm V/m$');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Gamma_main_SOL_multline.eps']);


% poloidal_DND_core_plot9(x2,shi,shi_eir,shei,shidd,shidu,shifr,shiva,shivc,sna_eir(:,:,2).*ti*qe,nc4,nc4+1,nc4+2,nx-1,nsep+3,'Ion heat source components near outer target, y = nsep + 3',...
%     '$Q_i \; W$','\rm total source','Q_{\rm EIR}','Q_{ei}','p{\rm div} u_{ExB}','p{\rm div} u_{||}','Q_{fr}','Q_{vis\rm CL}','Q_{vis\rm AN}','Sna * Ti');


% % % % % % % % % % iout=poloidal_plot_multline(x2,ua(:,:,is_main)./cs,nx,ny,nc4-5,nc4-4,nc4-3,nx-1,nsep+1,18,'Mach number near the outer target, main ions','$M, \;\; \rm $');
% % % % % % % % % % iout=poloidal_plot_multline(x2,fmo_etaPat_graduax(:,:,is_main),nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Poloidal viscous momentum flux in the SOL','$-\frac43\frac{h_z\sqrt{g}}{h^2_x}\frac{\partial u_{||}}{\partial x}, \;\; \rm $');
% % % % % % % % % % iout=poloidal_plot_multline(x2,fmo_corx(:,:,is_main),nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Poloidal particle flux and diamagnetic flux in the SOL','$\Gamma_{x}^{nomdf}+$\Gamma_{x}^{dia}, \;\; \rm s^{-1}$');
% % % % % % % % % % iout=poloidal_plot_multline(x2,fmox(:,:,is_main),nx,ny,-1,nc2,nc3,nx,nsep+1,18,'Poloidal momentum flux in the SOL','$\Gamma_{x}^{m}, \;\; \rm $');


%iout=poloidal_plot_multline(x2,fnax_nupar(:,:,2)+fnax_nuExB(:,:,2)+fnax_dia(:,:,2),nx,ny,0,nc2,nc3+1,nx,nsep+1,ny-nsep,'Poloidal particle flux in the inner SOL','$\Gamma_i, \;\;  \rm s^{-1}$');

% % iout=poloidal_plot_multline(x1,fnax_nupar(:,:,is_main)+fnax_nuExB(:,:,is_main)+fnax_dia(:,:,is_main)+fnax_Dgradn(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Poloidal main ion particle flux in the SOL','$\Gamma_i, \;\;  \rm s^{-1}$');
% % 
% % iout=poloidal_plot_multline(x2,ux_ExB(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Main ion ExB velocity in the SOL','$u_{ExB}, \;\;  \rm m/s}$');
% % iout=poloidal_plot_multline(x2,ux_dia(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Main ion grad-B drift velocity  in the SOL','$u_{\nabla B}, \;\;  \rm m/s$');
% % iout=poloidal_plot_multline(x2,Bx./B.*ua(:,:,is_main),nx,ny,0,nc2,nc3+1,nx,nsep+1,8,'Poloidal projection of main ion parallel velocity in the SOL','$b_xu_{||}, \;\;  \rm m/s$');

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



iout = R_plot_core2_1Darray(y2,1,Ey,Ey_neo,nsep,nout,'Radial electric field','E, V/m','E_{rad}','E_{rad}^{NEO}');
set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'Ey_midpl.eps']);

% % % % % % % % % %poloidal_DND_core_plot8(x2,smo(:,:,2),smogp(:,:,2),smoch(:,:,2),smotf(:,:,2),smocf(:,:,2),smovv(:,:,2),smovh(:,:,2),smoii(:,:,2),nc1,nc2,nc3,nc4,2,'momentum source components in the CORE, y = 2','$S_m \; kg\cdot m^2 / s^2$','\rm total','\nabla p + E','mn\nu(u_a-u_b)','n\nabla T$','\rm centrif','visc_1','visc_2','ion-ion');
% % % % % % % % % poloidal_DND_core_plot12(x2,smo(:,:,2),div_fmo_x(:,:,2),div_fmo_y(:,:,2),smodt(:,:,2),smogp(:,:,2),smoch(:,:,2),smotf(:,:,2),smocf(:,:,2),smovv(:,:,2),smovh(:,:,2),smoii(:,:,2),smoat(:,:,2),nc1,nc2,nc3,nc4,2,'momentum balance components in the CORE, y = 2','$S_m \; kg\cdot m^2 / s^2$','\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','\nabla p + E','mn\nu(u_a-u_b)','n\nabla T','\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % % % % % % set(gcf,'PaperPositionMode','auto');
% % % % % % % % % print('-depsc2','-r600',[PATH_PREFIX,'poloidal_momentum_flux_components_CORE.eps']);
% % % % % % % % % 
% % % % % % % % % poloidal_DND_core_plot13(x2,smo(:,:,2),div_fmo_x(:,:,2),div_fmo_y(:,:,2),smodt(:,:,2),smogp(:,:,2),smoEprll(:,:,2),smoch(:,:,2),smotf(:,:,2),smocf(:,:,2),smovv(:,:,2),smovh(:,:,2),...
% % % % % % % % %     smoii(:,:,2),smoat(:,:,2),nc4-5,nc4-4,nc4-3,nx-1,nsep+3,'momentum balance components in the SOL, y = nsep + 3','$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % % % %     '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','\nabla p + E_{||}','E_{||}','mn\nu(u_a-u_b)','n\nabla T','\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % % % % % % set(gcf,'PaperPositionMode','auto');
% % % % % % % % % print('-depsc2','-r600',[PATH_PREFIX,'Deuterium_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % % % % % 

% % % % % % % % inner part of the SOL
% % % % % % % poloidal_DND_core_plot2(x2,te,ti,1,3,5,nc1+6,nsep+3,'Temperatures in the SOL, y = nsep + 3, inner part','$T, \; eV$','T_e','T_i');
% % % % % % % set(gcf,'PaperPositionMode','auto');
% % % % % % % print('-depsc2','-r600',[PATH_PREFIX,'Te_Ti_pol_in_nsep_3.eps']);
% % % % % % % 
% % % % % % % if  exist('is_N01','var')
% % % % % % %     iout=poloidal_DND_core_plot10(x2,na(:,:,is_main)/1000.0,na(:,:,is_N01-1),na(:,:,is_N01),na(:,:,is_N02),na(:,:,is_N03),na(:,:,is_N04),na(:,:,is_N05),na(:,:,is_N06),na(:,:,is_N07),nN_tot,...
% % % % % % %         1,3,5,nc1+6,nsep+3,'Ion densities, y = nsep + 3, inner part','$n, \; 10^{19} \; s^{-1}$','D^{+}/1000','N^0','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{tot}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'n_pol_in_nsep_3.eps']);    
% % % % % % %     iout=poloidal_DND_core_plot9(x2,ua(:,:,is_main),ua(:,:,is_N01),ua(:,:,is_N02),ua(:,:,is_N03),ua(:,:,is_N04),ua(:,:,is_N05),ua(:,:,is_N06),ua(:,:,is_N07),uaN_ch_avr,...
% % % % % % %         1,3,5,nc1+6,nsep+3,'Ion parallel velocities, y = nsep + 3, inner part','$u, \; m/s$','D^{+}','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{avr}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'upar_pol_in_nsep_3.eps']);    
% % % % % % %     iout=poloidal_DND_core_plot2(x1,sna_eir(:,:,is_main)/1000.0,sna_eir(:,:,is_N01),...
% % % % % % %         1,3,5,nc1+6,nsep+3,'Sources (from Eirene), y = nsep + 3, inner part','$S_{eir}, \; s^{-1}$','D^{+}/1000','N^{+}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'sna_pol_in_nsep_3.eps']);    
% % % % % % % % % %     iout=poloidal_DND_core_plot9(x1,fnax_mdf(:,:,is_main)/1000.0,fnax_mdf(:,:,is_N01),fnax_mdf(:,:,is_N02),fnax_mdf(:,:,is_N03),fnax_mdf(:,:,is_N04),fnax_mdf(:,:,is_N05),fnax_mdf(:,:,is_N06),fnax_mdf(:,:,is_N07),...
% % % % % % % % % %         fnax_mdf(:,:,is_N01)+fnax_mdf(:,:,is_N02)+fnax_mdf(:,:,is_N03)+fnax_mdf(:,:,is_N04)+fnax_mdf(:,:,is_N05)+fnax_mdf(:,:,is_N06)+fnax_mdf(:,:,is_N07),...
% % % % % % % % % %         1,3,5,nc1-6,nsep+3,'Ion parallel fluxes (mdf), y = nsep + 3','$\Gamma, \; s^{-1}$','D^{+}/1000','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{avr}');
% % % % % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'fna_mdf__pol_out_nsep_3.eps']);    
% % % % % % %     iout=poloidal_DND_core_plot9(x1,fnax_phys(:,:,is_main)/1000.0,fnax_phys(:,:,is_N01),fnax_phys(:,:,is_N02),fnax_phys(:,:,is_N03),fnax_phys(:,:,is_N04),fnax_phys(:,:,is_N05),fnax_phys(:,:,is_N06),fnax_phys(:,:,is_N07),...
% % % % % % %         fnax_phys(:,:,is_N01)+fnax_phys(:,:,is_N02)+fnax_phys(:,:,is_N03)+fnax_phys(:,:,is_N04)+fnax_phys(:,:,is_N05)+fnax_phys(:,:,is_N06)+fnax_phys(:,:,is_N07),...
% % % % % % %         2,3,4,nc1+6,nsep+3,'Ion parallel fluxes (phys), y = nsep + 3, inner part','$\Gamma, \; s^{-1}$','D^{+}/1000','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{avr}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'fna_phys__pol_out_nsep_3.eps']);    
% % % % % % % % % %     poloidal_DND_core_plot3(x2,smotf_ii_gradTi(:,:,is_main),smotf_ii_gradTi_Ntot,abs(smotf_ii_gradTi(:,:,is_main)+smotf_ii_gradTi_Ntot),...
% % % % % % % % % %          1,3,5,nc1-6,nsep+3,[label{is_N02},' Thermal force in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % % % % %          'D','N_{tot}','D+N_{tot}');
% % % % % % % end;
% % % % % % % poloidal_DND_core_plot4(x2,smoe_grad_pe,-smoEprll_tot,-smoche_tot,-smotf_ie_gradTe_tot,...
% % % % % % %          1,3,5,nc1+6,nsep+3,'Electron force balance in the SOL (approximation), y = nsep + 3, inner part','$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % %          '-\nabla p_e','-en_eE_{||}','\sigma m_en_e\nu_{ae}(u_a-u_e)', 'n\nabla Te');
% % % % % % % set(gcf,'PaperPositionMode','auto');
% % % % % % % print('-depsc2','-r600',[PATH_PREFIX,'eForce_pol_in_nsep_3.eps']);
% % % % % % %     
% % % % % % % for is=1:ns
% % % % % % %     if Za(is) > 0
% % % % % % %         poloidal_DND_core_plot15(x2,smo(:,:,is),div_fmo_x(:,:,is),div_fmo_y(:,:,is),smodt(:,:,is),smogpi(:,:,is),smoEprll(:,:,is),smochi(:,:,is),...
% % % % % % %              smoche(:,:,is),smotf_ii_gradTi(:,:,is),smotf_ie_gradTe(:,:,is),smocf(:,:,is),smovv(:,:,is),smovh(:,:,is),...
% % % % % % %              smoii(:,:,is),smoat(:,:,is),2,3,4,nc1+6,nsep+3,[label{is},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % %              '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu_{ab}(u_a-u_b)','-m_en_e\nu_{ae}(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % % % %              '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % % % %         set(gcf,'PaperPositionMode','auto');
% % % % % % %         print('-depsc2','-r600',[PATH_PREFIX,label_string{is},'_poloidal_momentum_flux_components_near_inner_divertor.eps']);
% % % % % % %     end;
% % % % % % % end;
% % % % % % % 
% % % % % % % % outer part of the SOL
% % % % % % % poloidal_DND_core_plot2(x2,te,ti,nc4-6,nc4-4,nc4-3,nx,nsep+3,'Temperatures in the SOL, y = nsep + 3, outer part','$T, \; eV$','T_e','T_i');
% % % % % % % set(gcf,'PaperPositionMode','auto');
% % % % % % % print('-depsc2','-r600',[PATH_PREFIX,'Te_Ti_pol_out_nsep_3.eps']);
% % % % % % % 
% % % % % % % if  exist('is_N01','var')
% % % % % % %     iout=poloidal_DND_core_plot10(x2,na(:,:,is_main)/1000.0,na(:,:,is_N01-1),na(:,:,is_N01),na(:,:,is_N02),na(:,:,is_N03),na(:,:,is_N04),na(:,:,is_N05),na(:,:,is_N06),na(:,:,is_N07),nN_tot,...
% % % % % % %         nc4-6,nc4-4,nc4-3,nx,nsep+3,'Ion densities, y = nsep + 3, outer part','$n, \; 10^{19} \; s^{-1}$','D^{+}/1000','N^0','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{tot}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'n_pol_out_nsep_3.eps']);    
% % % % % % %     iout=poloidal_DND_core_plot9(x2,ua(:,:,is_main),ua(:,:,is_N01),ua(:,:,is_N02),ua(:,:,is_N03),ua(:,:,is_N04),ua(:,:,is_N05),ua(:,:,is_N06),ua(:,:,is_N07),uaN_ch_avr,...
% % % % % % %         nc4-6,nc4-4,nc4-3,nx,nsep+3,'Ion parallel velocities, y = nsep + 3, outer part','$u, \; m/s$','D^{+}','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{avr}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'upar_pol_out_nsep_3.eps']);    
% % % % % % %     iout=poloidal_DND_core_plot2(x1,sna_eir(:,:,is_main)/1000.0,sna_eir(:,:,is_N01),...
% % % % % % %         nc4-6,nc4-4,nc4-3,nx-1,nsep+3,'Sources (from Eirene), y = nsep + 3, outer part','$S_{eir}, \; s^{-1}$','D^{+}/1000','N^{+}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'sna_pol_out_nsep_3.eps']);    
% % % % % % % % % %     iout=poloidal_DND_core_plot9(x1,fnax_mdf(:,:,is_main)/1000.0,fnax_mdf(:,:,is_N01),fnax_mdf(:,:,is_N02),fnax_mdf(:,:,is_N03),fnax_mdf(:,:,is_N04),fnax_mdf(:,:,is_N05),fnax_mdf(:,:,is_N06),fnax_mdf(:,:,is_N07),...
% % % % % % % % % %         fnax_mdf(:,:,is_N01)+fnax_mdf(:,:,is_N02)+fnax_mdf(:,:,is_N03)+fnax_mdf(:,:,is_N04)+fnax_mdf(:,:,is_N05)+fnax_mdf(:,:,is_N06)+fnax_mdf(:,:,is_N07),...
% % % % % % % % % %         nc4-6,nc4-4,nc4-3,nx-1,nsep+3,'Ion parallel fluxes (mdf), y = nsep + 3','$\Gamma, \; s^{-1}$','D^{+}/1000','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{avr}');
% % % % % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'fna_mdf__pol_out_nsep_3.eps']);    
% % % % % % %     iout=poloidal_DND_core_plot9(x1,fnax_phys(:,:,is_main)/1000.0,fnax_phys(:,:,is_N01),fnax_phys(:,:,is_N02),fnax_phys(:,:,is_N03),fnax_phys(:,:,is_N04),fnax_phys(:,:,is_N05),fnax_phys(:,:,is_N06),fnax_phys(:,:,is_N07),...
% % % % % % %         fnax_phys(:,:,is_N01)+fnax_phys(:,:,is_N02)+fnax_phys(:,:,is_N03)+fnax_phys(:,:,is_N04)+fnax_phys(:,:,is_N05)+fnax_phys(:,:,is_N06)+fnax_phys(:,:,is_N07),...
% % % % % % %         nc4-6,nc4-4,nc4-3,nx,nsep+3,'Ion parallel fluxes (phys), y = nsep + 3, outer part','$\Gamma, \; s^{-1}$','D^{+}/1000','N^{+}','N^{++}','N^{3+}','N^{4+}','N^{5+}','N^{6+}','N^{7+}','N_{avr}');
% % % % % % %     set(gcf,'PaperPositionMode','auto');
% % % % % % %     print('-depsc2','-r600',[PATH_PREFIX,'fna_phys__pol_out_nsep_3.eps']);    
% % % % % % % % % %     poloidal_DND_core_plot3(x2,smotf_ii_gradTi(:,:,is_main),smotf_ii_gradTi_Ntot,abs(smotf_ii_gradTi(:,:,is_main)+smotf_ii_gradTi_Ntot),...
% % % % % % % % % %          nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' Thermal force in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % % % % %          'D','N_{tot}','D+N_{tot}');
% % % % % % % end;
% % % % % % % poloidal_DND_core_plot4(x2,smoe_grad_pe,-smoEprll_tot,-smoche_tot,-smotf_ie_gradTe_tot,...
% % % % % % %          nc4-6,nc4-4,nc4-3,nx-1,nsep+3,'Electron force balance in the SOL (approximation), y = nsep + 3, outer part','$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % %          '-\nabla p_e','-en_eE_{||}','\sigma m_en_e\nu_{ae}(u_a-u_e)', 'n\nabla Te');
% % % % % % % set(gcf,'PaperPositionMode','auto');
% % % % % % % print('-depsc2','-r600',[PATH_PREFIX,'eForce_pol_out_nsep_3.eps']);
% % % % % % %     
% % % % % % % for is=1:ns
% % % % % % %     if Za(is) > 0
% % % % % % %         poloidal_DND_core_plot15(x2,smo(:,:,is),div_fmo_x(:,:,is),div_fmo_y(:,:,is),smodt(:,:,is),smogpi(:,:,is),smoEprll(:,:,is),smochi(:,:,is),...
% % % % % % %              smoche(:,:,is),smotf_ii_gradTi(:,:,is),smotf_ie_gradTe(:,:,is),smocf(:,:,is),smovv(:,:,is),smovh(:,:,is),...
% % % % % % %              smoii(:,:,is),smoat(:,:,is),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is},' momentum balance components in the SOL, y = nsep + 3, outer part'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % %              '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu_{ab}(u_a-u_b)','-m_en_e\nu_{ae}(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % % % %              '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % % % %         set(gcf,'PaperPositionMode','auto');
% % % % % % %         print('-depsc2','-r600',[PATH_PREFIX,label_string{is},'_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % % %     end;
% % % % % % % end;


% % % %     poloidal_DND_core_plot3(x2,smoii(:,:,is_N02),smo_smq(:,:,is_N02),smq_sral(:,:,is_N02),...
% % % %         nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % %         '\rm smoii','\rm smq','\rm smq sral');
% % % %     poloidal_DND_core_plot3(x2,smo(:,:,is_N02),smogpi(:,:,is_N02)+smoEprll(:,:,is_N02)+smochi(:,:,is_N02)+...
% % % %         smoche(:,:,is_N02)+smotf_ii_gradTi(:,:,is_N02)+smotf_ie_gradTe(:,:,is_N02)+smocf(:,:,is_N02)+smovv(:,:,is_N02)+smovh(:,:,is_N02)+...
% % % %         smo_smq(:,:,is_N02)+smoat(:,:,is_N02),smodt(:,:,is_N02)+smogpi(:,:,is_N02)+smoEprll(:,:,is_N02)+smochi(:,:,is_N02)+...
% % % %         smotf_b2npmo(:,:,is_N02)+smocf(:,:,is_N02)+smovv(:,:,is_N02)+smovh(:,:,is_N02)+...
% % % %         smoii(:,:,is_N02)+smoat(:,:,is_N02),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % %         '\rm total source','sum1','sum2');




% % % % % if  exist('is_N01','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N01),div_fmo_x(:,:,is_N01),div_fmo_y(:,:,is_N01),smodt(:,:,is_N01),smogpi(:,:,is_N01),smoEprll(:,:,is_N01),smochi(:,:,is_N01),...
% % % % %         smoche(:,:,is_N01),smotf_ii_gradTi(:,:,is_N01),smotf_ie_gradTe(:,:,is_N01),smocf(:,:,is_N01),smovv(:,:,is_N01),smovh(:,:,is_N01),...
% % % % %         smoii(:,:,is_N01),smoat(:,:,is_N01),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N01},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N01_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % % % %     poloidal_DND_core_plot3(x2,smo(:,:,is_N01),smo_sral(:,:,is_N01),smodt(:,:,is_N01),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N01},...
% % % % % % % %         ' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % % % % %         '\rm total source','sral','smodt');
% % % % % end;
% % % % % if  exist('is_N02','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N02),div_fmo_x(:,:,is_N02),div_fmo_y(:,:,is_N02),smodt(:,:,is_N02),smogpi(:,:,is_N02),smoEprll(:,:,is_N02),smochi(:,:,is_N02),...
% % % % %         smoche(:,:,is_N02),smotf_ii_gradTi(:,:,is_N02),smotf_ie_gradTe(:,:,is_N02),smocf(:,:,is_N02),smovv(:,:,is_N02),smovh(:,:,is_N02),...
% % % % %         smoii(:,:,is_N02),smoat(:,:,is_N02),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N02_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % %     poloidal_DND_core_plot3(x2,smo(:,:,is_N02),smodt(:,:,is_N02)+smogpi(:,:,is_N02)+smoEprll(:,:,is_N02)+smochi(:,:,is_N02)+...
% % % % %         smoche(:,:,is_N02)+smotf_ii_gradTi(:,:,is_N02)+smotf_ie_gradTe(:,:,is_N02)+smocf(:,:,is_N02)+smovv(:,:,is_N02)+smovh(:,:,is_N02)+...
% % % % %         smoii(:,:,is_N02)+smoat(:,:,is_N02),smodt(:,:,is_N02)+smogpi(:,:,is_N02)+smoEprll(:,:,is_N02)+smochi(:,:,is_N02)+...
% % % % %         smotf_b2npmo(:,:,is_N02)+smocf(:,:,is_N02)+smovv(:,:,is_N02)+smovh(:,:,is_N02)+...
% % % % %         smoii(:,:,is_N02)+smoat(:,:,is_N02),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','sum1','sum2');
% % % % %     poloidal_DND_core_plot3(x2,smotf_b2npmo(:,:,is_N02),smotf_b2sifr(:,:,is_N02),smotf_b2sifr2(:,:,is_N02),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm npmo','sifr','sifr2');
% % % % %     poloidal_DND_core_plot5(x2,smotf_b2npmo(:,:,is_N02),smotf_b2sifr(:,:,is_N02),smotf_b2sifr2(:,:,is_N02),smotf_b2npmo_manual0(:,:,is_N02),smotf_b2npmo_manual1(:,:,is_N02),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm npmo','sifr','sifr2','man0','man1');
% % % % %     poloidal_DND_core_plot2(x2,smoche(:,:,is_N02)+smotf_ii_gradTi(:,:,is_N02)+smotf_ie_gradTe(:,:,is_N02),smotf_b2npmo(:,:,is_N02),...
% % % % %         nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N02},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm smotf new','\rm smotf old');
% % % % %     poloidal_DND_core_plot3(x2,smo(:,:,is_N02),smo_sral(:,:,is_N02),smodt(:,:,is_N02),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N01},...
% % % % %         ' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','sral','smodt');
% % % % % end;
% % % % % if  exist('is_N03','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N03),div_fmo_x(:,:,is_N03),div_fmo_y(:,:,is_N03),smodt(:,:,is_N03),smogpi(:,:,is_N03),smoEprll(:,:,is_N03),smochi(:,:,is_N03),...
% % % % %         smoche(:,:,is_N03),smotf_ii_gradTi(:,:,is_N03),smotf_ie_gradTe(:,:,is_N03),smocf(:,:,is_N03),smovv(:,:,is_N03),smovh(:,:,is_N03),...
% % % % %         smoii(:,:,is_N03),smoat(:,:,is_N03),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N03},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N03_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % end;
% % % % % if  exist('is_N04','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N04),div_fmo_x(:,:,is_N04),div_fmo_y(:,:,is_N04),smodt(:,:,is_N04),smogpi(:,:,is_N04),smoEprll(:,:,is_N04),smochi(:,:,is_N04),...
% % % % %         smoche(:,:,is_N04),smotf_ii_gradTi(:,:,is_N04),smotf_ie_gradTe(:,:,is_N04),smocf(:,:,is_N04),smovv(:,:,is_N04),smovh(:,:,is_N04),...
% % % % %         smoii(:,:,is_N04),smoat(:,:,is_N04),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N04},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N04_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % end;
% % % % % if  exist('is_N05','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N05),div_fmo_x(:,:,is_N05),div_fmo_y(:,:,is_N05),smodt(:,:,is_N05),smogpi(:,:,is_N05),smoEprll(:,:,is_N05),smochi(:,:,is_N05),...
% % % % %         smoche(:,:,is_N05),smotf_ii_gradTi(:,:,is_N05),smotf_ie_gradTe(:,:,is_N05),smocf(:,:,is_N05),smovv(:,:,is_N05),smovh(:,:,is_N05),...
% % % % %         smoii(:,:,is_N05),smoat(:,:,is_N05),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N05},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N05_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % end;
% % % % % if  exist('is_N06','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N06),div_fmo_x(:,:,is_N06),div_fmo_y(:,:,is_N06),smodt(:,:,is_N06),smogpi(:,:,is_N06),smoEprll(:,:,is_N06),smochi(:,:,is_N06),...
% % % % %         smoche(:,:,is_N06),smotf_ii_gradTi(:,:,is_N06),smotf_ie_gradTe(:,:,is_N06),smocf(:,:,is_N06),smovv(:,:,is_N06),smovh(:,:,is_N06),...
% % % % %         smoii(:,:,is_N06),smoat(:,:,is_N06),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N06},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N06_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % end;
% % % % % if  exist('is_N07','var')
% % % % %     poloidal_DND_core_plot15(x2,smo(:,:,is_N07),div_fmo_x(:,:,is_N07),div_fmo_y(:,:,is_N07),smodt(:,:,is_N07),smogpi(:,:,is_N07),smoEprll(:,:,is_N07),smochi(:,:,is_N07),...
% % % % %         smoche(:,:,is_N07),smotf_ii_gradTi(:,:,is_N07),smotf_ie_gradTe(:,:,is_N07),smocf(:,:,is_N07),smovv(:,:,is_N07),smovh(:,:,is_N07),...
% % % % %         smoii(:,:,is_N07),smoat(:,:,is_N07),nc4-6,nc4-4,nc4-3,nx-1,nsep+3,[label{is_N07},' momentum balance components in the SOL, y = nsep + 3'],'$S_m \; kg\cdot m^2 / s^2$',...
% % % % %         '\rm total source','{\rm div} \Gamma_x^{(m)}','{\rm div} \Gamma_y^{(m)}','time deriv.','-\nabla p_i','E_{||}','-mn\nu(u_a-u_b)','-mn\nu(u_a-u_e)','n\nabla Ti','n\nabla Te',...
% % % % %         '\rm centrif','visc_1','visc_2','ion-ion','Eirene');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'N07_poloidal_momentum_flux_components_near_outer_divertor.eps']);
% % % % % end;
% % % % % 
% % % % % 
% % % % % if  exist('is_C01','var')
% % % % %     iout=poloidal_plot_4_1D_profiles(x2,Fnax_mdf_C_ch,Fnax_nuExB_C_ch,Fnax_Dgradn_C_ch,Fnax_nupar_C_ch,0,nc2,nc3,nx,nsep+1,'Integrated poloidal carbon flux, s^{-1}','$\Gamma_x, \; s^{-1}$','Total','ExB','D\nabla n','nu_{||}');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'Ctot_poloidal_flux_components.eps']);
% % % % %     iout=poloidal_plot_4_1D_profiles(x2,Fnax_mdf_C_ch,Fnax_nuExB_C_ch,Fnax_Dgradn_C_ch,Fnax_nupar_C_ch,0,nc1,nc1+1,nc1+3,nsep+1,'Integrated poloidal carbon flux, s^{-1}','$\Gamma_x, \; s^{-1}$','Total','ExB','D\nabla n','nu_{||}');
% % % % %     set(gcf,'PaperPositionMode','auto');
% % % % %     print('-depsc2','-r600',[PATH_PREFIX,'Ctot_poloidal_flux_components_near_inner_divertor.eps']);
% % % % % end;


% iout=poloidal_plot_2_1D_profiles(x2,jx_prllc_dens,sigxc_luc_Ebx,nout,nc4,nc4+1,nx,nsep+2,'outer SOL','A/m^2','j_{||}','\sigma_{||}E_{||}');

% % % % % % % % if  exist('is_C01','var')
% % % % % % % % inner target
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),2,nc1,nc1+1,nc1+2,nsep+1,'main ion flux components in the SOL near inner target, y = nsep + 1','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),2,nc1,nc1+1,nc1+2,nsep+2,'main ion flux components in the SOL near inner target, y = nsep + 2','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),2,nc1,nc1+1,nc1+2,nsep+3,'main ion flux components in the SOL near inner target, y = nsep + 3','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),2,nc1,nc1+1,nc1+2,nsep+4,'main ion flux components in the SOL near inner target, y = nsep + 4','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),2,nc1,nc1+1,nc1+2,nsep+5,'main ion flux components in the SOL near inner target, y = nsep + 5','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),2,nc1,nc1+1,nc1+2,nsep+6,'main ion flux components in the SOL near inner target, y = nsep + 6','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % 
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),2,nc1,nc1+1,nc1+2,nsep+1,'C^{+1} flux components in the SOL near inner target, y = nsep + 1','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),2,nc1,nc1+1,nc1+2,nsep+2,'C^{+1} flux components in the SOL near inner target, y = nsep + 2','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),2,nc1,nc1+1,nc1+2,nsep+3,'C^{+1} flux components in the SOL near inner target, y = nsep + 3','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),2,nc1,nc1+1,nc1+2,nsep+4,'C^{+1} flux components in the SOL near inner target, y = nsep + 4','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),2,nc1,nc1+1,nc1+2,nsep+5,'C^{+1} flux components in the SOL near inner target, y = nsep + 5','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),2,nc1,nc1+1,nc1+2,nsep+6,'C^{+1} flux components in the SOL near inner target, y = nsep + 6','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % 
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),2,nc1,nc1+1,nc1+2,nsep+1,'C^{+2} flux components in the SOL near inner target, y = nsep + 1','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),2,nc1,nc1+1,nc1+2,nsep+2,'C^{+2} flux components in the SOL near inner target, y = nsep + 2','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),2,nc1,nc1+1,nc1+2,nsep+3,'C^{+2} flux components in the SOL near inner target, y = nsep + 3','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),2,nc1,nc1+1,nc1+2,nsep+4,'C^{+2} flux components in the SOL near inner target, y = nsep + 4','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),2,nc1,nc1+1,nc1+2,nsep+5,'C^{+2} flux components in the SOL near inner target, y = nsep + 5','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),2,nc1,nc1+1,nc1+2,nsep+6,'C^{+2} flux components in the SOL near inner target, y = nsep + 6','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % 
% % % % % % % % 
% % % % % % % % outer target
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),nc4-2,nc4-1,nc4,nx-1,nsep+1,'main ion flux components in the SOL near outer target, y = nsep + 1','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),nc4-2,nc4-1,nc4,nx-1,nsep+2,'main ion flux components in the SOL near outer target, y = nsep + 2','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),nc4-2,nc4-1,nc4,nx-1,nsep+3,'main ion flux components in the SOL near outer target, y = nsep + 3','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),nc4-2,nc4-1,nc4,nx-1,nsep+4,'main ion flux components in the SOL near outer target, y = nsep + 4','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),nc4-2,nc4-1,nc4,nx-1,nsep+5,'main ion flux components in the SOL near outer target, y = nsep + 5','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,2),fnax_Dgradn(:,:,2),fnax_nuExB(:,:,2),fnax_PSch(:,:,2),fnax_dia(:,:,2),fnax_uDPC(:,:,2),fnax_nupar(:,:,2),nc4-2,nc4-1,nc4,nx-1,nsep+6,'main ion flux components in the SOL near outer target, y = nsep + 6','$\Gamma, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % 
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),nc4-2,nc4-1,nc4,nx-1,nsep+1,'C^{+1} flux components in the SOL near outer target, y = nsep + 1','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),nc4-2,nc4-1,nc4,nx-1,nsep+2,'C^{+1} flux components in the SOL near outer target, y = nsep + 2','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),nc4-2,nc4-1,nc4,nx-1,nsep+3,'C^{+1} flux components in the SOL near outer target, y = nsep + 3','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),nc4-2,nc4-1,nc4,nx-1,nsep+4,'C^{+1} flux components in the SOL near outer target, y = nsep + 4','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),nc4-2,nc4-1,nc4,nx-1,nsep+5,'C^{+1} flux components in the SOL near outer target, y = nsep + 5','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,4),fnax_Dgradn(:,:,4),fnax_nuExB(:,:,4),fnax_PSch(:,:,4),fnax_dia(:,:,4),fnax_uDPC(:,:,4),fnax_nupar(:,:,4),nc4-2,nc4-1,nc4,nx-1,nsep+6,'C^{+1} flux components in the SOL near outer target, y = nsep + 6','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % 
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),nc4-2,nc4-1,nc4,nx-1,nsep+1,'C^{+2} flux components in the SOL near outer target, y = nsep + 1','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),nc4-2,nc4-1,nc4,nx-1,nsep+2,'C^{+2} flux components in the SOL near outer target, y = nsep + 2','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),nc4-2,nc4-1,nc4,nx-1,nsep+3,'C^{+2} flux components in the SOL near outer target, y = nsep + 3','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),nc4-2,nc4-1,nc4,nx-1,nsep+4,'C^{+2} flux components in the SOL near outer target, y = nsep + 4','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),nc4-2,nc4-1,nc4,nx-1,nsep+5,'C^{+2} flux components in the SOL near outer target, y = nsep + 5','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % poloidal_DND_core_plot7(x2,fnax_mdf(:,:,5),fnax_Dgradn(:,:,5),fnax_nuExB(:,:,5),fnax_PSch(:,:,5),fnax_dia(:,:,5),fnax_uDPC(:,:,5),fnax_nupar(:,:,5),nc4-2,nc4-1,nc4,nx-1,nsep+6,'C^{+2} flux components in the SOL near outer target, y = nsep + 6','$\Gamma_x, 1 /m^2 s$','\rm \Gamma_x^{(mdf)}','\Gamma_x^{\rm diff}','nu_x^{\rm ExB}','nu_x^{\rm PSch}','nu_x^{\nabla B}','nu_x^{\rm DPC}','b_xnu_{||}');
% % % % % % % % 
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc1,'main ion flux components above X-point at the HFS, x = nc1','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc1+1,'main ion flux components above X-point at the HFS, x = nc1+1','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc1+2,'main ion flux components above X-point at the HFS, x = nc1+2','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc1+3,'main ion flux components above X-point at the HFS, x = nc1+3','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc1+4,'main ion flux components above X-point at the HFS, x = nc1+4','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc1+5,'main ion flux components above X-point at the HFS, x = nc1+5','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % 
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc4,'main ion flux components above X-point at the LFS, x = nc4','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc4-1,'main ion flux components above X-point at the LFS, x = nc4-1','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc4-2,'main ion flux components above X-point at the LFS, x = nc4-2','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc4-3,'main ion flux components above X-point at the LFS, x = nc4-3','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc4-4,'main ion flux components above X-point at the LFS, x = nc4-4','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % R_plot_6(y2,fnay_mdf(:,:,2),fnay_Dgradn(:,:,2),fnay_nuExB(:,:,2),fnay_PSch(:,:,2),fnay_dia(:,:,2),fnay_nuAN(:,:,2),nx,ny,nc4-5,'main ion flux components above X-point at the LFS, x = nc4-5','$\Gamma_y, 1 /m^2 s$','\rm \Gamma_y^{(mdf)}','\Gamma_y^{\rm diff}','nu_y^{\rm ExB}','nu_y^{\rm PSch}','nu_y^{\nabla B}','nu_y^{\rm AN}');
% % % % % % % % 
% % % % % % % % end;