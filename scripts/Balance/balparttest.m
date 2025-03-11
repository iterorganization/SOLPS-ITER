%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balpart plots the particle balance for a given SOLPS simulation.             %
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
function btn = balparttest(balfile,indrad,indpol,isplot,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fna_tot');
fnbx_tot = sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_pinch');
fnbx_tot_compare = sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_pll');
fnbx_tot_compare = fnbx_tot_compare+sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_drift');
fnbx_tot_compare = fnbx_tot_compare+sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_ch');
fnbx_tot_compare = fnbx_tot_compare+sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_nanom');
fnbx_tot_compare = fnbx_tot_compare+sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_panom');
fnbx_tot_compare = fnbx_tot_compare+sum(sum(tmp(:,:,1,:,isplot),5),3);
tmp = ncread(balfile,'fna_pschused');
fnbx_tot_compare = fnbx_tot_compare+sum(sum(tmp(:,:,1,:,isplot),5),3);

figure; hold on;
plot(fnbx_tot(:,comuse.sep+2));
plot(fnbx_tot_compare(:,comuse.sep+2));
plot(fnbx_tot(:,comuse.sep+2)-fnbx_tot_compare(:,comuse.sep+2))

% Sources:
tmp = ncread(balfile,'tot_sna_bal');
tot_sna_bal = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbr_phys_sna_bal');
tot_sna_bal_compare = sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbr_bas_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbr_first_flight_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stbc_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'eirene_mc_papl_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'eirene_mc_pmpl_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'eirene_mc_pipl_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'eirene_mc_pppl_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'eirene_mc_core_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+squeeze(sum(sum(tmp(:,:,isplot,:),3),4));
tmp = ncread(balfile,'b2stbm_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'ext_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_sna_ion_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stel_sna_rec_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2stcx_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srsm_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srdt_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);
tmp = ncread(balfile,'b2srst_sna_bal');
tot_sna_bal_compare = tot_sna_bal_compare+sum(tmp(:,:,isplot),3);

figure; hold on;
plot(tot_sna_bal(2:end-1,comuse.sep+2));
plot(tot_sna_bal_compare(2:end-1,comuse.sep+2));
plot(tot_sna_bal(2:end-1,comuse.sep+2)-tot_sna_bal_compare(2:end-1,comuse.sep+2));

% Residual:
tmp = ncread(balfile,'resco');
rescb = sum(tmp(:,:,isplot),3);
%%

%% Create the units string
switch areatype
    case 'parallel'
        units = 'm^{-2}s^{-1}';
    case 'contact'
        units = 'm^{-2}s^{-1}';
    case 'none'
        units = 's^{-1}';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end
%%

%% Calculate the radial divergences...
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

%% Make plots...
btn = radial_balance(...
 cat(3,fnbx_pll,fnbx_drift,fnbx_nanom,fnbx_panom,fnbx_pinch,fnbx_ch,fnbx_pschused),...
 cat(3,raddiv_drift,raddiv_pll,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_papl_sna,4),sum(eirene_mc_pmpl_sna,4),sum(eirene_mc_pipl_sna,4),sum(eirene_mc_pppl_sna,4),eirene_mc_core_sna,...
       b2stel_sna_ion_prev,b2stel_sna_ion_next,b2stel_sna_rec_prev,b2stel_sna_rec_next,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna,b2stbr_phys_sna,b2stbr_bas_sna,b2stbr_first_flight_sna),...
 rescb,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'parallel convection','dia.+ExB drifts','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnbx\_ch','PS'},...
 {'rad. drift diverg.','rad. diverg. nv_{||}','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion prev.','b2stel ion next','b2stel rec prev.','b2stel rec next','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},...
 comuse,indrad,area_divide,reverse,false,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

areadividepol = poloidal_balance(...
 cat(3,fnbx_pll,fnbx_drift,fnbx_nanom,fnbx_panom,fnbx_pinch,fnbx_ch,fnbx_pschused),...
 cat(3,raddiv_drift,raddiv_pll,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_papl_sna,4),sum(eirene_mc_pmpl_sna,4),sum(eirene_mc_pipl_sna,4),sum(eirene_mc_pppl_sna,4),eirene_mc_core_sna,...
       b2stel_sna_ion_prev,b2stel_sna_ion_next,b2stel_sna_rec_prev,b2stel_sna_rec_next,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna,b2stbr_phys_sna,b2stbr_bas_sna,b2stbr_first_flight_sna),...
 rescb,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'parallel convection','dia.+ExB drifts','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnbx\_ch','PS'},...
 {'rad. drift diverg.','rad. diverg. nv_{||}','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion prev.','b2stel ion next','b2stel rec prev.','b2stel rec next','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},...
 comuse,indpol,area_divide,reverse,false,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_papl_sna)},{squeeze(eirene_mc_pmpl_sna)},{squeeze(eirene_mc_pipl_sna)},{squeeze(eirene_mc_pppl_sna)},...
                      {'Strata decomp. of (\int_d^uS_{part}^{EIR}dV)/dA_{||d} in radial direction',...
                       'Strata decomp. of S_{part}^{EIR}dV/dA_{||d}$ in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,btn.areadown,areadividepol,reverse,false);
end
%%
end




