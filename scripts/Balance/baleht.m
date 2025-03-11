%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baleht plots the electron internal energy balance for a given SOLPS          %
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
function baleht(balfile,indrad,indpol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nx = comuse.nx;
ny = comuse.ny;
nstra = comuse.nstra;
topix = comuse.topix+1;
topiy = comuse.topiy+1;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fhe_32');
fhex_32 = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_32 = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_52');
fhex_52 = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_52 = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_thermj');
fhex_thermj = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_thermj = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_cond');
fhex_cond = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_cond = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_dia');
fhex_dia = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_dia = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_ecrb');
fhex_ecrb = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_ecrb = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_strange');
fhex_strange = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_strange = tmp(:,:,2,1)+tmp(:,:,2,2);
tmp = ncread(balfile,'fhe_pschused');
fhex_pschused = tmp(:,:,1,1)+tmp(:,:,1,2);
fhey_pschused = tmp(:,:,2,1)+tmp(:,:,2,2);
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
%%

%% Make plots...
btp = radial_balance(...
 cat(3,fhex_32,fhex_52,fhex_cond,fhex_thermj,fhex_dia,fhex_ecrb,fhex_strange,fhex_pschused)/1E6,...
 cat(3,raddive_32,raddive_52,raddive_cond,raddive_thermj,raddive_dia,raddive_ecrb,raddive_strange,raddive_pschused,b2stbc_she,...
       sum(eirene_mc_eael_she,3),sum(eirene_mc_emel_she,3),sum(eirene_mc_eiel_she,3),sum(eirene_mc_epel_she,3),...
       b2stbm_she,ext_she,...
       b2srsm_she,b2srdt_she,b2srst_she,...
       b2sihs_diae,b2sihs_divue,b2sihs_exbe,b2sihs_joule,b2npht_shei,b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stel_she)/1E6,...
 reshe/1E6,...
 {'dA_{xu}q_{exu}/dA_{||d}',...
  'dA_{xd}q_{exd}/dA_{||d}',...
  '(\int_d^u S_{IE}^edV)/dA_{||d}',...
  '(\int_d^ures.dV)/dA_{||d}'},...
 {'fhex\_32','fhex\_52','fhex\_cond','fhex\_thermj','fhex\_dia','fhex\_ecrb','fhex\_strange','fhex\_pschused'},...
 [{'rad. diverg. fhey\_32','rad. diverg. fhey\_52','rad. diverg. fhey\_cond','rad. diverg. fhey\_thermj',...
  'rad. diverg. fhey\_dia','rad. diverg. fhey\_ecrb','rad. diverg. fhey\_strange','rad. diverg. fhey\_psch','b2stbc\_she',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'b2stbm\_she','ext\_she',...
  'b2srsm\_she','b2srdt\_she','b2srst\_she',...
  'b2sihs\_diae','b2sihs\_divue','b2sihs\_exbe','b2sihs\_joule','equipartition','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indrad,apllx,reverse,false,axbal(1:4),'MWm^{-2}',true);

areadownpol = poloidal_balance(...
 cat(3,fhex_32,fhex_52,fhex_cond,fhex_thermj,fhex_dia,fhex_ecrb,fhex_strange,fhex_pschused)/1E6,...
 cat(3,raddive_32,raddive_52,raddive_cond,raddive_thermj,raddive_dia,raddive_ecrb,raddive_strange,raddive_pschused,b2stbc_she,...
       sum(eirene_mc_eael_she,3),sum(eirene_mc_emel_she,3),sum(eirene_mc_eiel_she,3),sum(eirene_mc_epel_she,3),...
       b2stbm_she,ext_she,...
       b2srsm_she,b2srdt_she,b2srst_she,...
       b2sihs_diae,b2sihs_divue,b2sihs_exbe,b2sihs_joule,b2npht_shei,b2stbr_phys_she,b2stbr_bas_she,b2stbr_first_flight_she,b2stel_she)/1E6,...
 reshe/1E6,...
 {'dA_xq_{ex}/dA_{||d}',...
  'S_{IE}^edV/dA_{||d}',...
  'res.dV/dA_{||d}'},...
 {'fhex\_32','fhex\_52','fhex\_cond','fhex\_thermj','fhex\_dia','fhex\_ecrb','fhex\_strange','fhex\_pschused'},...
 [{'rad. diverg. fhey\_32','rad. diverg. fhey\_52','rad. diverg. fhey\_cond','rad. diverg. fhey\_thermj',...
  'rad. diverg. fhey\_dia','rad. diverg. fhey\_ecrb','rad. diverg. fhey\_strange','rad. diverg. fhey\_psch','b2stbc\_she',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'b2stbm\_she','ext\_she',...
  'b2srsm\_she','b2srdt\_she','b2srst\_she',...
  'b2sihs\_diae','b2sihs\_divue','b2sihs\_exbe','b2sihs\_joule','equipartition','b2stbr\_phys','b2stbr\_bas','b2stbr\_first\_flight'},strcat('b2stel\_she\_',comuse.species)],...
 comuse,indpol,ones(size(apllx)),reverse,false,axbal(5:7),'MWm^{-2}');

if strata_plot
    make_strata_plots({eirene_mc_eael_she/1E6},{eirene_mc_emel_she/1E6},{eirene_mc_eiel_she/1E6},{eirene_mc_epel_she/1E6},...
                      {'Strata decomp. of (\int_d^u S_{eIE}^{EIR}dV)/dA_{||d} in radial direction',...
                       'Strata decomp. of S_{eIE}^{EIR}dV/dA_{||d} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,btp.areadown,areadownpol,reverse,false);
end
%%
end




