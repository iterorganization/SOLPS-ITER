%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balmom plots the momentum balance for a given SOLPS simulation.              %
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
% makeplot:    Decides whether to make plots or just pass back the values in   %
%              the radial balance plots                                        %
% areaend:     Either 'left', 'right' or 'none'. Defines the poloidal end      %
%              of the balance region at which areas will be calculated. The    %
%              poloidal fluxes at both ends will then be divided by these      %
%              areas to give flux densities.                                   %
% area_divide: The area that poloidal fluxes and sources are divided by        %
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function baltotpress(balfile,indrad,indpol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,polbaldist)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
topix = comuse.topix+1;
topiy = comuse.topiy+1;
leftix = comuse.leftix+1;
leftiy = comuse.leftiy+1;
rightix = comuse.rightix+1;
rightiy = comuse.rightiy+1;
za = comuse.za;
dv = comuse.dv; % Cell vol.
hx = comuse.hx; % hx
gs = comuse.gs; % gs
B = comuse.bb; % Mag. field

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fmo_flua');
fmox_flua = sum(tmp(:,:,1,za>0),4);
fmoy_flua = sum(tmp(:,:,2,za>0),4);
tmp = ncread(balfile,'fmo_cvsa');
fmox_cvsa = sum(tmp(:,:,1,za>0),4);
fmoy_cvsa = sum(tmp(:,:,2,za>0),4);
tmp = ncread(balfile,'fmo_hybr');
fmox_hybr = sum(tmp(:,:,1,za>0),4);
fmoy_hybr = sum(tmp(:,:,2,za>0),4);
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
    eirene_mc_mppl_smo = sum(tmp(:,:,za>0,:),3);
else
    eirene_mc_mapl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mmpl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mipl_smo = zeros(nx,ny,1,nstra);
    eirene_mc_mppl_smo = zeros(nx,ny,1,nstra);
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

% b2sigp_style=='1':
tmp = ncread(balfile,'b2sifr_smoch_bal');
b2sifr_smoch = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smotf_ehxp_bal');
b2sifr_smotf_ehxb = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smotf_cthe_bal');
b2sifr_smotf_cthe = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smotf_cthi_bal');
b2sifr_smotf_cthi = sum(tmp(:,:,za>0),3);
% b2sigp_style=='2':
tmp = ncread(balfile,'b2sifr_smofrea_bal');
b2sifr_smofrea = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smofria_bal');
b2sifr_smofria = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smotfea_bal');
b2sifr_smotfea = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sifr_smotfia_bal');
b2sifr_smotfia = sum(tmp(:,:,za>0),3);

tmp = ncread(balfile,'b2siav_smovh_bal');
b2siav_smovh = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2siav_smovv_bal');
b2siav_smovv = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sicf_smo_bal');
b2sicf_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sian_smo_bal');
b2sian_smo = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2nxdv_smo_bal');
b2nxdv_smo = sum(tmp(:,:,za>0),3);

tmp = ncread(balfile,'b2sigp_smogpi_bal');
b2sigp_smogpi = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sigp_smogpe_bal');
b2sigp_smogpe = sum(tmp(:,:,za>0),3);
tmp = ncread(balfile,'b2sigp_smogpgr_bal');
b2sigp_smogpgr = sum(tmp(:,:,za>0),3);

% Residual:
tmp = ncread(balfile,'resmo');
resmo = sum(tmp(:,:,za>0),3);
%%

%% Parallel area at cell centres:
hz = (1-comuse.b2mndr_hz)+comuse.b2mndr_hz*(dv./gs(:,:,3));
apll = dv.*hz./hx.*abs(B(:,:,1)./B(:,:,4));
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
apllc = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx
            continue;
        end
        apllc(ix,iy) = 0.5*(apllx(ix,iy)+apllx(rightix(ix,iy),rightiy(ix,iy)));
    end
end
%%

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
visc = zeros(nx,ny);
hybr = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx
            continue;
        end
        visc(ix,iy) = fmox_cvsa(ix,iy)-fmox_cvsa(rightix(ix,iy),rightiy(ix,iy));
        hybr(ix,iy) = fmox_hybr(ix,iy)-fmox_hybr(rightix(ix,iy),rightiy(ix,iy));
    end
end
%%

%% Calculate the geometric term...
geomterm = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx
            continue;
        end
        geomterm(ix,iy) = 0.5*(fmox_flua(ix,iy)/apllx(ix,iy)+...
                                fmox_flua(rightix(ix,iy),rightiy(ix,iy))/apllx(rightix(ix,iy),rightiy(ix,iy)))*...
                           (apllx(ix,iy)-apllx(rightix(ix,iy),rightiy(ix,iy)));
    end
end
%%

%% Calculate the static pressure on poloidal cell faces...
ne = ncread(balfile,'ne');
te = ncread(balfile,'te');
na = ncread(balfile,'na');
ti = ncread(balfile,'ti');
pe = ne.*te;
pi = ti.*sum(na(:,:,za>0),3);
pex = zeros(nx,ny);
pex(end,:) = -pe(end,:);
pix = zeros(nx,ny);
pix(end,:) = -pi(end,:);
for iy=1:ny
    ix = nx-1;
    while true
        pex(ix,iy) = pex(rightix(ix,iy),rightiy(ix,iy))+b2sigp_smogpe(ix,iy)/apllc(ix,iy);
        pix(ix,iy) = pix(rightix(ix,iy),rightiy(ix,iy))+b2sigp_smogpi(ix,iy)/apllc(ix,iy);
        ix = leftix(ix,iy);
        if ix<1
            break;
        end
    end
end
%%

%% Make plots...
bm = radial_balance(...
 cat(3,fmox_flua./apllx,pex,pix),...
 cat(3,visc./apllc,hybr./apllc,raddiv_flua./apllc,raddiv_visc./apllc,raddiv_hybr./apllc,...
       sum(eirene_mc_mapl_smo,4)./apllc,sum(eirene_mc_mmpl_smo,4)./apllc,sum(eirene_mc_mipl_smo,4)./apllc,sum(eirene_mc_mppl_smo,4)./apllc,...
       b2stel_smq_ion./apllc,b2stel_smq_rec./apllc,b2stcx_smq./apllc,...
       b2sifr_smoch./apllc+b2sifr_smotf_ehxb./apllc+b2sifr_smotf_cthe./apllc+b2sifr_smotf_cthi./apllc,...
       b2sifr_smofrea./apllc+b2sifr_smofria./apllc+b2sifr_smotfea./apllc+b2sifr_smotfia./apllc,...
       b2siav_smovh./apllc,b2siav_smovv./apllc,b2sicf_smo./apllc,b2sian_smo./apllc,b2nxdv_smo./apllc,...
       b2sigp_smogpgr./apllc,...
       b2stbr_phys_smo./apllc,b2stbr_bas_smo./apllc,...
       b2stbm_smo./apllc,ext_smo./apllc,...
       b2srsm_smo./apllc,b2srdt_smo./apllc,b2srst_smo./apllc,b2stbc_smo./apllc,geomterm./apllc),...
 resmo./apllc,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'convected','electron static','ion static'},...
 {'viscous','hybrid','net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'sum b2sifr (b2sigp==1)',...
  'sum b2sifr (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc','geometric term'},...
 comuse,indrad,ones(nx,ny),reverse,true,axbal(1:4),'Nm^{-2}',makeplot,'right');

if ~makeplot
    return
end

areadownpol = poloidal_balance(...
 cat(3,fmox_flua./apllx,pex,pix),...
 cat(3,visc./apllc,hybr./apllc,raddiv_flua./apllc,raddiv_visc./apllc,raddiv_hybr./apllc,...
       sum(eirene_mc_mapl_smo,4)./apllc,sum(eirene_mc_mmpl_smo,4)./apllc,sum(eirene_mc_mipl_smo,4)./apllc,sum(eirene_mc_mppl_smo,4)./apllc,...
       b2stel_smq_ion./apllc,b2stel_smq_rec./apllc,b2stcx_smq./apllc,...
       b2sifr_smoch./apllc+b2sifr_smotf_ehxb./apllc+b2sifr_smotf_cthe./apllc+b2sifr_smotf_cthi./apllc,...
       b2sifr_smofrea./apllc+b2sifr_smofria./apllc+b2sifr_smotfea./apllc+b2sifr_smotfia./apllc,...
       b2siav_smovh./apllc,b2siav_smovv./apllc,b2sicf_smo./apllc,b2sian_smo./apllc,b2nxdv_smo./apllc,...
       b2sigp_smogpgr./apllc,...
       b2stbr_phys_smo./apllc,b2stbr_bas_smo./apllc,...
       b2stbm_smo./apllc,ext_smo./apllc,...
       b2srsm_smo./apllc,b2srdt_smo./apllc,b2srst_smo./apllc,b2stbc_smo./apllc,geomterm./apllc),...
 resmo./apllc,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'convected','electron static','ion static'},...
 {'viscous','hybrid','net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'sum b2sifr (b2sigp==1)',...
  'sum b2sifr (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc','geometric term'},...
 comuse,indpol,ones(nx,ny),reverse,true,axbal(5:7),'Nm^{-2}','right',polbaldist);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)},{squeeze(eirene_mc_mmpl_smo)},{squeeze(eirene_mc_mipl_smo)},{squeeze(eirene_mc_mppl_smo)},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,bm.area_divide,areadownpol,reverse,true);
end    
%%
end




