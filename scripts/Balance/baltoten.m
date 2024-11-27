%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baltoten plots the total internal energy balance for a given SOLPS           %
% simulation.                                                                  %
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
function bth = baltoten(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nFc = comuse.nFc;
nstra = comuse.nstra;

%% Obtain required arrays from the simulation...
% Fluxes (electrons)
fhe_32 = ncread(balfile,'fhe_32');
fne = ncread(balfile,'fne');
te = intface(ncread(balfile,'te'),comuse);
fhex_32 = fhe_32(:,1)+fne(:,1).*te;
fhey_32 = fhe_32(:,2);
tmp = ncread(balfile,'fhe_52');
fhex_52 = tmp(:,1);
fhey_52 = tmp(:,2);
tmp = ncread(balfile,'fhe_thermj');
fhex_thermj = tmp(:,1);
fhey_thermj = tmp(:,2);
tmp = ncread(balfile,'fhe_cond');
fhex_cond = tmp(:,1);
fhey_cond = tmp(:,2);
tmp = ncread(balfile,'fhe_dia');
fhex_dia = tmp(:,1);
fhey_dia = tmp(:,2);
tmp = ncread(balfile,'fhe_ecrb');
fhex_ecrb = tmp(:,1);
fhey_ecrb = tmp(:,2);
tmp = ncread(balfile,'fhe_strange');
fhex_strange = tmp(:,1);
fhey_strange = tmp(:,2);
tmp = ncread(balfile,'fhe_pschused');
fhex_pschused = tmp(:,1);
fhey_pschused = tmp(:,2);
% Fluxes (ions):
fhi_32 = ncread(balfile,'fhi_32');
fhix_32 = fhi_32(:,1);
fhix_KE = zeros(nFc,1);
fhiy_KE = zeros(nFc,1);
ti = intface(ncread(balfile,'ti'),comuse);
fna = ncread(balfile,'fna_pinch')+...
      ncread(balfile,'fna_pll')+...
      ncread(balfile,'fna_drift')+...
      ncread(balfile,'fna_ch')+...
      ncread(balfile,'fna_nanom')+...
      ncread(balfile,'fna_panom')+...
      ncread(balfile,'fna_pschused');
kinrgy = ncread(balfile,'kinrgy');
for is=1:comuse.ns
    kinrgyf = intface(kinrgy(:,is),comuse);
    fhix_32 = fhix_32+fna(:,1,is).*ti;
    fhix_KE = fhix_KE+fna(:,1,is).*kinrgyf;
    fhiy_KE = fhiy_KE+fna(:,2,is).*kinrgyf;
end
fhiy_32 = fhi_32(:,2);
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
% KE of ion flow:
% tmp = ncread(balfile,'fna_pll');
% fnax = tmp(:,:,1,2);
% tmp = ncread(balfile,'kinrgy');
% kinrgy = tmp(:,:,2);
% fhix_KE = zeros(nx,ny);
% for iy=1:ny
%     for ix=1:nx
%         if leftix(ix,iy)<1
%             continue;
%         end
%         fhix_KE(ix,iy) = fnax(ix,iy)*...
%                        (kinrgy(leftix(ix,iy),leftiy(ix,iy))*dv(ix,iy)+...
%                         kinrgy(ix,iy)*dv(leftix(ix,iy),leftiy(ix,iy)))/...
%                        (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)));
%     end
% end
% Sources (electrons):
b2stbr_phys_she = ncread(balfile,'b2stbr_phys_she_bal');
b2stbr_bas_she = ncread(balfile,'b2stbr_bas_she_bal');
b2stbr_first_flight_she = ncread(balfile,'b2stbr_first_flight_she_bal');
b2stbc_she = ncread(balfile,'b2stbc_she_bal');
if (comuse.b2mndr_eirene~=0)
    eirene_mc_eael_she = ncread(balfile,'eirene_mc_eael_she_bal');
    eirene_mc_emel_she = ncread(balfile,'eirene_mc_emel_she_bal');
    eirene_mc_eiel_she = ncread(balfile,'eirene_mc_eiel_she_bal');
    eirene_mc_epel_she = ncread(balfile,'eirene_mc_epel_she_bal');
else
    eirene_mc_eael_she = zeros(nCv,nstra);
    eirene_mc_emel_she = zeros(nCv,nstra);
    eirene_mc_eiel_she = zeros(nCv,nstra);
    eirene_mc_epel_she = zeros(nCv,nstra);
end
b2stbm_she = ncread(balfile,'b2stbm_she_bal');
ext_she = ncread(balfile,'ext_she_bal');
b2stel_she = ncread(balfile,'b2stel_she_bal');
b2srsm_she = ncread(balfile,'b2srsm_she_bal');
b2srdt_she = ncread(balfile,'b2srdt_she_bal');
b2srst_she = ncread(balfile,'b2srst_she_bal');
b2sihs_diae = ncread(balfile,'b2sihs_diae_bal');
b2sihs_divue = ncread(balfile,'b2sihs_divue_bal');
b2sihs_divue = zeros(size(b2sihs_divue));
b2sihs_exbe = ncread(balfile,'b2sihs_exbe_bal');
b2sihs_joule = ncread(balfile,'b2sihs_joule_bal');
% Sources (ions):
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
b2sihs_divua = zeros(size(b2sihs_divua));
b2sihs_exba = ncread(balfile,'b2sihs_exba_bal');
b2sihs_visa = ncread(balfile,'b2sihs_visa_bal');
b2sihs_fraa = ncread(balfile,'b2sihs_fraa_bal');
% Residual (electrons):
reshe = ncread(balfile,'reshe');
% Residual (ions):
reshi = ncread(balfile,'reshi');

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
        fhe_32 = fhex_32;
        fhe_52 = fhex_52;
        fhe_thermj = fhex_thermj;
        fhe_cond = fhex_cond;
        fhe_dia = fhex_dia;
        fhe_ecrb = fhex_ecrb;
        fhe_strange = fhex_strange;
        fhe_pschused = fhex_pschused;
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
        fhi_KE = fhix_KE;
    otherwise % Poloidal + radial component
        fhe_32 = fhex_32 + fhey_32;
        fhe_52 = fhex_52 + fhey_52;
        fhe_thermj = fhex_thermj + fhey_thermj;
        fhe_cond = fhex_cond + fhey_cond;
        fhe_dia = fhex_dia + fhey_dia;
        fhe_ecrb = fhex_ecrb + fhey_ecrb;
        fhe_strange = fhex_strange + fhey_strange;
        fhe_pschused = fhex_pschused + fhey_pschused;
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
        fhi_KE = fhix_KE + fhiy_KE;
end

%% Calculate the radial divergences...
% Radial balance
raddive_32 = raddiv(fhex_32,fhey_32,comuse,facesup,facesdown,areatype);
raddive_52 = raddiv(fhex_52,fhey_52,comuse,facesup,facesdown,areatype);
raddive_thermj = raddiv(fhex_thermj,fhey_thermj,comuse,facesup,facesdown,areatype);
raddive_cond = raddiv(fhex_cond,fhey_cond,comuse,facesup,facesdown,areatype);
raddive_dia = raddiv(fhex_dia,fhey_dia,comuse,facesup,facesdown,areatype);
raddive_ecrb = raddiv(fhex_ecrb,fhey_ecrb,comuse,facesup,facesdown,areatype);
raddive_strange = raddiv(fhex_strange,fhey_strange,comuse,facesup,facesdown,areatype);
raddive_pschused = raddiv(fhex_pschused,fhey_pschused,comuse,facesup,facesdown,areatype);
raddivi_32 = raddiv(fhix_32,fhiy_32,comuse,facesup,facesdown,areatype);
raddivi_52 = raddiv(fhix_52,fhiy_52,comuse,facesup,facesdown,areatype);
raddivi_cond = raddiv(fhix_cond,fhiy_cond,comuse,facesup,facesdown,areatype);
raddivi_dia = raddiv(fhix_dia,fhiy_dia,comuse,facesup,facesdown,areatype);
raddivi_ecrb = raddiv(fhix_ecrb,fhiy_ecrb,comuse,facesup,facesdown,areatype);
raddivi_strange = raddiv(fhix_strange,fhiy_strange,comuse,facesup,facesdown,areatype);
raddivi_pschused = raddiv(fhix_pschused,fhiy_pschused,comuse,facesup,facesdown,areatype);
raddivi_inert = raddiv(fhix_inert,fhiy_inert,comuse,facesup,facesdown,areatype);
raddivi_vispar = raddiv(fhix_vispar,fhiy_vispar,comuse,facesup,facesdown,areatype);
raddivi_anml = raddiv(fhix_anml,fhiy_anml,comuse,facesup,facesdown,areatype);
raddivi_kevis = raddiv(fhix_kevis,fhiy_kevis,comuse,facesup,facesdown,areatype);

% Poloidal balance
raddive_32_pol = raddiv(fhex_32,fhey_32,comuse,[],[],areatype);
raddive_52_pol = raddiv(fhex_52,fhey_52,comuse,[],[],areatype);
raddive_thermj_pol = raddiv(fhex_thermj,fhey_thermj,comuse,[],[],areatype);
raddive_cond_pol = raddiv(fhex_cond,fhey_cond,comuse,[],[],areatype);
raddive_dia_pol = raddiv(fhex_dia,fhey_dia,comuse,[],[],areatype);
raddive_ecrb_pol = raddiv(fhex_ecrb,fhey_ecrb,comuse,[],[],areatype);
raddive_strange_pol = raddiv(fhex_strange,fhey_strange,comuse,[],[],areatype);
raddive_pschused_pol = raddiv(fhex_pschused,fhey_pschused,comuse,[],[],areatype);
raddivi_32_pol = raddiv(fhix_32,fhiy_32,comuse,[],[],areatype);
raddivi_52_pol = raddiv(fhix_52,fhiy_52,comuse,[],[],areatype);
raddivi_cond_pol = raddiv(fhix_cond,fhiy_cond,comuse,[],[],areatype);
raddivi_dia_pol = raddiv(fhix_dia,fhiy_dia,comuse,[],[],areatype);
raddivi_ecrb_pol = raddiv(fhix_ecrb,fhiy_ecrb,comuse,[],[],areatype);
raddivi_strange_pol = raddiv(fhix_strange,fhiy_strange,comuse,[],[],areatype);
raddivi_pschused_pol = raddiv(fhix_pschused,fhiy_pschused,comuse,[],[],areatype);
raddivi_inert_pol = raddiv(fhix_inert,fhiy_inert,comuse,[],[],areatype);
raddivi_vispar_pol = raddiv(fhix_vispar,fhiy_vispar,comuse,[],[],areatype);
raddivi_anml_pol = raddiv(fhix_anml,fhiy_anml,comuse,[],[],areatype);
raddivi_kevis_pol = raddiv(fhix_kevis,fhiy_kevis,comuse,[],[],areatype);

%% Make plots...
bth = radial_balance(...
 cat(2,fhe_32,fhi_32,fhe_52,fhi_52,fhe_cond,fhi_cond,fhe_thermj,fhe_dia,fhi_dia,fhe_ecrb,fhi_ecrb,fhe_strange,...
       fhi_strange,fhe_pschused,fhi_pschused,fhi_inert,fhi_vispar,fhi_anml,fhi_kevis,fhi_KE)/1E6,...
 cat(2,raddive_32,raddivi_32,raddive_52,raddivi_52,raddive_cond,raddivi_cond,raddive_thermj,raddive_dia,raddivi_dia,...
 raddive_ecrb,raddivi_ecrb,raddive_strange,raddivi_strange,raddive_pschused,raddivi_pschused,raddivi_inert,raddivi_vispar,...
 raddivi_anml,raddivi_kevis,b2stbc_she,b2stbc_shi,...
       sum(eirene_mc_eael_she,2),sum(eirene_mc_emel_she,2),sum(eirene_mc_eiel_she,2),sum(eirene_mc_epel_she,2),...
       sum(eirene_mc_eapl_shi,2),sum(eirene_mc_empl_shi,2),sum(eirene_mc_eipl_shi,2),sum(eirene_mc_eppl_shi,2),...
       b2stbm_she,b2stbm_shi,ext_she,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_she,b2srsm_shi,b2srdt_she,b2srdt_shi,b2srst_she,b2srst_shi,...
       b2sihs_diae,b2sihs_diaa,b2sihs_divue,b2sihs_divua,b2sihs_exbe,b2sihs_exba,b2sihs_visa,b2sihs_joule,b2sihs_fraa,...
       b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stbr_phys_shi,b2stbr_bas_shi,b2stbr_first_flight_shi,b2stel_she)/1E6,...
 (reshe+reshi)/1E6,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'fhe\_32','fhi\_32','fhe\_52','fhi\_52','fhe\_cond','fhi\_cond','fhe\_thermj','fhe\_dia','fhi\_dia','fhe\_ecrb','fhi\_ecrb','fhe\_strange',...
  'fhi\_strange','fhe\_pschused','fhi\_pschused','fhi\_inert','fhi\_vispar','fhi\_anml','fhi\_kevis','fhi_KE'},...
 [{'rad. diverg. fhe\_32','rad. diverg. fhi\_32','rad. diverg. fhe\_52','rad. diverg. fhi\_52','rad. diverg. fhe\_cond',...
  'rad. diverg. fhi\_cond','rad. diverg. fhe\_thermj','rad. diverg. fhe\_dia','rad. diverg. fhi\_dia','rad. diverg. fhe\_ecrb',...
  'rad. diverg. fhi\_ecrb','rad. diverg. fhe\_strange','rad. diverg. fhi\_strange','rad. diverg. fhe\_pschused','rad. diverg. fhi\_pschused',...
  'rad. diverg. fhi\_inert','rad. diverg. fhi\_vispar','rad. diverg. fhi\_anml','rad. diverg. fhi\_kevis',...
  'b2stbc\_she','b2stbc\_shi',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_she','b2stbm\_shi','ext\_she','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_she','b2srsm\_shi','b2srdt\_she','b2srdt\_shi','b2srst\_she','b2srst\_shi',...
  'b2sihs\_diae','b2sihs\_diaa','b2sihs\_divue','b2sihs\_divua','b2sihs\_exbe','b2sihs\_exba','b2sihs\_visa','b2sihs\_joule','b2sihs\_fraa',...
  'b2stbr\_phys el.','b2stbr\_bas el.','b2stbr\_first\_flight el.','b2stbr\_phys ion','b2stbr\_bas ion','b2stbr\_first\_flight ion'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indrad,facesup,facesdown,area_divide,reverse,false,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

pb = poloidal_balance(...
 cat(2,fhe_32,fhi_32,fhe_52,fhi_52,fhe_cond,fhi_cond,fhe_thermj,fhe_dia,fhi_dia,fhe_ecrb,fhi_ecrb,fhe_strange,...
       fhi_strange,fhe_pschused,fhi_pschused,fhi_inert,fhi_vispar,fhi_anml,fhi_kevis,fhi_KE)/1E6,...
 cat(2,raddive_32_pol,raddivi_32_pol,raddive_52_pol,raddivi_52_pol,raddive_cond_pol,raddivi_cond_pol,raddive_thermj_pol,...
       raddive_dia_pol,raddivi_dia_pol,raddive_ecrb_pol,raddivi_ecrb_pol,raddive_strange_pol,raddivi_strange_pol,...
       raddive_pschused_pol,raddivi_pschused_pol,raddivi_inert_pol,raddivi_vispar_pol,raddivi_anml_pol,raddivi_kevis_pol,...
       b2stbc_she,b2stbc_shi,...
       sum(eirene_mc_eael_she,2),sum(eirene_mc_emel_she,2),sum(eirene_mc_eiel_she,2),sum(eirene_mc_epel_she,2),...
       sum(eirene_mc_eapl_shi,2),sum(eirene_mc_empl_shi,2),sum(eirene_mc_eipl_shi,2),sum(eirene_mc_eppl_shi,2),...
       b2stbm_she,b2stbm_shi,ext_she,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_she,b2srsm_shi,b2srdt_she,b2srdt_shi,b2srst_she,b2srst_shi,...
       b2sihs_diae,b2sihs_diaa,b2sihs_divue,b2sihs_divua,b2sihs_exbe,b2sihs_exba,b2sihs_visa,b2sihs_joule,b2sihs_fraa,...
       b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stbr_phys_shi,b2stbr_bas_shi,b2stbr_first_flight_shi,b2stel_she)/1E6,...
 (reshe+reshi)/1E6,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'fhe\_32','fhi\_32','fhe\_52','fhi\_52','fhe\_cond','fhi\_cond','fhe\_thermj','fhe\_dia','fhi\_dia','fhe\_ecrb','fhi\_ecrb','fhe\_strange',...
  'fhi\_strange','fhe\_pschused','fhi\_pschused','fhi\_inert','fhi\_vispar','fhi\_anml','fhi\_kevis','fhi_KE'},...
 [{'rad. diverg. fhe\_32','rad. diverg. fhi\_32','rad. diverg. fhe\_52','rad. diverg. fhi\_52','rad. diverg. fhe\_cond',...
  'rad. diverg. fhi\_cond','rad. diverg. fhe\_thermj','rad. diverg. fhe\_dia','rad. diverg. fhi\_dia','rad. diverg. fhe\_ecrb',...
  'rad. diverg. fhi\_ecrb','rad. diverg. fhe\_strange','rad. diverg. fhi\_strange','rad. diverg. fhe\_pschused','rad. diverg. fhi\_pschused',...
  'rad. diverg. fhi\_inert','rad. diverg. fhi\_vispar','rad. diverg. fhi\_anml','rad. diverg. fhi\_kevis',...
  'b2stbc\_she','b2stbc\_shi',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_she','b2stbm\_shi','ext\_she','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_she','b2srsm\_shi','b2srdt\_she','b2srdt\_shi','b2srst\_she','b2srst\_shi',...
  'b2sihs\_diae','b2sihs\_diaa','b2sihs\_divue','b2sihs\_divua','b2sihs\_exbe','b2sihs\_exba','b2sihs\_visa','b2sihs\_joule','b2sihs\_fraa',...
  'b2stbr\_phys el.','b2stbr\_bas el.','b2stbr\_first\_flight el.','b2stbr\_phys ion','b2stbr\_bas ion','b2stbr\_first\_flight ion'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indpol,facesup_pol,facesdown_pol,area_divide,reverse,false,axbal(5:7),units,areaend,polbaldist,19);

if strata_plot
    make_strata_plots({eirene_mc_eael_she/1E6,eirene_mc_eapl_shi/1E6},{eirene_mc_emel_she/1E6,eirene_mc_empl_shi/1E6},...
                      {eirene_mc_eiel_she/1E6,eirene_mc_eipl_shi/1E6},{eirene_mc_epel_she/1E6,eirene_mc_eppl_shi/1E6},...
                      {['Strata decomp. of (\int_d^uS_{eIE}^{EIR}dV)/dA_{||d} and ',...
                        '(\int_d^uS_{iIE}^{EIR}dV)/dA_{||d} in radial direction'],...
                       ['Strata decomp. of S_{eIE}^{EIR}dV/dA_{||d}$ and ',...
                        'S_{iIE}^{EIR}dV/dA_{||d} in poloidal direction']},...
                      {'el','ion'},comuse,indrad,indpol,nstra,axstrat,axbal,bth.area_divide,pb.area_divide,reverse,false,bth.index,pb.pbCv,pb.pbCvP);
end              

% Plot the actual plasma load on the target at the end:
% kinrgy = ncread(balfile,'kinrgy');
% rpt = ncread(balfile,'rpt');
% te = ncread(balfile,'te');
% ti = ncread(balfile,'ti');
% fne = ncread(balfile,'fne');
% fna = ncread(balfile,'fna_pinch')+ncread(balfile,'fna_pll')+ncread(balfile,'fna_drift')+ncread(balfile,'fna_ch')+...
%       ncread(balfile,'fna_nanom')+ncread(balfile,'fna_panom')+ncread(balfile,'fna_pschused');
% is = comuse.za>0;
% nsi = length(find(is));
% fhei = (fhex_32+fhix_32+fhex_52+fhix_52+fhex_cond+fhix_cond+fhex_thermj+fhex_dia+fhix_dia+fhex_ecrb+fhix_ecrb+fhex_strange+...
%         fhix_strange+fhex_pschused+fhix_pschused+fhix_inert+fhix_vispar+fhix_anml+fhix_kevis);
% fhrc = sum(squeeze(fna(:,:,1,is)).*rpt(:,:,is)*comuse.ev,3);
% fhkn = sum(squeeze(fna(:,:,1,is)).*kinrgy(:,:,is),3);
% fhti = sum(squeeze(fna(:,:,1,is)).*repmat(ti,[1,1,nsi]),3);
% fhte = fne(:,:,1).*te;
% fhpl = fhei+fhrc+fhkn+fhti+fhte;
% plot(bth.ymysep,fhpl(end,2:end-1)./bth.areadown/1E6,'parent',axbal(1),'displayname','total plasma');
% plot(bth.ymysep,fhei(end,2:end-1)./bth.areadown/1E6,'parent',axbal(1),'displayname','ion+electron heat');
% plot(bth.ymysep,fhrc(end,2:end-1)./bth.areadown/1E6,'parent',axbal(1),'displayname','surface recombination');
% plot(bth.ymysep,fhkn(end,2:end-1)./bth.areadown/1E6,'parent',axbal(1),'displayname','KE of ion flow');
% plot(bth.ymysep,fhti(end,2:end-1)./bth.areadown/1E6,'parent',axbal(1),'displayname','\Gamma_tT_i');
% plot(bth.ymysep,fhte(end,2:end-1)./bth.areadown/1E6,'parent',axbal(1),'displayname','\Gamma_tT_e');
%%
end




