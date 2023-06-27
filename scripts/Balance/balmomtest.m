%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balmom plots the momentum balance for a given SOLPS simulation.              %
% balfile:     Full path to balance.nc file                                    %
% indbal:      Logical matrix of size nx*ny that is true for cells where       %
%              balance should be performed                                     %
% iyplot:      Array of y indices along which poloidal balance will be plotted %
%              (within the volume specified by indbal)                         %
% isplot:      Species index to be plotted                                     %
% comuse:      Structure containing commonly-used variables (from get_comuse)  %
% axbal:       Array of axes into which balance plots will be placed           %
% reverse:     True if the right-most end of the balance volume is upstream of %
%              the left-most end, otherwise false                              %
% strata_plot: If true then divide the EIRENE source into components from each %
%              stratum (in a new figure)                                       %
% axstrat:     Array of aces into which strata plots will be placed            %
% makeplot:    Decides whether to make plots or just pass back the values in   %
%              the radial balance plots                                        %
% areaend:     Either 'left', 'right' or 'none'. Defines the poloidal end      %
%              of the balance region at which areas will be calculated. The    %
%              poloidal fluxes at both ends will then be divided by these      %
%              areas to give flux densities.                                   %
% area_divide: The area that poloidal fluxes and sources are divided by        %
% areatype:    The type of area that poloidal fluxes are divided by            %
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function balmomtest(balfile,indrad,indpol,isplot,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fmo_tot');
fmox_tot = sum(tmp(:,:,1,isplot),4);
fmox_tot_compare = 0;
tmp = ncread(balfile,'fmo_flua');
fmox_tot_compare = fmox_tot_compare + sum(tmp(:,:,1,isplot),4);
tmp = ncread(balfile,'fmo_cvsa');
fmox_tot_compare = fmox_tot_compare + sum(tmp(:,:,1,isplot),4);
tmp = ncread(balfile,'fmo_hybr');
fmox_tot_compare = fmox_tot_compare + sum(tmp(:,:,1,isplot),4);
% tmp = ncread(balfile,'fmo_b2nxfv');
% fmox_tot_compare = fmox_tot_compare + sum(tmp(:,:,1,isplot),4);
figure; hold on;
plot(fmox_tot(2:end-1,comuse.sep+2));
plot(fmox_tot_compare(2:end-1,comuse.sep+2));
plot(fmox_tot(2:end-1,comuse.sep+2)-fmox_tot_compare(2:end-1,comuse.sep+2));
% Sources:
tmp = ncread(balfile,'tot_smo_bal');
tot_smo = sum(tmp(:,:,isplot),3);
tot_smo_compare = 0;
tmp = ncread(balfile,'b2stbr_phys_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbr_bas_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbc_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'eirene_mc_mapl_smo_bal');
tot_smo_compare = tot_smo_compare + squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'eirene_mc_mmpl_smo_bal');
tot_smo_compare = tot_smo_compare + squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'eirene_mc_mipl_smo_bal');
tot_smo_compare = tot_smo_compare + squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
try
    tmp = ncread(balfile,'eirene_mc_mppl_smo_bal');
catch exception
    if strcmp(exception.identifier,'MATLAB:imagesci:netcdf:unknownLocation')
        warning('eirene_mc_mppl_smo_bal not found in %s. Trying old name eirene_mc_cppv_smo_bal instead..',balfile);
        try
            tmp = ncread(balfile,'eirene_mc_cppv_smo_bal');
            display('Found!');
        catch exception
            error(exception.message);
        end
    else
        error(exception.message);
    end
end
tot_smo_compare = tot_smo_compare + squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'b2stbm_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'ext_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_smq_ion_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_smq_rec_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stcx_smq_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srsm_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srdt_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srst_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smoch_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_ehxp_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_cthe_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_cthi_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smofrea_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smofria_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotfea_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotfia_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2siav_smovh_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2siav_smovv_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sicf_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sian_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2nxdv_smo_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sigp_smogpi_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sigp_smogpe_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sigp_smogpgr_bal');
tot_smo_compare = tot_smo_compare + sum(tmp(:,:,isplot),3);

figure; hold on;
plot(tot_smo(2:end-1,comuse.sep+2));
plot(tot_smo_compare(2:end-1,comuse.sep+2));
plot(tot_smo(2:end-1,comuse.sep+2)-tot_smo_compare(2:end-1,comuse.sep+2));
% Residual:
tmp = ncread(balfile,'resmo');
resmo = sum(tmp(:,:,isplot),3);
%%

%% Create the units string
switch areatype
    case 'parallel'
        units = 'Nm^{-2}';
    case 'contact'
        units = 'Nm^{-2}';
    case 'none'
        units = 'N';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end
%%

%% Calculate the radial divergence...
% raddiv_flua = zeros(nx,ny);
% raddiv_visc = zeros(nx,ny);
% raddiv_hybr = zeros(nx,ny);
% raddiv_b2nxfv = zeros(nx,ny);
raddiv_fmotot = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
%         raddiv_flua(ix,iy) = fmoy_flua(ix,iy)-fmoy_flua(topix(ix,iy),topiy(ix,iy));
%         raddiv_visc(ix,iy) = fmoy_cvsa(ix,iy)-fmoy_cvsa(topix(ix,iy),topiy(ix,iy));
%         raddiv_hybr(ix,iy) = fmoy_hybr(ix,iy)-fmoy_hybr(topix(ix,iy),topiy(ix,iy));
%         raddiv_b2nxfv(ix,iy) = fmoy_b2nxfv(ix,iy)-fmoy_b2nxfv(topix(ix,iy),topiy(ix,iy));
        raddiv_fmotot(ix,iy) = fmoy_tot(ix,iy)-fmoy_tot(topix(ix,iy),topiy(ix,iy));
    end
end
%%

%% Calculate the poloidal divergence of the viscous, hybrid correction and new ion viscosity form parts...
% visc = zeros(nx,ny);
% hybr = zeros(nx,ny);
% b2nxfv = zeros(nx,ny);
% for iy=1:ny
%     for ix=1:nx
%         if rightix(ix,iy)>nx
%             continue;
%         end
% %         visc(ix,iy) = (fmox_cvsa(ix,iy)+fmox_b2nxfv(ix,iy))-...
% %                       (fmox_cvsa(rightix(ix,iy),rightiy(ix,iy))+fmox_b2nxfv(rightix(ix,iy),rightiy(ix,iy)));
%         visc(ix,iy) = fmox_cvsa(ix,iy)-fmox_cvsa(rightix(ix,iy),rightiy(ix,iy));
%         hybr(ix,iy) = fmox_hybr(ix,iy)-fmox_hybr(rightix(ix,iy),rightiy(ix,iy));
%         b2nxfv(ix,iy) = fmox_b2nxfv(ix,iy)-fmox_b2nxfv(rightix(ix,iy),rightiy(ix,iy));
%     end
% end
%%

%% Make plots...
bm = radial_balance(...
 fmox_flua,...
 cat(3,visc,hybr,b2nxfv,raddiv_flua,raddiv_visc,raddiv_hybr,b2stbc_smo,sum(eirene_mc_mapl_smo,4),...
       sum(eirene_mc_mmpl_smo,4),sum(eirene_mc_mipl_smo,4),sum(eirene_mc_mppl_smo,4),b2stbm_smo,ext_smo,...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smoch,b2sifr_smotf_ehxb,b2sifr_smotf_cthe,b2sifr_smotf_cthi,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2sian_smo,b2nxdv_smo,b2sigp_smogpi,b2sigp_smogpe,b2sigp_smogpgr,b2stbr_phys_smo,b2stbr_bas_smo),...
 resmo,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'parallel convection'},...
 {'parallel viscosity','hybrid correction','b2nxfv','rad. diverg. nmu_{||}u_y','rad. diverg. visc.','rad. diverg. hybr.','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','friction force','b2sifr\_smotf\_ehxb','b2sifr\_smotf\_cthe','b2sifr\_smotf_cthi','b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv\_smo','ion stat. press. gradient','el. stat. press. gradient','pressure gradient restriction','b2stbr\_phys','b2stbr\_bas'},...
 comuse,indrad,area_divide,reverse,true,axbal(1:4),units,true,areaend);
%
% areadownpol = poloidal_balance(...
%  fmox_flua,...
%  cat(3,visc,hybr,b2nxfv,raddiv_flua,raddiv_visc,raddiv_hybr,b2stbc_smo,sum(eirene_mc_mapl_smo,4),...
%        sum(eirene_mc_mmpl_smo,4),sum(eirene_mc_mipl_smo,4),sum(eirene_mc_mppl_smo,4),b2stbm_smo,ext_smo,...
%        b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smoch,b2sifr_smotf_ehxb,b2sifr_smotf_cthe,b2sifr_smotf_cthi,... b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smoch,b2sifr_smotf,...
%        b2siav_smovh,b2siav_smovv,b2sicf_smo,b2sian_smo,b2nxdv_smo,b2sigp_smogpi,b2sigp_smogpe,b2sigp_smogpgr,b2stbr_phys_smo,b2stbr_bas_smo),...%b2siav_smovh,b2siav_smovv,b2sicf_smo,b2nxdv_smo,b2sigp_smogp,b2stbr_phys_smo,b2stbr_bas_smo),...
%  resmo,...
%  {'total radially-integrated flux',...
%   'total radially-integrated source',...
%   'radially-integrated residual'},...
%  {'parallel convection'},...
%  {'parallel viscosity','hybrid correction','b2nxfv','rad. diverg. nmu_{||}u_y','rad. diverg. visc.','rad. diverg. hybr.','b2stbc',...
%   'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
%   'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','friction force','b2sifr\_smotf\_ehxb','b2sifr\_smotf\_cthe','b2sifr\_smotf\_cthi','b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv\_smo','ion stat. press. gradient','el. stat. press. gradient','pressure gradient restriction','b2stbr\_phys','b2stbr\_bas'},...
%  comuse,indpol,area_divide,reverse,true,axbal(5:7),units,areaend,polbaldist);

bm = radial_balance(...
 fmox_tot,...
 cat(3,raddiv_fmotot,tot_smo),...
 resmo,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'total'},...
 {'rad. diverg.','total'},...
 comuse,indrad,area_divide,reverse,true,axbal(1:4),units,true,areaend);

areadownpol = poloidal_balance(...
 fmox_tot,...
 cat(3,raddiv_fmotot,tot_smo),...
 resmo,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'total'},...
 {'rad. diverg.','total'},...
 comuse,indpol,area_divide,reverse,true,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)},{squeeze(eirene_mc_mmpl_smo)},{squeeze(eirene_mc_mipl_smo)},{squeeze(eirene_mc_mppl_smo)},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,bm.areadownrad,areadownpol,reverse,true);
end
%%
end




