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
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function balmom(balfile,indrad,indpol,isplot,comuse,axbal,reverse,strata_plot,axstrat)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
leftix = comuse.leftix+1;  % Convert to one-based
leftiy = comuse.leftiy+1;
rightix = comuse.rightix+1;
rightiy = comuse.rightiy+1;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

dv = comuse.dv; % Cell vol.
hx = comuse.hx; % hx
B = comuse.bb; % Mag. field

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fmo_flua');
fmox_flua = sum(tmp(:,:,1,isplot),4);
fmoy_flua = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fmo_cvsa');
fmox_cvsa = sum(tmp(:,:,1,isplot),4);
fmoy_cvsa = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fmo_b2nxfv');
fmox_b2nxfv = sum(tmp(:,:,1,isplot),4);
fmoy_b2nxfv = sum(tmp(:,:,2,isplot),4);
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
    tmp = ncread(balfile,'eirene_mc_cppv_smo_bal');
    eirene_mc_cppv_smo = sum(tmp(:,:,isplot,:),3);
else
    eirene_mc_mapl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mmpl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mipl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_cppv_smo = zeros(nx,ny,1,nstra);
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
tmp = ncread(balfile,'b2sifr_smoch_bal');
b2sifr_smoch = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sifr_smotf_bal');
b2sifr_smotf = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2siav_smovh_bal');
b2siav_smovh = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2siav_smovv_bal');
b2siav_smovv = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sicf_smo_bal');
b2sicf_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2nxdv_smo_bal');
b2nxdv_smo = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2sigp_smogp_bal');
b2sigp_smogp = sum(tmp(:,:,isplot),3);
% Residual:
tmp = ncread(balfile,'resmo');
resmo = sum(tmp(:,:,isplot),3);
%%

%% Parallel area at cell centres...
apll = dv./hx.*abs(B(:,:,1)./B(:,:,4));
% Map to left cell face:
apllx = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if leftix(ix,iy)<1
            continue;
        end
        apllx(ix,iy) = (apll(leftix(ix,iy),leftiy(ix,iy))*dv(ix,iy)+...
                        apll(ix,iy)*dv(leftix(ix,iy),leftiy(ix,iy)))/...
                       (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)));
    end
end

%% Calculate the radial divergence...
raddiv_flua = zeros(nx,ny);
raddiv_vis = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddiv_flua(ix,iy) = fmoy_flua(ix,iy)-fmoy_flua(topix(ix,iy),topiy(ix,iy));
        raddiv_vis(ix,iy) = (fmoy_cvsa(ix,iy)+fmoy_b2nxfv(ix,iy))-...
                            (fmoy_cvsa(topix(ix,iy),topiy(ix,iy))+fmoy_b2nxfv(topix(ix,iy),topiy(ix,iy)));
    end
end
%%

%% Calculate the poloidal divergence of the viscous part...
visc = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx
            continue;
        end
        visc(ix,iy) = (fmox_cvsa(ix,iy)+fmox_b2nxfv(ix,iy))-...
                        (fmox_cvsa(rightix(ix,iy),rightiy(ix,iy))+fmox_b2nxfv(rightix(ix,iy),rightiy(ix,iy)));
    end
end
%%

%% Calculate the friction term between species (should sum to zero)
b2sifr_smo = b2sifr_smoch+b2sifr_smotf;
%%

%% Make plots...
areadownrad = radial_balance(...
 fmox_flua,...
 cat(3,visc,raddiv_flua,raddiv_vis,b2stbc_smo,sum(eirene_mc_mapl_smo,4),...
       sum(eirene_mc_mmpl_smo,4),sum(eirene_mc_mipl_smo,4),sum(eirene_mc_cppv_smo,4),b2stbm_smo,ext_smo,...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smo,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2nxdv_smo,b2sigp_smogp,b2stbr_phys_smo,b2stbr_bas_smo),...      
 resmo,...
 {'dA_{xu}n_umu_{||u}u_{xu}/dA_{||d}',...
  'n_dmu_{||d}^2',...
  '(\int_d^uS_{mom}^{tot}dV)/dA_{||d}',...
  '(\int_d^ures.dV)/dA_{||d}'},...
 {'nmu_{||}^2'},...
 {'parallel viscosity','rad. diverg. nmu_{||}u_y','rad. diverg. visc.','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','b2sifr','b2siav\_smovh','b2siav\_smovv','b2sicf','b2nxdv\_smo','stat. press. gradient','b2stbr\_phys','b2stbr\_bas'},...
 comuse,indrad,apllx,reverse,true,axbal(1:4),'Nm^{-2}');

areadownpol = poloidal_balance(...
 fmox_flua,...
 cat(3,visc,raddiv_flua,raddiv_vis,b2stbc_smo,sum(eirene_mc_mapl_smo,4),...
       sum(eirene_mc_mmpl_smo,4),sum(eirene_mc_mipl_smo,4),sum(eirene_mc_cppv_smo,4),b2stbm_smo,ext_smo,...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smo,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2nxdv_smo,b2sigp_smogp,b2stbr_phys_smo,b2stbr_bas_smo),...  
 resmo,...
 {'dA_xnmu_{||}u_x/dA_{||d}',...
  'S_{mom}^{tot}dV/dA_{||d}',...
  'res.dV/dA_{||d}'},...
 {'nmu_{||}^2'},...
 {'parallel viscosity','rad. diverg. nmu_{||}u_y','rad. diverg. visc.','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','b2sifr','b2siav\_smovh','b2siav\_smovv','b2sicf','b2nxdv\_smo','stat. press. gradient','b2stbr\_phys','b2stbr\_bas'},...
 comuse,indpol,apllx,reverse,true,axbal(5:7),'Nm^{-2}');

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)},{squeeze(eirene_mc_mmpl_smo)},{squeeze(eirene_mc_mipl_smo)},{squeeze(eirene_mc_cppv_smo)},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,true);
end    
%%
end




