%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balien plots the ion internal energy balance for a given SOLPS simulation.   %
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
function baliht(balfile,indrad,indpol,comuse,axbal,reverse,strata_plot,axstrat)

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
tmp = ncread(balfile,'fhi_32');
fhix_32 = tmp(:,:,1);
fhiy_32 = tmp(:,:,2);
tmp = ncread(balfile,'fhi_52');
fhix_52 = tmp(:,:,1);
fhiy_52 = tmp(:,:,2);
tmp = ncread(balfile,'fhi_cond');
fhix_cond = tmp(:,:,1);
fhiy_cond = tmp(:,:,2);
tmp = ncread(balfile,'fhi_dia');
fhix_dia = tmp(:,:,1);
fhiy_dia = tmp(:,:,2);
tmp = ncread(balfile,'fhi_ecrb');
fhix_ecrb = tmp(:,:,1);
fhiy_ecrb = tmp(:,:,2);
tmp = ncread(balfile,'fhi_strange');
fhix_strange = tmp(:,:,1);
fhiy_strange = tmp(:,:,2);
tmp = ncread(balfile,'fhi_pschused');
fhix_pschused = tmp(:,:,1);
fhiy_pschused = tmp(:,:,2);
tmp = ncread(balfile,'fhi_inert');
fhix_inert = tmp(:,:,1);
fhiy_inert = tmp(:,:,2);
tmp = ncread(balfile,'fhi_vispar');
fhix_vispar = tmp(:,:,1);
fhiy_vispar = tmp(:,:,2);
tmp = ncread(balfile,'fhi_anml');
fhix_anml = tmp(:,:,1);
fhiy_anml = tmp(:,:,2);
tmp = ncread(balfile,'fhi_kevis');
fhix_kevis = tmp(:,:,1);
fhiy_kevis = tmp(:,:,2);
% Sources:
b2stbr_shi = ncread(balfile,'b2stbr_shi_bal');
b2stbc_shi = ncread(balfile,'b2stbc_shi_bal');
if (comuse.b2mndr_eirene~=0)
    eirene_mc_eapl_shi = ncread(balfile,'eirene_mc_eapl_shi_bal');
    eirene_mc_empl_shi = ncread(balfile,'eirene_mc_empl_shi_bal');
    eirene_mc_eipl_shi = ncread(balfile,'eirene_mc_eipl_shi_bal');
    eirene_mc_eppl_shi = ncread(balfile,'eirene_mc_eppl_shi_bal');
else
    eirene_mc_eapl_shi = zeros(nx,ny,nstra);
    eirene_mc_empl_shi = zeros(nx,ny,nstra);
    eirene_mc_eipl_shi = zeros(nx,ny,nstra);
    eirene_mc_eppl_shi = zeros(nx,ny,nstra);
end
b2stbm_shi = ncread(balfile,'b2stbm_shi_bal');
ext_shi = ncread(balfile,'ext_shi_bal');
b2stel_shi_ion = ncread(balfile,'b2stel_shi_ion_bal');
b2stel_shi_rec = ncread(balfile,'b2stel_shi_rec_bal');
b2stcx_shi = ncread(balfile,'b2stcx_shi_bal');
b2srsm_shi = ncread(balfile,'b2srsm_shi_bal');
b2srdt_shi = ncread(balfile,'b2srdt_shi_bal');
b2srst_shi = ncread(balfile,'b2srst_shi_bal');
b2sihs_diaa = ncread(balfile,'b2sihs_diaa_bal');
b2sihs_divua = ncread(balfile,'b2sihs_divua_bal');
b2sihs_exba = ncread(balfile,'b2sihs_exba_bal');
b2sihs_visa = ncread(balfile,'b2sihs_visa_bal');
b2sihs_fraa = ncread(balfile,'b2sihs_fraa_bal');
b2npht_shei = ncread(balfile,'b2npht_shei_bal');
% Residual:
reshi = ncread(balfile,'reshi');
%%

%% Parallel area at left edges:
apll = dv./hx.*abs(B(:,:,1)./B(:,:,4));
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
%%

%% Radial divergences...
raddivi_32 = zeros(nx,ny);
raddivi_52 = zeros(nx,ny);
raddivi_cond = zeros(nx,ny);
raddivi_dia = zeros(nx,ny);
raddivi_ecrb = zeros(nx,ny);
raddivi_strange = zeros(nx,ny);
raddivi_pschused = zeros(nx,ny);
raddivi_inert = zeros(nx,ny);
raddivi_vispar = zeros(nx,ny);
raddivi_anml = zeros(nx,ny);
raddivi_kevis = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddivi_32(ix,iy) = fhiy_32(ix,iy)-fhiy_32(topix(ix,iy),topiy(ix,iy));
        raddivi_52(ix,iy) = fhiy_52(ix,iy)-fhiy_52(topix(ix,iy),topiy(ix,iy));
        raddivi_cond(ix,iy) = fhiy_cond(ix,iy)-fhiy_cond(topix(ix,iy),topiy(ix,iy));
        raddivi_dia(ix,iy) = fhiy_dia(ix,iy)-fhiy_dia(topix(ix,iy),topiy(ix,iy));
        raddivi_ecrb(ix,iy) = fhiy_ecrb(ix,iy)-fhiy_ecrb(topix(ix,iy),topiy(ix,iy));
        raddivi_strange(ix,iy) = fhiy_strange(ix,iy)-fhiy_strange(topix(ix,iy),topiy(ix,iy));
        raddivi_pschused(ix,iy) = fhiy_pschused(ix,iy)-fhiy_pschused(topix(ix,iy),topiy(ix,iy));
        raddivi_inert(ix,iy) = fhiy_inert(ix,iy)-fhiy_inert(topix(ix,iy),topiy(ix,iy));
        raddivi_vispar(ix,iy) = fhiy_vispar(ix,iy)-fhiy_vispar(topix(ix,iy),topiy(ix,iy));
        raddivi_anml(ix,iy) = fhiy_anml(ix,iy)-fhiy_anml(topix(ix,iy),topiy(ix,iy));
        raddivi_kevis(ix,iy) = fhiy_kevis(ix,iy)-fhiy_kevis(topix(ix,iy),topiy(ix,iy));
    end
end
%%

%% B2STBR part not from Eirene...
b2stbr_not_eirene = b2stbr_shi-(sum(eirene_mc_eapl_shi,3)+sum(eirene_mc_empl_shi,3)+...
                                sum(eirene_mc_eipl_shi,3)+sum(eirene_mc_eppl_shi,3));
%%

%% Make plots...
areadownrad = radial_balance(...
 cat(3,fhix_32,fhix_52,fhix_cond,fhix_dia,fhix_ecrb,fhix_strange,fhix_pschused,...
       fhix_inert,fhix_vispar,fhix_anml,fhix_kevis)/1E6,...
 cat(3,raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,...
       raddivi_inert,raddivi_vispar,raddivi_anml,raddivi_kevis,b2stbc_shi,...
       sum(eirene_mc_eapl_shi,3),sum(eirene_mc_empl_shi,3),sum(eirene_mc_eipl_shi,3),sum(eirene_mc_eppl_shi,3),...
       b2stbm_shi,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_shi,b2srdt_shi,b2srst_shi,...
       b2sihs_diaa,b2sihs_divua,b2sihs_exba,b2sihs_visa,b2sihs_fraa,b2npht_shei,b2stbr_not_eirene)/1E6,...
 reshi/1E6,...
 {'$dA_{xu}\tilde q_{ixu}/dA_{\parallel d}$',...
  '$dA_{xd}\tilde q_{ixd}/dA_{\parallel d}$',...
  '$\left(\int_d^u S_{\rm{IE}}^idV\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u {\rm{res.}}dV\right)/dA_{\parallel d}$'},...
 {'fhix\_32','fhix\_52','fhix\_cond','fhix\_dia','fhix\_ecrb','fhix\_strange','fhix\_pschused',...
  'fhix\_inert','fhix\_vispar','fhix\_anml','fhix\_kevis'},...
 {'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond','rad. diverg. fhiy\_dia',...
  'rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch',...
  'rad. diverg. fhiy\_inert','rad. diverg. fhiy\_vispar','rad. diverg. fhiy\_anml','rad. diverg. fhiy\_kevis','b2stbc\_shi',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_shi','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_shi','b2srdt\_shi','b2srst\_shi',...
  'b2sihs\_diaa','b2sihs\_divua','b2sihs\_exba','b2sihs\_visa','b2sihs\_fraa','equipartition','b2stbr not Eirene'},...
 comuse,indrad,apllx,reverse,false,axbal(1:4),'MWm$^{-2}$');

areadownpol = poloidal_balance(...
 cat(3,fhix_32,fhix_52,fhix_cond,fhix_dia,fhix_ecrb,fhix_strange,fhix_pschused,...
       fhix_inert,fhix_vispar,fhix_anml,fhix_kevis)/1E6,...
 cat(3,raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,...
       raddivi_inert,raddivi_vispar,raddivi_anml,raddivi_kevis,b2stbc_shi,...
       sum(eirene_mc_eapl_shi,3),sum(eirene_mc_empl_shi,3),sum(eirene_mc_eipl_shi,3),sum(eirene_mc_eppl_shi,3),...
       b2stbm_shi,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_shi,b2srdt_shi,b2srst_shi,...
       b2sihs_diaa,b2sihs_divua,b2sihs_exba,b2sihs_visa,b2sihs_fraa,b2npht_shei,b2stbr_not_eirene)/1E6,...
 reshi/1E6,...
 {'$dA_x\tilde q_{ix}/dA_{\parallel d}$',...
  '$S_{\rm{IE}}^idV/dA_{\parallel d}$',...
  '${\rm{res.}}dV/dA_{\parallel d}$'},...
 {'fhix\_32','fhix\_52','fhix\_cond','fhix\_dia','fhix\_ecrb','fhix\_strange','fhix\_pschused',...
  'fhix\_inert','fhix\_vispar','fhix\_anml','fhix\_kevis'},...
 {'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond','rad. diverg. fhiy\_dia',...
  'rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch',...
  'rad. diverg. fhiy\_inert','rad. diverg. fhiy\_vispar','rad. diverg. fhiy\_anml','rad. diverg. fhiy\_kevis','b2stbc\_shi',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_shi','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_shi','b2srdt\_shi','b2srst\_shi',...
  'b2sihs\_diaa','b2sihs\_divua','b2sihs\_exba','b2sihs\_visa','b2sihs\_fraa','equipartition','b2stbr not Eirene'},...
 comuse,indpol,apllx,reverse,false,axbal(5:7),'MWm$^{-2}$');

if strata_plot
    make_strata_plots({eirene_mc_eapl_shi/1E6},{eirene_mc_empl_shi/1E6},{eirene_mc_eipl_shi/1E6},{eirene_mc_eppl_shi/1E6},...
                      {'Strata decomp. of $\left(\int_d^u S_{i\rm{IE}}^{\rm{EIR}}dV\right)/dA_{\parallel d}$ in radial direction',...
                       'Strata decomp. of $S_{i\rm{IE}}^{\rm{EIR}}dV/dA_{\parallel d}$ in poloidal direction'},...
                      {'el','ion'},comuse,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,false);
end              
%%
end




