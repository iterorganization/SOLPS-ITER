%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balmom plots the momentum balance for a given SOLPS simulation.              %
% balfile:     Full path to balance.nc file                                    %
% indrad:      Logical matrix of size nCv that is true for cells where         %
%              radial balance should be performed                              %
% indpol:      Logical matrix of size nCv that is true for cells where         %
%              poloidal balance should be performed                            %
% facesup:     List of faces of the upstream boundary of indrad                %
% facesdown:   List of faces of the downstream boundary of indrad              %
% facesup_pol: List of faces of the upstream boundary of indpol                %
% facesdown_pol: List of faces of the downstream boundary of indpol            %
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
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) August 2024 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function balmom(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,isplot,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nstra = comuse.nstra;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fmo_flua');
fmox_flua = sum(tmp(:,1,isplot),3);
fmoy_flua = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fmo_cvsa');
fmox_cvsa = sum(tmp(:,1,isplot),3);
fmoy_cvsa = sum(tmp(:,2,isplot),3);
tmp = ncread(balfile,'fmo_hybr');
fmox_hybr = sum(tmp(:,1,isplot),3);
fmoy_hybr = sum(tmp(:,2,isplot),3);
% Sources:
tmp = ncread(balfile,'b2stbr_phys_smo_bal');
b2stbr_phys_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stbr_bas_smo_bal');
b2stbr_bas_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stbc_smo_bal');
b2stbc_smo = sum(tmp(:,isplot),2);
if (comuse.b2mndr_eirene~=0)
    tmp = ncread(balfile,'eirene_mc_mapl_smo_bal');
    eirene_mc_mapl_smo = sum(tmp(:,isplot,:),2);
    tmp = ncread(balfile,'eirene_mc_mmpl_smo_bal');
    eirene_mc_mmpl_smo = sum(tmp(:,isplot,:),2);
    tmp = ncread(balfile,'eirene_mc_mipl_smo_bal');
    eirene_mc_mipl_smo = sum(tmp(:,isplot,:),2);
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
    eirene_mc_mppl_smo = sum(tmp(:,isplot,:),2);
else
    eirene_mc_mapl_smo = zeros(nCv,1,nstra);
    eirene_mc_mmpl_smo = zeros(nCv,1,nstra);
    eirene_mc_mipl_smo = zeros(nCv,1,nstra);
    eirene_mc_mppl_smo = zeros(nCv,1,nstra);
end
tmp = ncread(balfile,'b2stbm_smo_bal');
b2stbm_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'ext_smo_bal');
ext_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stel_smq_ion_bal');
b2stel_smq_ion = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stel_smq_rec_bal');
b2stel_smq_rec = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2stcx_smq_bal');
b2stcx_smq = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2srsm_smo_bal');
b2srsm_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2srdt_smo_bal');
b2srdt_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2srst_smo_bal');
b2srst_smo = sum(tmp(:,isplot),2);

% b2sigp_style=='1':
tmp = ncread(balfile,'b2sifr_smoch_bal');
b2sifr_smoch = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sifr_smotf_ehxp_bal');
b2sifr_smotf_ehxb = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sifr_smotf_cthe_bal');
b2sifr_smotf_cthe = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sifr_smotf_cthi_bal');
b2sifr_smotf_cthi = sum(tmp(:,isplot),2);
% b2sigp_style=='2':
tmp = ncread(balfile,'b2sifr_smofrea_bal');
b2sifr_smofrea = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sifr_smofria_bal');
b2sifr_smofria = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sifr_smotfea_bal');
b2sifr_smotfea = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sifr_smotfia_bal');
b2sifr_smotfia = sum(tmp(:,isplot),2);

tmp = ncread(balfile,'b2siav_smovh_bal');
b2siav_smovh = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2siav_smovv_bal');
b2siav_smovv = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sicf_smo_bal');
b2sicf_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sian_smo_bal');
b2sian_smo = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2nxdv_smo_bal');
b2nxdv_smo = sum(tmp(:,isplot),2);

tmp = ncread(balfile,'b2sigp_smogpi_bal');
b2sigp_smogpi = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sigp_smogpe_bal');
b2sigp_smogpe = sum(tmp(:,isplot),2);
tmp = ncread(balfile,'b2sigp_smogpgr_bal');
b2sigp_smogpgr = sum(tmp(:,isplot),2);

% Residual:
tmp = ncread(balfile,'resmo');
resmo = sum(tmp(:,isplot),2);
%%

%% Create the units string
switch areatype
    case 'parallel'
        units = 'Nm^{-2}';
    case 'contact'
        units = 'Nm^{-2}';
    case 'none'
        units = 'N';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end
%%

%% Account for hz
hz = (1-comuse.b2mndr_hz)+comuse.b2mndr_hz*comuse.fcHz;
area_divide = area_divide.*hz;

%% Calculate the total flux depending on areatype
switch areatype
    case 'parallel' % Retain only the poloidal component
        fmo_flua = fmox_flua;
        fmo_cvsa = fmox_cvsa;
        fmo_hybr = fmox_hybr;
    otherwise % Poloidal + radial component
        fmo_flua = fmox_flua + fmoy_flua;
        fmo_cvsa = fmox_cvsa + fmoy_cvsa;
        fmo_hybr = fmox_hybr + fmoy_hybr;
end

%% Calculate the radial divergence...
raddiv_flua = raddiv(fmox_flua,fmoy_flua,comuse,indrad,facesup,facesdown,areatype);
raddiv_visc = raddiv(fmox_cvsa,fmoy_cvsa,comuse,indrad,facesup,facesdown,areatype);
raddiv_hybr = raddiv(fmox_hybr,fmoy_hybr,comuse,indrad,facesup,facesdown,areatype);

%% Fluxes required to calculate the divergence of the fluxes in indpol
fmo2_flua = raddiv_pol(fmox_flua,fmoy_flua,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fmo2_cvsa = raddiv_pol(fmox_cvsa,fmoy_cvsa,comuse,indpol,facesup_pol,facesdown_pol,areatype);
fmo2_hybr = raddiv_pol(fmox_hybr,fmoy_hybr,comuse,indpol,facesup_pol,facesdown_pol,areatype);

%% Calculate the poloidal divergence of the viscous, hybrid correction and new ion viscosity form parts...
% visc = zeros(nx,ny);
% hybr = zeros(nx,ny);
% for iy=1:ny
%     for ix=1:nx
%         if rightix(ix,iy)>nx
%             continue;
%         end
%         visc(ix,iy) = fmox_cvsa(ix,iy)-fmox_cvsa(rightix(ix,iy),rightiy(ix,iy));
%         hybr(ix,iy) = fmox_hybr(ix,iy)-fmox_hybr(rightix(ix,iy),rightiy(ix,iy));
%     end
% end
%%

%% Make plots...
bm = radial_balance(...
 cat(2,fmo_flua,fmo_cvsa,fmo_hybr),...
 cat(2,sum(eirene_mc_mapl_smo,3),sum(eirene_mc_mmpl_smo,3),sum(eirene_mc_mipl_smo,3),sum(eirene_mc_mppl_smo,3),...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,...
       b2sifr_smoch,b2sifr_smotf_ehxb,b2sifr_smotf_cthe,b2sifr_smotf_cthi,...
       b2sifr_smofrea,b2sifr_smofria,b2sifr_smotfea,b2sifr_smotfia,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2sian_smo,b2nxdv_smo,...
       b2sigp_smogpi,b2sigp_smogpe,b2sigp_smogpgr,...
       b2stbr_phys_smo,b2stbr_bas_smo,...
       b2stbm_smo,ext_smo,...
       b2srsm_smo,b2srdt_smo,b2srst_smo,b2stbc_smo),...
 cat(2,raddiv_flua,raddiv_visc,raddiv_hybr),...
 resmo,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'convected','viscous','hybrid'},...
 {'net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'ion-ion friction (b2sigp==1)','thermal force Ehat component (b2sigp==1)','electron thermal force (b2sigp==1)','ion thermal force (b2sigp==1)',...
  'electron-ion friction (b2sigp==2)','ion-ion friction (b2sigp==2)','electron thermal force (b2sigp==2)','ion thermal force (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'ion stat. press. grad.','el. stat.press. grad. (b2sigp==1) or po. grad. (b2sigp==2)','pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc'},...
 comuse,indrad,facesup,facesdown,area_divide,reverse,true,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

areadownpol = poloidal_balance(...
 cat(2,fmo_flua,fmo_cvsa,fmo_hybr),...
 cat(2,fmo2_flua,fmo2_cvsa,fmo2_hybr),...
 cat(2,sum(eirene_mc_mapl_smo,3),sum(eirene_mc_mmpl_smo,3),sum(eirene_mc_mipl_smo,3),sum(eirene_mc_mppl_smo,3),...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,...
       b2sifr_smoch,b2sifr_smotf_ehxb,b2sifr_smotf_cthe,b2sifr_smotf_cthi,...
       b2sifr_smofrea,b2sifr_smofria,b2sifr_smotfea,b2sifr_smotfia,...
       b2siav_smovh,b2siav_smovv,b2sicf_smo,b2sian_smo,b2nxdv_smo,...
       b2sigp_smogpi,b2sigp_smogpe,b2sigp_smogpgr,...
       b2stbr_phys_smo,b2stbr_bas_smo,...
       b2stbm_smo,ext_smo,...
       b2srsm_smo,b2srdt_smo,b2srst_smo,b2stbc_smo),...
 resmo,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'convected','viscous','hybrid'},...
 {'net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'ion-ion friction (b2sigp==1)','thermal force Ehat component (b2sigp==1)','electron thermal force (b2sigp==1)','ion thermal force (b2sigp==1)',...
  'electron-ion friction (b2sigp==2)','ion-ion friction (b2sigp==2)','electron thermal force (b2sigp==2)','ion thermal force (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'ion stat. press. grad.','el. stat.press. grad. (b2sigp==1) or po. grad. (b2sigp==2)','pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc'},...
 comuse,indpol,facesup_pol,facesdown_pol,area_divide,reverse,true,axbal(5:7),units,areaend,polbaldist);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)},{squeeze(eirene_mc_mmpl_smo)},{squeeze(eirene_mc_mipl_smo)},{squeeze(eirene_mc_mppl_smo)},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,bm.area_divide,areadownpol,reverse,true);
end
%%
end




