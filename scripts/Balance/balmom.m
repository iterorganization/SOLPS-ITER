%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balmom plots the momentum balance for a given SOLPS simulation.              %
% balfile:     Full path to balance.nc file                                    %
% indbal:      Logical matrix of size nx*ny that is true for cells where       %
%              balance should be performed                                     %
% iyplot:      Array of y indices along which poloidal balance will be plotted %
%              (within the volume specified by indbal)                         %
% isplot:      Array of species indices to be plotted. If length(isplot)>1,    %
%              then balance is summed over those species                       %
% comuse:      Structure containing commonly-used variables (from get_comuse)  %
% axbal:       Array of axes into which balance plots will be placed           %
% reverse:     True if the right-most end of the balance volume is upstream of %
%              the left-most end, otherwise false                              %
% strata_plot: If true then divide the EIRENE source into components from each %
%              stratum (in a new figure)                                       %
% axstrat:     Array of axes into which strata plots will be placed            %
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
function balmom(balfile,indrad,indpol,isplot,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fmo_flua');
fmox_flua = sum(sum(tmp(:,:,1,:,isplot),5),3);
fmoy_flua = sum(sum(tmp(:,:,2,:,isplot),5),3);
tmp = ncread(balfile,'fmo_cvsa');
fmox_cvsa = sum(sum(tmp(:,:,1,:,isplot),5),3);
fmoy_cvsa = sum(sum(tmp(:,:,2,:,isplot),5),3);
tmp = ncread(balfile,'fmo_hybr');
fmox_hybr = sum(sum(tmp(:,:,1,:,isplot),5),3);
fmoy_hybr = sum(sum(tmp(:,:,2,:,isplot),5),3);
% Sources:
tmp = ncread(balfile,'b2stbr_phys_smo_bal');
b2stbr_phys_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbr_bas_smo_bal');
b2stbr_bas_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbc_smo_bal');
b2stbc_smo = sum(tmp(:,:,isplot),3);
if (comuse.b2mndr_eirene~=0)
    tmp = ncread(balfile,'eirene_mc_mapl_smo_bal');
    eirene_mc_mapl_smo = sum(tmp(:,:,isplot,:),3);
    tmp = ncread(balfile,'eirene_mc_mmpl_smo_bal');
    eirene_mc_mmpl_smo = sum(tmp(:,:,isplot,:),3);
    tmp = ncread(balfile,'eirene_mc_mipl_smo_bal');
    eirene_mc_mipl_smo = sum(tmp(:,:,isplot,:),3);
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
    eirene_mc_mppl_smo = sum(tmp(:,:,isplot,:),3);
else
    eirene_mc_mapl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mmpl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mipl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mppl_smo = zeros(nx,ny,1,nstra);
end
tmp = ncread(balfile,'b2stbm_smo_bal');
b2stbm_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'ext_smo_bal');
ext_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_smq_ion_bal');
b2stel_smq_ion = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_smq_rec_bal');
b2stel_smq_rec = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stcx_smq_bal');
b2stcx_smq = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srsm_smo_bal');
b2srsm_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srdt_smo_bal');
b2srdt_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srst_smo_bal');
b2srst_smo = sum(tmp(:,:,isplot),3);

% b2sigp_style=='1':
tmp = ncread(balfile,'b2sifr_smoch_bal');
b2sifr_smoch = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_ehxp_bal');
b2sifr_smotf_ehxb = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_cthe_bal');
b2sifr_smotf_cthe = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_cthi_bal');
b2sifr_smotf_cthi = sum(tmp(:,:,isplot),3);
% b2sigp_style=='2':
tmp = ncread(balfile,'b2sifr_smofrea_bal');
b2sifr_smofrea = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smofria_bal');
b2sifr_smofria = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotfea_bal');
b2sifr_smotfea = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotfia_bal');
b2sifr_smotfia = sum(tmp(:,:,isplot),3);

tmp = ncread(balfile,'b2siav_smovh_bal');
b2siav_smovh = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2siav_smovv_bal');
b2siav_smovv = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sicf_smo_bal');
b2sicf_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sian_smo_bal');
b2sian_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2nxdv_smo_bal');
b2nxdv_smo = sum(tmp(:,:,isplot),3);

tmp = ncread(balfile,'b2sigp_smogpi_bal');
b2sigp_smogpi = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sigp_smogpe_bal');
b2sigp_smogpe = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sigp_smogpgr_bal');
b2sigp_smogpgr = sum(tmp(:,:,isplot),3);

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

%% Account for hz
hz = (1-comuse.b2mndr_hz)+comuse.b2mndr_hz*(comuse.dv./comuse.gs(:,:,3));
area_divide = area_divide.*hz;

%% Calculate the radial divergence...
raddiv_flua = zeros(nx,ny);
raddiv_visc = zeros(nx,ny);
raddiv_hybr = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddiv_flua(ix,iy) = fmoy_flua(ix,iy)-fmoy_flua(topix(ix,iy),topiy(ix,iy));
        raddiv_visc(ix,iy) = fmoy_cvsa(ix,iy)-fmoy_cvsa(topix(ix,iy),topiy(ix,iy));
        raddiv_hybr(ix,iy) = fmoy_hybr(ix,iy)-fmoy_hybr(topix(ix,iy),topiy(ix,iy));
    end
end
%%

%% Calculate the poloidal divergence of the viscous, hybrid correction and new ion viscosity form parts...
% visc = zeros(nx,ny);
% hybr = zeros(nx,ny);
% for iy=1:ny
%     for ix=1:nx
%         if rightix(ix,iy)>nx
%             continue;
%         end
%         visc(ix,iy) = fmox_cvsa(ix,iy)-fmox_cvsa(rightix(ix,iy),rightiy(ix,iy));
%         hybr(ix,iy) = fmox_hybr(ix,iy)-fmox_hybr(rightix(ix,iy),rightiy(ix,iy));
%     end
% end
%%

%% Make plots...
bm = radial_balance(...
 cat(3,fmox_flua,fmox_cvsa,fmox_hybr),...
 cat(3,raddiv_flua,raddiv_visc,raddiv_hybr,...
       sum(eirene_mc_mapl_smo,4),sum(eirene_mc_mmpl_smo,4),sum(eirene_mc_mipl_smo,4),sum(eirene_mc_mppl_smo,4),...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,...
       b2sifr_smoch,b2sifr_smotf_ehxb,b2sifr_smotf_cthe,b2sifr_smotf_cthi,...
       b2sifr_smofrea,b2sifr_smofria,b2sifr_smotfea,b2sifr_smotfia,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2sian_smo,b2nxdv_smo,...
       b2sigp_smogpi,b2sigp_smogpe,b2sigp_smogpgr,...
       b2stbr_phys_smo,b2stbr_bas_smo,...
       b2stbm_smo,ext_smo,...
       b2srsm_smo,b2srdt_smo,b2srst_smo,b2stbc_smo),...
 resmo,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'convected','viscous','hybrid'},...
 {'net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'ion-ion friction (b2sigp==1)','thermal force Ehat component (b2sigp==1)','electron thermal force (b2sigp==1)','ion thermal force (b2sigp==1)',...
  'electron-ion friction (b2sigp==2)','ion-ion friction (b2sigp==2)','electron thermal force (b2sigp==2)','ion thermal force (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'ion stat. press. grad.','el. stat.press. grad. (b2sigp==1) or po. grad. (b2sigp==2)','pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc'},...
 comuse,indrad,area_divide,reverse,true,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

areadownpol = poloidal_balance(...
 cat(3,fmox_flua,fmox_cvsa,fmox_hybr),...
 cat(3,raddiv_flua,raddiv_visc,raddiv_hybr,...
       sum(eirene_mc_mapl_smo,4),sum(eirene_mc_mmpl_smo,4),sum(eirene_mc_mipl_smo,4),sum(eirene_mc_mppl_smo,4),...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,...
       b2sifr_smoch,b2sifr_smotf_ehxb,b2sifr_smotf_cthe,b2sifr_smotf_cthi,...
       b2sifr_smofrea,b2sifr_smofria,b2sifr_smotfea,b2sifr_smotfia,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2sian_smo,b2nxdv_smo,...
       b2sigp_smogpi,b2sigp_smogpe,b2sigp_smogpgr,...
       b2stbr_phys_smo,b2stbr_bas_smo,...
       b2stbm_smo,ext_smo,...
       b2srsm_smo,b2srdt_smo,b2srst_smo,b2stbc_smo),...
 resmo,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'convected','viscous','hybrid'},...
 {'net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'ion-ion friction (b2sigp==1)','thermal force Ehat component (b2sigp==1)','electron thermal force (b2sigp==1)','ion thermal force (b2sigp==1)',...
  'electron-ion friction (b2sigp==2)','ion-ion friction (b2sigp==2)','electron thermal force (b2sigp==2)','ion thermal force (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'ion stat. press. grad.','el. stat.press. grad. (b2sigp==1) or po. grad. (b2sigp==2)','pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc'},...
 comuse,indpol,area_divide,reverse,true,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)},{squeeze(eirene_mc_mmpl_smo)},{squeeze(eirene_mc_mipl_smo)},{squeeze(eirene_mc_mppl_smo)},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,bm.area_divide,areadownpol,reverse,true);
end
%%
end




