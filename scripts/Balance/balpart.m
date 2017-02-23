%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balpart plots the particle balance for a given SOLPS simulation.             %
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
function balpart(balfile,indrad,indpol,isplot,comuse,axbal,reverse,strata_plot,axstrat)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
leftix = comuse.leftix+1;  % Convert to one-based
leftiy = comuse.leftiy+1;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

dv = comuse.dv; % Cell vol.
hx = comuse.hx; % hx
B = comuse.bb; % Mag. field

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fna_pinch');
fnbx_pinch = sum(tmp(:,:,1,isplot),4);
fnby_pinch = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fna_pll');
fnbx_pll = sum(tmp(:,:,1,isplot),4);
fnby_pll = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fna_drift');
fnbx_drift = sum(tmp(:,:,1,isplot),4);
fnby_drift = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fna_ch');
fnbx_ch = sum(tmp(:,:,1,isplot),4);
fnby_ch = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fna_nanom');
fnbx_nanom = sum(tmp(:,:,1,isplot),4);
fnby_nanom = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fna_panom');
fnbx_panom = sum(tmp(:,:,1,isplot),4);
fnby_panom = sum(tmp(:,:,2,isplot),4);
tmp = ncread(balfile,'fna_pschused');
fnbx_pschused = sum(tmp(:,:,1,isplot),4);
fnby_pschused = sum(tmp(:,:,2,isplot),4);
% Sources:
tmp = ncread(balfile,'b2stbr_sna_bal');
b2stbr_sna = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbc_sna_bal');
b2stbc_sna = sum(tmp(:,:,isplot),3);
if (comuse.b2mndr_eirene~=0)
    tmp = ncread(balfile,'eirene_mc_papl_sna_bal');
    eirene_mc_papl_sna = sum(tmp(:,:,isplot,:),3);
    tmp = ncread(balfile,'eirene_mc_pmpl_sna_bal');
    eirene_mc_pmpl_sna = sum(tmp(:,:,isplot,:),3);
    tmp = ncread(balfile,'eirene_mc_pipl_sna_bal');
    eirene_mc_pipl_sna = sum(tmp(:,:,isplot,:),3);
    tmp = ncread(balfile,'eirene_mc_pppl_sna_bal');
    eirene_mc_pppl_sna = sum(tmp(:,:,isplot,:),3);
    tmp = ncread(balfile,'eirene_mc_core_sna_bal');
    eirene_mc_core_sna = sum(tmp(:,:,isplot),3);
else
    eirene_mc_papl_sna = zeros(nx,ny,1,nstra);
    eirene_mc_pmpl_sna = zeros(nx,ny,1,nstra);
    eirene_mc_pipl_sna = zeros(nx,ny,1,nstra);
    eirene_mc_pppl_sna = zeros(nx,ny,1,nstra);
    eirene_mc_core_sna = zeros(nx,ny,1,nstra);
end
tmp = ncread(balfile,'b2stbm_sna_bal');
b2stbm_sna = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'ext_sna_bal');
ext_sna = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_sna_ion_bal');
b2stel_sna_ion = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_sna_rec_bal');
b2stel_sna_rec = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stcx_sna_bal');
b2stcx_sna = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srsm_sna_bal');
b2srsm_sna = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srdt_sna_bal');
b2srdt_sna = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srst_sna_bal');
b2srst_sna = sum(tmp(:,:,isplot),3);
% Residual:    
tmp = ncread(balfile,'resco');
rescb = sum(tmp(:,:,isplot),3);
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
raddiv_pinch = zeros(nx,ny);
raddiv_pll = zeros(nx,ny);
raddiv_drift = zeros(nx,ny);
raddiv_nanom = zeros(nx,ny);
raddiv_panom = zeros(nx,ny);
raddiv_ch = zeros(nx,ny);
raddiv_pschused = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddiv_pinch(ix,iy) = fnby_pinch(ix,iy)-fnby_pinch(topix(ix,iy),topiy(ix,iy));
        raddiv_pll(ix,iy) = fnby_pll(ix,iy)-fnby_pll(topix(ix,iy),topiy(ix,iy));
        raddiv_drift(ix,iy) = fnby_drift(ix,iy)-fnby_drift(topix(ix,iy),topiy(ix,iy));
        raddiv_nanom(ix,iy) = fnby_nanom(ix,iy)-fnby_nanom(topix(ix,iy),topiy(ix,iy));
        raddiv_panom(ix,iy) = fnby_panom(ix,iy)-fnby_panom(topix(ix,iy),topiy(ix,iy));
        raddiv_ch(ix,iy) = fnby_ch(ix,iy)-fnby_ch(topix(ix,iy),topiy(ix,iy));
        raddiv_pschused(ix,iy) = fnby_pschused(ix,iy)-fnby_pschused(topix(ix,iy),topiy(ix,iy));                    
    end
end
%%

%% B2STBR part not from Eirene...
b2stbr_not_eirene = b2stbr_sna-(sum(eirene_mc_papl_sna,4)+sum(eirene_mc_pmpl_sna,4)+...
                                sum(eirene_mc_pipl_sna,4)+sum(eirene_mc_pppl_sna,4)+...
                                eirene_mc_core_sna);
%%

%% Make plots...
areadownrad = radial_balance(...
 cat(3,fnbx_pll,fnbx_drift,fnbx_nanom,fnbx_panom,fnbx_pinch,fnbx_ch,fnbx_pschused),...
 cat(3,raddiv_drift,raddiv_pll,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_papl_sna,4),sum(eirene_mc_pmpl_sna,4),sum(eirene_mc_pipl_sna,4),sum(eirene_mc_pppl_sna,4),eirene_mc_core_sna,...
       b2stel_sna_ion,b2stel_sna_rec,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna,b2stbr_not_eirene),...
 rescb,...
 {'$dA_{xu}\Gamma_{xu}/dA_{\parallel d}$',...
  '$\Gamma_{\parallel d}$',...
  '$\left(\int_d^u S_{\rm{part}}^{\rm{tot}}dV\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u {\rm{res.}}dV\right)/dA_{\parallel d}$'},...
 {'poloidal projection of $nv_{||}$','drift component','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnbx\_ch','Pfirsch-Schl\"{u}ter'},...
 {'rad. drift diverg.','rad. diverg. $nv_{||}$','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion','b2stel rec','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst','b2stbr not Eirene'},...
 comuse,indrad,apllx,reverse,false,axbal(1:4),'m$^{-2}$s$^{-1}$');

areadownpol = poloidal_balance(...
 cat(3,fnbx_pll,fnbx_drift,fnbx_nanom,fnbx_panom,fnbx_pinch,fnbx_ch,fnbx_pschused),...
 cat(3,raddiv_drift,raddiv_pll,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_papl_sna,4),sum(eirene_mc_pmpl_sna,4),sum(eirene_mc_pipl_sna,4),sum(eirene_mc_pppl_sna,4),eirene_mc_core_sna,...
       b2stel_sna_ion,b2stel_sna_rec,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna,b2stbr_not_eirene),...
 rescb,...
 {'$dA_x\Gamma_x/dA_{\parallel d}$',...
  '$S_{\rm{part}}^{\rm{tot}}dV/dA_{\parallel d}$',...
  '${\rm{res.}}dV/dA_{\parallel d}$'},...
 {'poloidal projection of $nv_{||}$','dia.+E$\times$B drifts','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnbx_ch','PS'},...
 {'rad. drift diverg.','rad. diverg. $nv_{||}$','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion','b2stel rec','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst','b2stbr not Eirene'},...
 comuse,indpol,apllx,reverse,false,axbal(5:7),'m$^{-2}$s$^{-1}$');

if strata_plot
    make_strata_plots({squeeze(eirene_mc_papl_sna)},{squeeze(eirene_mc_pmpl_sna)},{squeeze(eirene_mc_pipl_sna)},{squeeze(eirene_mc_pppl_sna)},...
                      {'Strata decomp. of $\left(\int_d^u S_{\rm{part}}^{\rm{EIR}}dV\right)/dA_{\parallel d}$ in radial direction',...
                       'Strata decomp. of $S_{\rm{part}}^{\rm{EIR}}dV/dA_{\parallel d}$ in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,false);
end              
%%
end




