%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balpart plots the particle balance for a given SOLPS simulation.             %
% balfile:     Full path to balance.nc file                                    %
% indrad:      Logical matrix of size nCv that is true for cells where radial  %
%              balance should be performed                                     %
% indpol:      Logical matrix of size nCv that is true for cells where         %
%              poloidal balance should be performed                            %
% facesup:     List of faces of the upstream boundary of indrad                %
% facesdown:   List of faces of the downstream boundary of indrad              %
% facesup_pol: List of faces of the upstream boundary of indpol                %
% facesdown_pol: List of faces of the downstream boundary of indpol            %
% isplot:      Species index to be plotted                                     %
% comuse:      Structure containing commonly-used variables (from get_comuse)  %
% axbal:       Array of axes into which balance plots will be placed           %
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
%              on the x-axis of the poloidal balance plots.                    %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function btn = balpart(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,isplot,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nstra = comuse.nstra;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fna_pinch');
fnbx_pinch = sum(tmp(:,1,isplot),3);
fnby_pinch = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fna_pll');
fnbx_pll = sum(tmp(:,1,isplot),3);
fnby_pll = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fna_drift');
fnbx_drift = sum(tmp(:,1,isplot),3);
fnby_drift = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fna_ch');
fnbx_ch = sum(tmp(:,1,isplot),3);
fnby_ch = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fna_nanom');
fnbx_nanom = sum(tmp(:,1,isplot),3);
fnby_nanom = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fna_panom');
fnbx_panom = sum(tmp(:,1,isplot),3);
fnby_panom = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fna_pschused');
fnbx_pschused = sum(tmp(:,1,isplot),3);
fnby_pschused = sum(tmp(:,2,isplot),3);
% Sources:
tmp = ncread(balfile,'b2stbr_phys_sna_bal');
b2stbr_phys_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stbr_bas_sna_bal');
b2stbr_bas_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stbr_first_flight_sna_bal');
b2stbr_first_flight_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stbc_sna_bal');
b2stbc_sna = sum(tmp(:,isplot),2);
if (comuse.b2mndr_eirene~=0)
    tmp = ncread(balfile,'eirene_mc_papl_sna_bal');
    eirene_mc_papl_sna = sum(tmp(:,isplot,:),2);
    tmp = ncread(balfile,'eirene_mc_pmpl_sna_bal');
    eirene_mc_pmpl_sna = sum(tmp(:,isplot,:),2);
    tmp = ncread(balfile,'eirene_mc_pipl_sna_bal');
    eirene_mc_pipl_sna = sum(tmp(:,isplot,:),2);
    tmp = ncread(balfile,'eirene_mc_pppl_sna_bal');
    eirene_mc_pppl_sna = sum(tmp(:,isplot,:),2);
    tmp = ncread(balfile,'eirene_mc_core_sna_bal');
    eirene_mc_core_sna = sum(tmp(:,isplot),2);
else
    eirene_mc_papl_sna = zeros(nCv,1,nstra);
    eirene_mc_pmpl_sna = zeros(nCv,1,nstra);
    eirene_mc_pipl_sna = zeros(nCv,1,nstra);
    eirene_mc_pppl_sna = zeros(nCv,1,nstra);
    eirene_mc_core_sna = zeros(nCv,1,nstra);
end
tmp = ncread(balfile,'b2stbm_sna_bal');
b2stbm_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'ext_sna_bal');
ext_sna = sum(tmp(:,isplot),2);
% Calculate the ionisation sink to the next ionisation state and the ionisation
% source from the previous ionisation state:
b2stel_sna_ion_bal = ncread(balfile,'b2stel_sna_ion_bal');
izhigh = [find(diff(comuse.za)<1)',comuse.ns];
izlow = [1,izhigh(1:end-1)+1];
b2stel_sna_ion_prev = zeros(nCv,comuse.ns);
b2stel_sna_ion_next = zeros(nCv,comuse.ns);
for is1=1:length(izhigh)
    for is2=izhigh(is1):-1:izlow(is1)
        if is2==izhigh(is1)
            b2stel_sna_ion_next(:,is2) = 0;
            b2stel_sna_ion_prev(:,is2) = b2stel_sna_ion_bal(:,is2);
        else
            b2stel_sna_ion_next(:,is2) = -b2stel_sna_ion_prev(:,is2+1);
            b2stel_sna_ion_prev(:,is2) = b2stel_sna_ion_bal(:,is2)-b2stel_sna_ion_next(:,is2);
        end
    end
end
b2stel_sna_ion_prev = sum(b2stel_sna_ion_prev(:,isplot),2);
b2stel_sna_ion_next = sum(b2stel_sna_ion_next(:,isplot),2);
% Calculate the recombination sink to the previous ionisation state and the
% recombination source from the next ionisation state:
b2stel_sna_rec_bal = ncread(balfile,'b2stel_sna_rec_bal');
b2stel_sna_rec_prev = zeros(nCv,comuse.ns);
b2stel_sna_rec_next = zeros(nCv,comuse.ns);
for is1=1:length(izhigh)
    for is2=izhigh(is1):-1:izlow(is1)
        if is2==izhigh(is1)
            b2stel_sna_rec_next(:,is2) = 0;
            b2stel_sna_rec_prev(:,is2) = b2stel_sna_rec_bal(:,is2);
        else
            b2stel_sna_rec_next(:,is2) = -b2stel_sna_rec_prev(:,is2+1);
            b2stel_sna_rec_prev(:,is2) = b2stel_sna_rec_bal(:,is2)-b2stel_sna_rec_next(:,is2);
        end
    end
end
b2stel_sna_rec_prev = sum(b2stel_sna_rec_prev(:,isplot),2);
b2stel_sna_rec_next = sum(b2stel_sna_rec_next(:,isplot),2);
tmp = ncread(balfile,'b2stcx_sna_bal');
b2stcx_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2srsm_sna_bal');
b2srsm_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2srdt_sna_bal');
b2srdt_sna = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2srst_sna_bal');
b2srst_sna = sum(tmp(:,isplot),2);
% Residual:
tmp = ncread(balfile,'resco');
rescb = sum(tmp(:,isplot),2);
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

%% Calculate the total flux depending on areatype
switch areatype
    case 'parallel' % Retain only the poloidal component
        fnb_pll = fnbx_pll;
        fnb_drift = fnbx_drift;
        fnb_nanom = fnbx_nanom;
        fnb_panom = fnbx_panom;
        fnb_pinch = fnbx_pinch;
        fnb_ch = fnbx_ch;
        fnb_pschused = fnbx_pschused;
    otherwise % Poloidal + radial component
        fnb_pll = fnbx_pll + fnby_pll;
        fnb_drift = fnbx_drift + fnby_drift;
        fnb_nanom = fnbx_nanom + fnby_nanom;
        fnb_panom = fnbx_panom + fnby_panom;
        fnb_pinch = fnbx_pinch + fnby_pinch;
        fnb_ch = fnbx_ch + fnby_ch;
        fnb_pschused = fnbx_pschused + fnby_pschused;
end

%% Calculate the radial divergences...
% Radial balance
raddiv_pll = raddiv(fnbx_pll,fnby_pll,comuse,facesup,facesdown,areatype);
raddiv_drift = raddiv(fnbx_drift,fnby_drift,comuse,facesup,facesdown,areatype);
raddiv_nanom = raddiv(fnbx_nanom,fnby_nanom,comuse,facesup,facesdown,areatype);
raddiv_panom = raddiv(fnbx_panom,fnby_panom,comuse,facesup,facesdown,areatype);
raddiv_pinch = raddiv(fnbx_pinch,fnby_pinch,comuse,facesup,facesdown,areatype);
raddiv_ch = raddiv(fnbx_ch,fnby_ch,comuse,facesup,facesdown,areatype);
raddiv_pschused = raddiv(fnbx_pschused,fnby_pschused,comuse,facesup,facesdown,areatype);

% Poloidal balance
raddiv_pll_pol = raddiv(fnbx_pll,fnby_pll,comuse,[],[],areatype);
raddiv_drift_pol = raddiv(fnbx_drift,fnby_drift,comuse,[],[],areatype);
raddiv_nanom_pol = raddiv(fnbx_nanom,fnby_nanom,comuse,[],[],areatype);
raddiv_panom_pol = raddiv(fnbx_panom,fnby_panom,comuse,[],[],areatype);
raddiv_pinch_pol = raddiv(fnbx_pinch,fnby_pinch,comuse,[],[],areatype);
raddiv_ch_pol = raddiv(fnbx_ch,fnby_ch,comuse,[],[],areatype);
raddiv_pschused_pol = raddiv(fnbx_pschused,fnby_pschused,comuse,[],[],areatype);

%% Make plots...
btn = radial_balance(...
 cat(2,fnb_pll,fnb_drift,fnb_nanom,fnb_panom,fnb_pinch,fnb_ch,fnb_pschused),...
 cat(2,raddiv_pll,raddiv_drift,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_papl_sna,3),sum(eirene_mc_pmpl_sna,3),sum(eirene_mc_pipl_sna,3),sum(eirene_mc_pppl_sna,3),eirene_mc_core_sna,...
       b2stel_sna_ion_prev,b2stel_sna_ion_next,b2stel_sna_rec_prev,b2stel_sna_rec_next,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna,b2stbr_phys_sna,b2stbr_bas_sna,b2stbr_first_flight_sna),...
 rescb,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'parallel convection','dia.+ExB drifts','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnb\_ch','PS'},...
 {'rad. diverg. nv_{||}','rad. drift diverg.','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion prev.','b2stel ion next','b2stel rec prev.','b2stel rec next','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},...
 comuse,indrad,facesup,facesdown,area_divide,reverse,false,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

areadividepol = poloidal_balance(...
 cat(2,fnb_drift,fnb_pll,fnb_nanom,fnb_panom,fnb_pinch,fnb_ch,fnb_pschused),...
 cat(2,raddiv_drift_pol,raddiv_pll_pol,raddiv_nanom_pol,raddiv_panom_pol,raddiv_pinch_pol,raddiv_ch_pol,raddiv_pschused_pol,...
 sum(eirene_mc_papl_sna,3),sum(eirene_mc_pmpl_sna,3),sum(eirene_mc_pipl_sna,3),sum(eirene_mc_pppl_sna,3),eirene_mc_core_sna,...
       b2stel_sna_ion_prev,b2stel_sna_ion_next,b2stel_sna_rec_prev,b2stel_sna_rec_next,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna,b2stbr_phys_sna,b2stbr_bas_sna,b2stbr_first_flight_sna),...
 rescb,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'parallel convection','dia.+ExB drifts','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnb\_ch','PS'},...
 {'rad. diverg. nv_{||}','rad. drift diverg.','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion prev.','b2stel ion next','b2stel rec prev.','b2stel rec next','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},...
 comuse,indpol,facesup_pol,facesdown_pol,area_divide,reverse,false,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_papl_sna)},{squeeze(eirene_mc_pmpl_sna)},{squeeze(eirene_mc_pipl_sna)},{squeeze(eirene_mc_pppl_sna)},...
                      {'Strata decomp. of EIRENE particle source with radial resolution',...
                       'Strata decomp. of EIRENE particle source with poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,btn.area_divide,areadividepol,reverse,false);
end
%%
end




