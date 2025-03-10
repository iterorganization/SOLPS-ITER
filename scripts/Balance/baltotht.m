%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baltotht plots the total internal energy balance for a given SOLPS           %
% simulation.                                                                  %
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
% areatype:    The type of area that poloidal fluxes are divided by            %
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bth = baltotht(balfile,indrad,indpol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

%% Obtain required arrays from the simulation...
% Fluxes (electrons):
tmp = ncread(balfile,'fhe_32');
fhex_32 = tmp(:,:,1);
fhey_32 = tmp(:,:,2);
tmp = ncread(balfile,'fhe_52');
fhex_52 = tmp(:,:,1);
fhey_52 = tmp(:,:,2);
tmp = ncread(balfile,'fhe_thermj');
fhex_thermj = tmp(:,:,1);
fhey_thermj = tmp(:,:,2);
tmp = ncread(balfile,'fhe_cond');
fhex_cond = tmp(:,:,1);
fhey_cond = tmp(:,:,2);
tmp = ncread(balfile,'fhe_dia');
fhex_dia = tmp(:,:,1);
fhey_dia = tmp(:,:,2);
tmp = ncread(balfile,'fhe_ecrb');
fhex_ecrb = tmp(:,:,1);
fhey_ecrb = tmp(:,:,2);
tmp = ncread(balfile,'fhe_strange');
fhex_strange = tmp(:,:,1);
fhey_strange = tmp(:,:,2);
tmp = ncread(balfile,'fhe_pschused');
fhex_pschused = tmp(:,:,1);
fhey_pschused = tmp(:,:,2);
% Fluxes (ions):
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
try
    tmp = ncread(balfile,'fhi_vzh');
catch exception
    if strcmp(exception.identifier,'MATLAB:imagesci:netcdf:unknownLocation')
        warning('fhi_vzh not found in %s. Balance will be incomplete if the Zhdanov closure was turned on.',balfile);
        tmp=zeros(nx,ny,2);
    end
end
fhix_vzh = tmp(:,:,1);
fhiy_vzh = tmp(:,:,2);
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
    eirene_mc_eael_she = zeros(nx,ny,nstra);
    eirene_mc_emel_she = zeros(nx,ny,nstra);
    eirene_mc_eiel_she = zeros(nx,ny,nstra);
    eirene_mc_epel_she = zeros(nx,ny,nstra);
end
b2stbm_she = ncread(balfile,'b2stbm_she_bal');
ext_she = ncread(balfile,'ext_she_bal');
b2stel_she = ncread(balfile,'b2stel_she_bal');
b2srsm_she = ncread(balfile,'b2srsm_she_bal');
b2srdt_she = ncread(balfile,'b2srdt_she_bal');
b2srst_she = ncread(balfile,'b2srst_she_bal');
b2sihs_diae = ncread(balfile,'b2sihs_diae_bal');
b2sihs_divue = ncread(balfile,'b2sihs_divue_bal');
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
% Residual (electrons):
reshe = ncread(balfile,'reshe');
% Residual (ions):
reshi = ncread(balfile,'reshi');

%% Create the units string
switch areatype
    case 'parallel'
        units = 'Wm^{-2}';
    case 'contact'
        units = 'Wm^{-2}';
    case 'none'
        units = 'W';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end
%%

%% Radial divergences...
raddive_32 = zeros(nx,ny);
raddive_52 = zeros(nx,ny);
raddive_thermj = zeros(nx,ny);
raddive_cond = zeros(nx,ny);
raddive_dia = zeros(nx,ny);
raddive_ecrb = zeros(nx,ny);
raddive_strange = zeros(nx,ny);
raddive_pschused = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddive_32(ix,iy) = fhey_32(ix,iy)-fhey_32(topix(ix,iy),topiy(ix,iy));
        raddive_52(ix,iy) = fhey_52(ix,iy)-fhey_52(topix(ix,iy),topiy(ix,iy));
        raddive_thermj(ix,iy) = fhey_thermj(ix,iy)-fhey_thermj(topix(ix,iy),topiy(ix,iy));
        raddive_cond(ix,iy) = fhey_cond(ix,iy)-fhey_cond(topix(ix,iy),topiy(ix,iy));
        raddive_dia(ix,iy) = fhey_dia(ix,iy)-fhey_dia(topix(ix,iy),topiy(ix,iy));
        raddive_ecrb(ix,iy) = fhey_ecrb(ix,iy)-fhey_ecrb(topix(ix,iy),topiy(ix,iy));
        raddive_strange(ix,iy) = fhey_strange(ix,iy)-fhey_strange(topix(ix,iy),topiy(ix,iy));
        raddive_pschused(ix,iy) = fhey_pschused(ix,iy)-fhey_pschused(topix(ix,iy),topiy(ix,iy));
    end
end
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
raddivi_vzh = zeros(nx,ny);
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
        raddivi_vzh(ix,iy) = fhiy_vzh(ix,iy)-fhiy_vzh(topix(ix,iy),topiy(ix,iy));
    end
end
%%

%% Make plots...
bth = radial_balance(...
 cat(3,fhex_32,fhix_32,fhex_52,fhix_52,fhex_cond,fhix_cond,fhex_thermj,fhex_dia,fhix_dia,fhex_ecrb,fhix_ecrb,fhex_strange,...
       fhix_strange,fhex_pschused,fhix_pschused,fhix_inert,fhix_vispar,fhix_anml,fhix_kevis,fhix_vzh)/1E6,...
 cat(3,raddive_32,raddive_52,raddive_cond,raddive_thermj,raddive_dia,raddive_ecrb,raddive_strange,raddive_pschused,...
       raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,...
       raddivi_inert,raddivi_vispar,raddivi_anml,raddivi_kevis,raddivi_vzh,...
       b2stbc_she,b2stbc_shi,...
       sum(eirene_mc_eael_she,3),sum(eirene_mc_emel_she,3),sum(eirene_mc_eiel_she,3),sum(eirene_mc_epel_she,3),...
       sum(eirene_mc_eapl_shi,3),sum(eirene_mc_empl_shi,3),sum(eirene_mc_eipl_shi,3),sum(eirene_mc_eppl_shi,3),...
       b2stbm_she,b2stbm_shi,ext_she,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_she,b2srsm_shi,b2srdt_she,b2srdt_shi,b2srst_she,b2srst_shi,...
       b2sihs_diae,b2sihs_diaa,b2sihs_divue,b2sihs_divua,b2sihs_exbe,b2sihs_exba,b2sihs_visa,b2sihs_joule,b2sihs_fraa,...
       b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stbr_phys_shi,b2stbr_bas_shi,b2stbr_first_flight_shi,b2stel_she)/1E6,...
 (reshe+reshi)/1E6,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'fhex\_32','fhix\_32','fhex\_52','fhix\_52','fhex\_cond','fhix\_cond','fhex\_thermj','fhex\_dia','fhix\_dia','fhex\_ecrb','fhix\_ecrb','fhex\_strange',...
  'fhix\_strange','fhex\_pschused','fhix\_pschused','fhix\_inert','fhix\_vispar','fhix\_anml','fhix\_kevis','fhix\_vzh'},...
 [{'rad. diverg. fhey\_32','rad. diverg. fhey\_52','rad. diverg. fhey\_cond','rad. diverg. fhey\_thermj',...
  'rad. diverg. fhey\_dia','rad. diverg. fhey\_ecrb','rad. diverg. fhey\_strange','rad. diverg. fhey\_psch',...
  'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond',...
  'rad. diverg. fhiy\_dia','rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch',...
  'rad. diverg. fhiy\_inert','rad. diverg. fhiy\_vispar','rad. diverg. fhiy\_anml','rad. diverg. fhiy\_kevis','rad. diverg. fhiy\_vzh'...
  'b2stbc\_she','b2stbc\_shi',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_she','b2stbm\_shi','ext\_she','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_she','b2srsm\_shi','b2srdt\_she','b2srdt\_shi','b2srst\_she','b2srst\_shi',...
  'b2sihs\_diae','b2sihs\_diaa','b2sihs\_divue','b2sihs\_divua','b2sihs\_exbe','b2sihs\_exba','b2sihs\_visa','b2sihs\_joule','b2sihs\_fraa',...
  'b2stbr\_phys el.','b2stbr\_bas el.','b2stbr\_first\_flight el.','b2stbr\_phys ion','b2stbr\_bas ion','b2stbr\_first\_flight ion'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indrad,area_divide,reverse,false,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

areadownpol = poloidal_balance(...
 cat(3,fhex_32,fhix_32,fhex_52,fhix_52,fhex_cond,fhix_cond,fhex_thermj,fhex_dia,fhix_dia,fhex_ecrb,fhix_ecrb,fhex_strange,...
       fhix_strange,fhex_pschused,fhix_pschused,fhix_inert,fhix_vispar,fhix_anml,fhix_kevis,fhix_vzh)/1E6,...
 cat(3,raddive_32,raddive_52,raddive_cond,raddive_thermj,raddive_dia,raddive_ecrb,raddive_strange,raddive_pschused,...
       raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,...
       raddivi_inert,raddivi_vispar,raddivi_anml,raddivi_kevis,raddivi_vzh,...
       b2stbc_she,b2stbc_shi,...
       sum(eirene_mc_eael_she,3),sum(eirene_mc_emel_she,3),sum(eirene_mc_eiel_she,3),sum(eirene_mc_epel_she,3),...
       sum(eirene_mc_eapl_shi,3),sum(eirene_mc_empl_shi,3),sum(eirene_mc_eipl_shi,3),sum(eirene_mc_eppl_shi,3),...
       b2stbm_she,b2stbm_shi,ext_she,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_she,b2srsm_shi,b2srdt_she,b2srdt_shi,b2srst_she,b2srst_shi,...
       b2sihs_diae,b2sihs_diaa,b2sihs_divue,b2sihs_divua,b2sihs_exbe,b2sihs_exba,b2sihs_visa,b2sihs_joule,b2sihs_fraa,...
       b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stbr_phys_shi,b2stbr_bas_shi,b2stbr_first_flight_shi,b2stel_she)/1E6,...
 (reshe+reshi)/1E6,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'fhex\_32','fhix\_32','fhex\_52','fhix\_52','fhex\_cond','fhix\_cond','fhex\_thermj','fhex\_dia','fhix\_dia','fhex\_ecrb','fhix\_ecrb','fhex\_strange',...
  'fhix\_strange','fhex\_pschused','fhix\_pschused','fhix\_inert','fhix\_vispar','fhix\_anml','fhix\_kevis','fhix\_vzh'},...
 [{'rad. diverg. fhey\_32','rad. diverg. fhey\_52','rad. diverg. fhey\_cond','rad. diverg. fhey\_thermj',...
  'rad. diverg. fhey\_dia','rad. diverg. fhey\_ecrb','rad. diverg. fhey\_strange','rad. diverg. fhey\_psch',...
  'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond',...
  'rad. diverg. fhiy\_dia','rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch',...
  'rad. diverg. fhiy\_inert','rad. diverg. fhiy\_vispar','rad. diverg. fhiy\_anml','rad. diverg. fhiy\_kevis','rad. diverg. fhiy\_vzh',...
  'b2stbc\_she','b2stbc\_shi',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_she','b2stbm\_shi','ext\_she','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_she','b2srsm\_shi','b2srdt\_she','b2srdt\_shi','b2srst\_she','b2srst\_shi',...
  'b2sihs\_diae','b2sihs\_diaa','b2sihs\_divue','b2sihs\_divua','b2sihs\_exbe','b2sihs\_exba','b2sihs\_visa','b2sihs\_joule','b2sihs\_fraa',...
  'b2stbr\_phys el.','b2stbr\_bas el.','b2stbr\_first\_flight el.','b2stbr\_phys ion','b2stbr\_bas ion','b2stbr\_first\_flight ion'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indpol,area_divide,reverse,false,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({eirene_mc_eael_she/1E6,eirene_mc_eapl_shi/1E6},{eirene_mc_emel_she/1E6,eirene_mc_empl_shi/1E6},...
                      {eirene_mc_eiel_she/1E6,eirene_mc_eipl_shi/1E6},{eirene_mc_epel_she/1E6,eirene_mc_eppl_shi/1E6},...
                      {['Strata decomp. of (\int_d^uS_{eIE}^{EIR}dV)/dA_{||d} and ',...
                        '(\int_d^uS_{iIE}^{EIR}dV)/dA_{||d} in radial direction'],...
                       ['Strata decomp. of S_{eIE}^{EIR}dV/dA_{||d}$ and ',...
                        'S_{iIE}^{EIR}dV/dA_{||d} in poloidal direction']},...
                      {'el','ion'},comuse,indrad,indpol,nstra,axstrat,axbal,bth.area_divide,areadownpol,reverse,false);
end
%%
end




