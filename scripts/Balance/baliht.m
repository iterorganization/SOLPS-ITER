%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baliht plots the ion internal energy balance for a given SOLPS simulation.   %
% balfile:     Full path to balance.nc file                                    %
% indrad:      Logical matrix of size nCv that is true for cells where radial  %
%              balance should be performed                                     %
% indpol:      Logical matrix of size nCv that is true for cells where         %
%              poloidal balance should be performed                            %
% facesup:     List of faces of the upstream boundary of indrad                %
% facesdown:   List of faces of the downstream boundary of indrad              %
% facesup_pol: List of faces of the upstream boundary of indpol                %
% facesdown_pol: List of faces of the downstream boundary of indpol            %
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
% areatype:    The type of area that poloidal fluxes are divided by            %
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) August 2024 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function baliht(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nstra = comuse.nstra;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fhi_32');
fhix_32 = tmp(:,1);
fhiy_32 = tmp(:,2);
tmp = ncread(balfile,'fhi_52');
fhix_52 = tmp(:,1);
fhiy_52 = tmp(:,2);
tmp = ncread(balfile,'fhi_cond');
fhix_cond = tmp(:,1);
fhiy_cond = tmp(:,2);
tmp = ncread(balfile,'fhi_dia');
fhix_dia = tmp(:,1);
fhiy_dia = tmp(:,2);
tmp = ncread(balfile,'fhi_ecrb');
fhix_ecrb = tmp(:,1);
fhiy_ecrb = tmp(:,2);
tmp = ncread(balfile,'fhi_strange');
fhix_strange = tmp(:,1);
fhiy_strange = tmp(:,2);
tmp = ncread(balfile,'fhi_pschused');
fhix_pschused = tmp(:,1);
fhiy_pschused = tmp(:,2);
tmp = ncread(balfile,'fhi_inert');
fhix_inert = tmp(:,1);
fhiy_inert = tmp(:,2);
tmp = ncread(balfile,'fhi_vispar');
fhix_vispar = tmp(:,1);
fhiy_vispar = tmp(:,2);
tmp = ncread(balfile,'fhi_anml');
fhix_anml = tmp(:,1);
fhiy_anml = tmp(:,2);
tmp = ncread(balfile,'fhi_kevis');
fhix_kevis = tmp(:,1);
fhiy_kevis = tmp(:,2);
% Sources:
b2stbr_phys_shi = ncread(balfile,'b2stbr_phys_shi_bal');
b2stbr_bas_shi = ncread(balfile,'b2stbr_bas_shi_bal');
b2stbr_first_flight_shi = ncread(balfile,'b2stbr_first_flight_shi_bal');
b2stbc_shi = ncread(balfile,'b2stbc_shi_bal');
if (comuse.b2mndr_eirene~=0)
    eirene_mc_eapl_shi = ncread(balfile,'eirene_mc_eapl_shi_bal');
    eirene_mc_empl_shi = ncread(balfile,'eirene_mc_empl_shi_bal');
    eirene_mc_eipl_shi = ncread(balfile,'eirene_mc_eipl_shi_bal');
    eirene_mc_eppl_shi = ncread(balfile,'eirene_mc_eppl_shi_bal');
else
    eirene_mc_eapl_shi = zeros(nCv,nstra);
    eirene_mc_empl_shi = zeros(nCv,nstra);
    eirene_mc_eipl_shi = zeros(nCv,nstra);
    eirene_mc_eppl_shi = zeros(nCv,nstra);
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

%% Create the units string
switch areatype
    case 'parallel'
        units = 'MWm^{-2}';
    case 'contact'
        units = 'MWm^{-2}';
    case 'none'
        units = 'MW';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end

%% Calculate the total flux depending on areatype
switch areatype
    case 'parallel' % Retain only the poloidal component
        fhi_32 = fhix_32;
        fhi_52 = fhix_52;
        fhi_cond = fhix_cond;
        fhi_dia = fhix_dia;
        fhi_ecrb = fhix_ecrb;
        fhi_strange = fhix_strange;
        fhi_pschused = fhix_pschused;
        fhi_inert = fhix_inert;
        fhi_vispar = fhix_vispar;
        fhi_anml = fhix_anml;
        fhi_kevis = fhix_kevis;
    otherwise % Poloidal + radial component
        fhi_32 = fhix_32 + fhiy_32;
        fhi_52 = fhix_52 + fhiy_52;
        fhi_cond = fhix_cond + fhiy_cond;
        fhi_dia = fhix_dia + fhiy_dia;
        fhi_ecrb = fhix_ecrb + fhiy_ecrb;
        fhi_strange = fhix_strange + fhiy_strange;
        fhi_pschused = fhix_pschused + fhiy_pschused;
        fhi_inert = fhix_inert + fhiy_inert;
        fhi_vispar = fhix_vispar + fhiy_vispar;
        fhi_anml = fhix_anml + fhiy_anml;
        fhi_kevis = fhix_kevis + fhiy_kevis;
end

%% Calculate the radial divergences...
% Radial balance
raddiv_32 = raddiv(fhix_32,fhiy_32,comuse,facesup,facesdown,areatype);
raddiv_52 = raddiv(fhix_52,fhiy_52,comuse,facesup,facesdown,areatype);
raddiv_cond = raddiv(fhix_cond,fhiy_cond,comuse,facesup,facesdown,areatype);
raddiv_dia = raddiv(fhix_dia,fhiy_dia,comuse,facesup,facesdown,areatype);
raddiv_ecrb = raddiv(fhix_ecrb,fhiy_ecrb,comuse,facesup,facesdown,areatype);
raddiv_strange = raddiv(fhix_strange,fhiy_strange,comuse,facesup,facesdown,areatype);
raddiv_pschused = raddiv(fhix_pschused,fhiy_pschused,comuse,facesup,facesdown,areatype);
raddiv_inert = raddiv(fhix_inert,fhiy_inert,comuse,facesup,facesdown,areatype);
raddiv_vispar = raddiv(fhix_vispar,fhiy_vispar,comuse,facesup,facesdown,areatype);
raddiv_anml = raddiv(fhix_anml,fhiy_anml,comuse,facesup,facesdown,areatype);
raddiv_kevis = raddiv(fhix_kevis,fhiy_kevis,comuse,facesup,facesdown,areatype);

% Poloidal balance
raddiv_32_pol = raddiv(fhix_32,fhiy_32,comuse,[],[],areatype);
raddiv_52_pol = raddiv(fhix_52,fhiy_52,comuse,[],[],areatype);
raddiv_cond_pol = raddiv(fhix_cond,fhiy_cond,comuse,[],[],areatype);
raddiv_dia_pol = raddiv(fhix_dia,fhiy_dia,comuse,[],[],areatype);
raddiv_ecrb_pol = raddiv(fhix_ecrb,fhiy_ecrb,comuse,[],[],areatype);
raddiv_strange_pol = raddiv(fhix_strange,fhiy_strange,comuse,[],[],areatype);
raddiv_pschused_pol = raddiv(fhix_pschused,fhiy_pschused,comuse,[],[],areatype);
raddiv_inert_pol = raddiv(fhix_inert,fhiy_inert,comuse,[],[],areatype);
raddiv_vispar_pol = raddiv(fhix_vispar,fhiy_vispar,comuse,[],[],areatype);
raddiv_anml_pol = raddiv(fhix_anml,fhiy_anml,comuse,[],[],areatype);
raddiv_kevis_pol = raddiv(fhix_kevis,fhiy_kevis,comuse,[],[],areatype);

%% Make plots...
btp = radial_balance(...
 cat(2,fhi_32,fhi_52,fhi_cond,fhi_dia,fhi_ecrb,fhi_strange,fhi_pschused,...
       fhi_inert,fhi_vispar,fhi_anml,fhi_kevis)/1E6,...
 cat(2,raddiv_32,raddiv_52,raddiv_cond,raddiv_dia,raddiv_ecrb,raddiv_strange,raddiv_pschused,...
       raddiv_inert,raddiv_vispar,raddiv_anml,raddiv_kevis,b2stbc_shi,...
       sum(eirene_mc_eapl_shi,2),sum(eirene_mc_empl_shi,2),sum(eirene_mc_eipl_shi,2),sum(eirene_mc_eppl_shi,2),...
       b2stbm_shi,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_shi,b2srdt_shi,b2srst_shi,...
       b2sihs_diaa,b2sihs_divua,b2sihs_exba,b2sihs_visa,b2sihs_fraa,b2npht_shei,b2stbr_phys_shi,b2stbr_bas_shi,b2stbr_first_flight_shi)/1E6,....
 reshi/1E6,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'fhi\_32','fhi\_52','fhi\_cond','fhi\_dia','fhi\_ecrb','fhi\_strange','fhi\_pschused',...
  'fhi\_inert','fhi\_vispar','fhi\_anml','fhi\_kevis'},...
 {'rad. diverg. fhi\_32','rad. diverg. fhi\_52','rad. diverg. fhi\_cond','rad. diverg. fhi\_dia',...
  'rad. diverg. fhi\_ecrb','rad. diverg. fhi\_strange','rad. diverg. fhi\_psch',...
  'rad. diverg. fhi\_inert','rad. diverg. fhi\_vispar','rad. diverg. fhi\_anml','rad. diverg. fhi\_kevis','b2stbc\_shi',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_shi','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_shi','b2srdt\_shi','b2srst\_shi',...
  'b2sihs\_diaa','b2sihs\_divua','b2sihs\_exba','b2sihs\_visa','b2sihs\_fraa','equipartition','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},...
 comuse,indrad,facesup,facesdown,area_divide,reverse,false,axbal(1:4),units,makeplot,areaend);

areadownpol = poloidal_balance(...
 cat(2,fhi_32,fhi_52,fhi_cond,fhi_dia,fhi_ecrb,fhi_strange,fhi_pschused,...
       fhi_inert,fhi_vispar,fhi_anml,fhi_kevis)/1E6,...
 cat(2,raddiv_32_pol,raddiv_52_pol,raddiv_cond_pol,raddiv_dia_pol,raddiv_ecrb_pol,raddiv_strange_pol,raddiv_pschused_pol,...
       raddiv_inert_pol,raddiv_vispar_pol,raddiv_anml_pol,raddiv_kevis_pol,b2stbc_shi,...
       sum(eirene_mc_eapl_shi,2),sum(eirene_mc_empl_shi,2),sum(eirene_mc_eipl_shi,2),sum(eirene_mc_eppl_shi,2),...
       b2stbm_shi,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_shi,b2srdt_shi,b2srst_shi,...
       b2sihs_diaa,b2sihs_divua,b2sihs_exba,b2sihs_visa,b2sihs_fraa,b2npht_shei,b2stbr_phys_shi,b2stbr_bas_shi,b2stbr_first_flight_shi)/1E6,...
 reshi/1E6,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'fhi\_32','fhi\_52','fhi\_cond','fhi\_dia','fhi\_ecrb','fhi\_strange','fhi\_pschused',...
  'fhi\_inert','fhi\_vispar','fhi\_anml','fhi\_kevis'},...
 {'rad. diverg. fhi\_32','rad. diverg. fhi\_52','rad. diverg. fhi\_cond','rad. diverg. fhi\_dia',...
  'rad. diverg. fhi\_ecrb','rad. diverg. fhi\_strange','rad. diverg. fhi\_psch',...
  'rad. diverg. fhi\_inert','rad. diverg. fhi\_vispar','rad. diverg. fhi\_anml','rad. diverg. fhi\_kevis','b2stbc\_shi',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_shi','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_shi','b2srdt\_shi','b2srst\_shi',...
  'b2sihs\_diaa','b2sihs\_divua','b2sihs\_exba','b2sihs\_visa','b2sihs\_fraa','equipartition','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},...
 comuse,indpol,facesup_pol,facesdown_pol,area_divide,reverse,false,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({eirene_mc_eapl_shi/1E6},{eirene_mc_empl_shi/1E6},{eirene_mc_eipl_shi/1E6},{eirene_mc_eppl_shi/1E6},...
                      {'Strata decomp. of (\int_d^uS_{iIE}^{EIR}dV)/dA_{||d}$ in radial direction',...
                       'Strata decomp. of S_{iIE}^{EIR}dV/dA_{||d} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,btp.areadown,areadownpol,reverse,false);
end              
%%
end




