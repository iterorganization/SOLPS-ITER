%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baltotpress plots the total pressure balance for a given SOLPS simulation.   %
% balfile:     Full path to balance.nc file                                    %
% indbal:      Logical matrix of size nx*ny that is true for cells where       %
%              balance should be performed                                     %
% iyplot:      Array of y indices along which poloidal balance will be plotted %
%              (within the volume specified by indbal)                         %
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
function baltotpress(balfile,indrad,indpol,comuse,axbal,reverse,strata_plot,axstrat)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
za = comuse.za;
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
fmox_flua = sum(tmp(:,:,1,za>0),4);
fmoy_flua = sum(tmp(:,:,2,za>0),4);
tmp = ncread(balfile,'fmo_cvsa');
fmox_cvsa = sum(tmp(:,:,1,za>0),4);
fmoy_cvsa = sum(tmp(:,:,2,za>0),4);
tmp = ncread(balfile,'fmo_b2nxfv');
fmox_b2nxfv = sum(tmp(:,:,1,za>0),4);
fmoy_b2nxfv = sum(tmp(:,:,2,za>0),4);
tmp = ncread(balfile,'b2sigp_pstat_bal');
b2sigp_pstat = sum(tmp(:,:,za>0),3);
% Sources:
tmp = ncread(balfile,'b2stbr_phys_smo_bal');
b2stbr_phys_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2stbr_bas_smo_bal');
b2stbr_bas_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2stbc_smo_bal');
b2stbc_smo = sum(tmp(:,:,za>0),3);
if (comuse.b2mndr_eirene~=0)
    tmp = ncread(balfile,'eirene_mc_mapl_smo_bal');
    eirene_mc_mapl_smo = sum(tmp(:,:,za>0,:),3);
    tmp = ncread(balfile,'eirene_mc_mmpl_smo_bal');
    eirene_mc_mmpl_smo = sum(tmp(:,:,za>0,:),3);
    tmp = ncread(balfile,'eirene_mc_mipl_smo_bal');
    eirene_mc_mipl_smo = sum(tmp(:,:,za>0,:),3);
    tmp = ncread(balfile,'eirene_mc_cppv_smo_bal');
    eirene_mc_cppv_smo = sum(tmp(:,:,za>0,:),3);
else
    eirene_mc_mapl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mmpl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mipl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_cppv_smo = zeros(nx,ny,1,nstra);
end
tmp = ncread(balfile,'b2stbm_smo_bal');
b2stbm_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'ext_smo_bal');
ext_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2stel_smq_ion_bal');
b2stel_smq_ion = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2stel_smq_rec_bal');
b2stel_smq_rec = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2stcx_smq_bal');
b2stcx_smq = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2srsm_smo_bal');
b2srsm_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2srdt_smo_bal');
b2srdt_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2srst_smo_bal');
b2srst_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smoch_bal');
b2sifr_smoch = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smotf_bal');
b2sifr_smotf = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2siav_smovh_bal');
b2siav_smovh = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2siav_smovv_bal');
b2siav_smovv = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sicf_smo_bal');
b2sicf_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2nxdv_smo_bal');
b2nxdv_smo = sum(tmp(:,:,za>0),3);
% Residual:
tmp = ncread(balfile,'resmo');
resmo = sum(tmp(:,:,za>0),3);
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

%% Calculate the stangeby-like geometric term:
geo_smo = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx
            continue;
        end
        geo_smo(ix,iy) = (fmox_flua(ix,iy)-fmox_flua(rightix(ix,iy),rightiy(ix,iy)))-...
                         apll(ix,iy)*(fmox_flua(ix,iy)/apll(ix,iy)-fmox_flua(rightix(ix,iy),rightiy(ix,iy))/apll(rightix(ix,iy),rightiy(ix,iy)));
    end
end
%%

%% Calculate the friction term between species (should sum to zero)
b2sifr_smo = b2sifr_smoch+b2sifr_smotf;
%%

%% Make plots...
areadownrad = radial_balance(...
 cat(3,fmox_flua./apll,b2sigp_pstat./apll),...
 cat(3,visc./apll,raddiv_flua./apll,raddiv_vis./apll,geo_smo./apll,b2stbc_smo./apll,sum(eirene_mc_mapl_smo,4)./apll,...
       sum(eirene_mc_mmpl_smo,4)./apll,sum(eirene_mc_mipl_smo,4)./apll,sum(eirene_mc_cppv_smo,4)./apll,b2stbm_smo./apll,ext_smo./apll,...
       b2stel_smq_ion./apll,b2stel_smq_rec./apll,b2stcx_smq./apll,b2srsm_smo./apll,b2srdt_smo./apll,b2srst_smo./apll,b2sifr_smo./apll,...
       b2siav_smovh./apll,b2siav_smovv./apll,b2sicf_smo./apll,b2nxdv_smo./apll,b2stbr_phys_smo./apll,b2stbr_bas_smo./apll),...
 resmo./apll,...
 {'nmu_{||}^2+n(T_e+T_i) on up. face',...
  'nmu_{||}^2+n(T_e+T_i) on down. face',...
  '\int_d^u(S_{mom}^{tot}+geom\_term)ds_{||}',...
  '\int_d^ures.ds_{||}'},...
 {'nmu_{||}^2','n(T_e+T_i)'},...
 {'parallel viscosity','rad. diverg. nmu_{||} u_y','rad. diverg. visc.','geom\_term','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','b2sifr','b2siav\_smovh','b2siav\_smovv','b2sicf','b2nxdv\_smo','b2stbr\_phys','b2stbr\_bas'},...
 comuse,indrad,ones(size(apll)),reverse,true,axbal(1:4),'Nm^{-2}');

areadownpol = poloidal_balance(...
 cat(3,fmox_flua./apll,b2sigp_pstat./apll),...
 cat(3,visc./apll,raddiv_flua./apll,raddiv_vis./apll,geo_smo./apll,b2stbc_smo./apll,sum(eirene_mc_mapl_smo,4)./apll,...
       sum(eirene_mc_mmpl_smo,4)./apll,sum(eirene_mc_mipl_smo,4)./apll,sum(eirene_mc_cppv_smo,4)./apll,b2stbm_smo./apll,ext_smo./apll,...
       b2stel_smq_ion./apll,b2stel_smq_rec./apll,b2stcx_smq./apll,b2srsm_smo./apll,b2srdt_smo./apll,b2srst_smo./apll,b2sifr_smo./apll,...
       b2siav_smovh./apll,b2siav_smovv./apll,b2sicf_smo./apll,b2nxdv_smo./apll,b2stbr_phys_smo./apll,b2stbr_bas_smo./apll),...
 resmo./apll,...
 {'nmu_{||}^2+n(T_e+T_i)',...
  '(S_{mom}^{tot}+geom\_term)ds_{||}',...
  'res.ds_{||}'},...
 {'nmu_{||}^2','n(T_e+T_i)'},...
 {'parallel viscosity','rad. diverg. nmu_{||} u_y','rad. diverg. visc.','geom\_term','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','b2sifr','b2siav\_smovh','b2siav\_smovv','b2sicf','b2nxdv\_smo','b2stbr\_phys','b2stbr\_bas'},...
 comuse,indpol,ones(size(apll)),reverse,true,axbal(5:7),'Nm^{-2}');

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)./repmat(apll,[1,1,size(eirene_mc_mapl_smo,4)])},...
                      {squeeze(eirene_mc_mmpl_smo)./repmat(apll,[1,1,size(eirene_mc_mmpl_smo,4)])},...
                      {squeeze(eirene_mc_mipl_smo)./repmat(apll,[1,1,size(eirene_mc_mipl_smo,4)])},...
                      {squeeze(eirene_mc_cppv_smo)./repmat(apll,[1,1,size(eirene_mc_cppv_smo,4)])},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,true);
end    
%%
end




