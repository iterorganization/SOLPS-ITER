%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baleht plots the electron internal energy balance for a given SOLPS          %
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
function baleht(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nstra = comuse.nstra;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fhe_32');
fhex_32 = tmp(:,1);
fhey_32 = tmp(:,2);
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
% Sources:
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
b2npht_shei = -ncread(balfile,'b2npht_shei_bal');
% Residual:
reshe = ncread(balfile,'reshe');
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
%%

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
    otherwise % Poloidal + radial component
        fhe_32 = fhex_32 + fhey_32;
        fhe_52 = fhex_52 + fhey_52;
        fhe_thermj = fhex_thermj + fhey_thermj;
        fhe_cond = fhex_cond + fhey_cond;
        fhe_dia = fhex_dia + fhey_dia;
        fhe_ecrb = fhex_ecrb + fhey_ecrb;
        fhe_strange = fhex_strange + fhey_strange;
        fhe_pschused = fhex_pschused + fhey_pschused;
end

%% Calculate the radial divergences...
raddiv_32 = raddiv(fhex_32,fhey_32,comuse,indrad,facesup,facesdown,areatype);
raddiv_52 = raddiv(fhex_52,fhey_52,comuse,indrad,facesup,facesdown,areatype);
raddiv_thermj = raddiv(fhex_thermj,fhey_thermj,comuse,indrad,facesup,facesdown,areatype);
raddiv_cond = raddiv(fhex_cond,fhey_cond,comuse,indrad,facesup,facesdown,areatype);
raddiv_dia = raddiv(fhex_dia,fhey_dia,comuse,indrad,facesup,facesdown,areatype);
raddiv_ecrb = raddiv(fhex_ecrb,fhey_ecrb,comuse,indrad,facesup,facesdown,areatype);
raddiv_strange = raddiv(fhex_strange,fhey_strange,comuse,indrad,facesup,facesdown,areatype);
raddiv_pschused = raddiv(fhex_pschused,fhey_pschused,comuse,indrad,facesup,facesdown,areatype);

%% Fluxes required to calculate the divergence of the fluxes in indpol
fhe2_32 = raddiv_pol(fhex_32,fhey_32,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_52 = raddiv_pol(fhex_52,fhey_52,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_thermj = raddiv_pol(fhex_thermj,fhey_thermj,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_cond = raddiv_pol(fhex_cond,fhey_cond,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_dia = raddiv_pol(fhex_dia,fhey_dia,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_ecrb = raddiv_pol(fhex_ecrb,fhey_ecrb,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_strange = raddiv_pol(fhex_strange,fhey_strange,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fhe2_pschused = raddiv_pol(fhex_pschused,fhey_pschused,comuse,indpol,facesup_pol,facesdown_pol,areatype);

%% Make plots...
btp = radial_balance(...
 cat(2,fhe_32,fhe_52,fhe_cond,fhe_thermj,fhe_dia,fhe_ecrb,fhe_strange,fhe_pschused)/1E6,...
 cat(2,b2stbc_she,...
       sum(eirene_mc_eael_she,2),sum(eirene_mc_emel_she,2),sum(eirene_mc_eiel_she,2),sum(eirene_mc_epel_she,2),...
       b2stbm_she,ext_she,...
       b2srsm_she,b2srdt_she,b2srst_she,...
       b2sihs_diae,b2sihs_divue,b2sihs_exbe,b2sihs_joule,b2npht_shei,b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stel_she)/1E6,...
       cat(2,raddiv_32,raddiv_52,raddiv_cond,raddiv_thermj,raddiv_dia,raddiv_ecrb,raddiv_strange,raddiv_pschused)/1E6,...
 reshe/1E6,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'fhe\_32','fhe\_52','fhe\_cond','fhe\_thermj','fhe\_dia','fhe\_ecrb','fhe\_strange','fhe\_pschused'},...
 [{'rad. diverg. fhe\_32','rad. diverg. fhe\_52','rad. diverg. fhe\_cond','rad. diverg. fhe\_thermj',...
  'rad. diverg. fhe\_dia','rad. diverg. fhe\_ecrb','rad. diverg. fhe\_strange','rad. diverg. fhe\_psch','b2stbc\_she',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'b2stbm\_she','ext\_she',...
  'b2srsm\_she','b2srdt\_she','b2srst\_she',...
  'b2sihs\_diae','b2sihs\_divue','b2sihs\_exbe','b2sihs\_joule','equipartition','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indrad,facesup,facesdown,area_divide,reverse,false,axbal(1:4),units,makeplot,areaend);

areadownpol = poloidal_balance(...
 cat(2,fhe_32,fhe_52,fhe_cond,fhe_thermj,fhe_dia,fhe_ecrb,fhe_strange,fhe_pschused)/1E6,...
 cat(2,fhe2_32,fhe2_52,fhe2_cond,fhe2_thermj,fhe2_dia,fhe2_ecrb,fhe2_strange,fhe2_pschused)/1E6,...
 cat(2,b2stbc_she,...
       sum(eirene_mc_eael_she,2),sum(eirene_mc_emel_she,2),sum(eirene_mc_eiel_she,2),sum(eirene_mc_epel_she,2),...
       b2stbm_she,ext_she,...
       b2srsm_she,b2srdt_she,b2srst_she,...
       b2sihs_diae,b2sihs_divue,b2sihs_exbe,b2sihs_joule,b2npht_shei,b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stel_she)/1E6,...
 reshe/1E6,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'fhe\_32','fhe\_52','fhe\_cond','fhe\_thermj','fhe\_dia','fhe\_ecrb','fhe\_strange','fhe\_pschused'},...
 [{'rad. diverg. fhe\_32','rad. diverg. fhe\_52','rad. diverg. fhe\_cond','rad. diverg. fhe\_thermj',...
  'rad. diverg. fhe\_dia','rad. diverg. fhe\_ecrb','rad. diverg. fhe\_strange','rad. diverg. fhe\_psch','b2stbc\_she',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'b2stbm\_she','ext\_she',...
  'b2srsm\_she','b2srdt\_she','b2srst\_she',...
  'b2sihs\_diae','b2sihs\_divue','b2sihs\_exbe','b2sihs\_joule','equipartition','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indpol,facesup_pol,facesdown_pol,area_divide,reverse,false,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({eirene_mc_eael_she/1E6},{eirene_mc_emel_she/1E6},{eirene_mc_eiel_she/1E6},{eirene_mc_epel_she/1E6},...
                      {'Strata decomp. of (\int_d^u S_{eIE}^{EIR}dV)/dA_{||d} in radial direction',...
                       'Strata decomp. of S_{eIE}^{EIR}dV/dA_{||d} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,btp.areadown,areadownpol,reverse,false);
end
%%
end




