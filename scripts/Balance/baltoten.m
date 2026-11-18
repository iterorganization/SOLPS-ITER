%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baltoten plots the total energy balance (internal energy of electrons and    %
% ions, and kinetic energy of the ions) for a given SOLPS simulation.          %
% B2.5 solves no total energy equation. Per cell, the balance is built from    %
% the equations it does solve: electron energy + ion energy + sum over the     %
% ion species of (u times the parallel momentum equation - m*u^2/2 times the   %
% continuity equation). Every term of these equations in balance.nc is         %
% multiplied in the same way, so the balance closes against                    %
%   reshe + reshi + sum_is (u*resmo - m*u^2/2*resco)                           %
% as well as the balances of these equations do.                               %
% For the flux terms, u_cell times the net inflow of a flux F is shown as the  %
% kinetic energy flux u_face*F on the faces plus the cell term                 %
% sum over the faces of (u_cell - u_face)*F, with u_face from intface.         %
% balfile:     Full path to balance.nc file                                    %
% indrad:      Logical matrix of size nCv that is true for cells where radial  %
%              balance should be performed                                     %
% indpol:      Logical matrix of size nCv that is true for cells where         %
%              poloidal balance should be performed                            %
% facesup:     List of faces of the upstream boundary of indrad                %
% facesdown:   List of faces of the downstream boundary of indrad              %
% facesup_pol: List of faces of the upstream boundary of indpol                %
% facesdown_pol: List of faces of the downstream boundary of indpol            %
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
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) August 2024 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bth = baltoten(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,areaend,area_divide,areatype,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nFc = comuse.nFc;
ns = comuse.ns;
nstra = comuse.nstra;
eirene = comuse.b2mndr_eirene~=0;

%% Internal energy of electrons and ions (as in baltotht)
% Fluxes:
hname = {'fhe_32','fhi_32','fhe_52','fhi_52','fhe_cond','fhi_cond',...
    'fhe_thermj','fhe_dia','fhi_dia','fhe_ecrb','fhi_ecrb','fhe_strange',...
    'fhi_strange','fhe_pschused','fhi_pschused','fhi_inert','fhi_vispar',...
    'fhi_anml','fhi_kevis','fhi_visq','fhi_visper','fhi_vzh'};
hfx = zeros(nFc,numel(hname));
hfy = zeros(nFc,numel(hname));
for k = 1:numel(hname)
    tmp = ncread_opt(balfile,hname{k},[nFc 2]);
    hfx(:,k) = tmp(:,1);
    hfy(:,k) = tmp(:,2);
end
% Sources (one column each):
sname = {'b2stbc_she_bal','b2stbc_shi_bal','b2stbm_she_bal',...
    'b2stbm_shi_bal','ext_she_bal','ext_shi_bal','b2stel_shi_ion_bal',...
    'b2stel_shi_rec_bal','b2stcx_shi_bal','b2srsm_she_bal',...
    'b2srsm_shi_bal','b2srdt_she_bal','b2srdt_shi_bal','b2srst_she_bal',...
    'b2srst_shi_bal','b2sihs_diae_bal','b2sihs_diaa_bal',...
    'b2sihs_divue_bal','b2sihs_divua_bal','b2sihs_exbe_bal',...
    'b2sihs_exba_bal','b2sihs_visa_bal','b2sihs_joule_bal',...
    'b2sihs_fraa_bal','b2stbr_phys_she_bal',...
    'b2stbr_first_flight_she_bal','b2stbr_phys_shi_bal',...
    'b2stbr_first_flight_shi_bal'};
snew = {'b2shdt_she_bal','b2shdt_shi_bal'};
hsrc = zeros(nCv,numel(sname)+numel(snew)+5);
for k = 1:numel(sname)
    hsrc(:,k) = ncread(balfile,sname{k});
end
for k = 1:numel(snew)
    hsrc(:,numel(sname)+k) = ncread_opt(balfile,snew{k},[nCv 1]);
end
% electron energy of the atomic processes by part, all species together
[tmp,parts] = ncread_opt(balfile,'b2stel_rqrad_bal',[nCv ns],...
    'b2stel_she_bal');
hsrc(:,end-4) = sum(tmp,2);
rqrad = 'b2stel\_rqrad';
if ~parts, rqrad = 'b2stel\_she'; end    % older B2.5: b2stel_she_bal
hsrc(:,end-3) = sum(ncread_opt(balfile,'b2stel_rqbrm_bal',[nCv ns]),2);
hsrc(:,end-2) = sum(ncread_opt(balfile,'b2stel_iz_bal',[nCv ns]),2);
hsrc(:,end-1) = sum(ncread_opt(balfile,'b2stel_rc_bal',[nCv ns]),2);
% EIRENE, all strata together
if eirene
    hsrc(:,end) = sum(ncread(balfile,'eirene_mc_eael_she_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_emel_she_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_eiel_she_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_epel_she_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_eapl_shi_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_empl_shi_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_eipl_shi_bal'),2) + ...
        sum(ncread(balfile,'eirene_mc_eppl_shi_bal'),2);
end
hsname = [strrep(strrep([sname,snew],'_bal',''),'_','\_'),...
    {rqrad,'b2stel\_rqbrm','b2stel\_iz','b2stel\_rc',...
    'eirene\_mc el. and ion'}];
% (equipartition, b2npht_shei_bal, cancels between electrons and ions)
reshe = ncread(balfile,'reshe');
reshi = ncread(balfile,'reshi');

%% Kinetic energy of the ions
% Parallel momentum: fluxes (per species) and sources
fmo = {ncread(balfile,'fmo_flua'),ncread(balfile,'fmo_cvsa'),...
    ncread(balfile,'fmo_hybr')};
mname = {'b2stel_smq_ion_bal','b2stel_smq_rec_bal','b2stcx_smq_bal',...
    'b2sifr_smoch_bal','b2sifr_smotf_ehxp_bal','b2sifr_smotf_cthe_bal',...
    'b2sifr_smotf_cthi_bal','b2sifr_smofrea_bal','b2sifr_smofria_bal',...
    'b2sifr_smotfea_bal','b2sifr_smotfia_bal','b2siav_smovh_bal',...
    'b2siav_smovv_bal','b2siav_smovi_bal','b2sicf_smo_bal',...
    'b2sian_smo_bal','b2nxdv_smo_bal','b2sigp_smogpi_bal',...
    'b2sigp_smogpe_bal','b2sigp_smogpgr_bal','b2stbr_phys_smo_bal',...
    'b2stbm_smo_bal','ext_smo_bal','b2srsm_smo_bal','b2srdt_smo_bal',...
    'b2srst_smo_bal','b2stbc_smo_bal'};
mnew = {'b2smdt_smo_bal'};
% groups of momentum sources shown together
mgroup = [1 1 1 2 2 2 2 2 2 2 2 3 3 3 4 4 4 5 5 5 4 4 4 4 4 4 4 4];
smom = cell(1,numel(mname)+numel(mnew));
for k = 1:numel(mname)
    smom{k} = ncread(balfile,mname{k});
end
for k = 1:numel(mnew)
    smom{numel(mname)+k} = ncread_opt(balfile,mnew{k},[nCv ns]);
end
if eirene
    smom{end+1} = squeeze(sum(ncread(balfile,'eirene_mc_mapl_smo_bal') + ...
        ncread(balfile,'eirene_mc_mmpl_smo_bal') + ...
        ncread(balfile,'eirene_mc_mipl_smo_bal') + ...
        ncread(balfile,'eirene_mc_mppl_smo_bal'),3));
    mgroup(end+1) = 6;
end
resmo = ncread(balfile,'resmo');
% Continuity: flux (sum of its parts, per species) and sources
fname = {'fna_pinch','fna_pll','fna_ecrb','fna_dia','fna_ch',...
    'fna_nanom','fna_panom','fna_pschused'};
fna = zeros(nFc,2,ns);
for k = 1:numel(fname)
    fna = fna + ncread_opt(balfile,fname{k},[nFc 2 ns],...
        strrep(fname{k},'ecrb','drift'));   % older B2.5: fna_drift
end
pname = {'b2stbr_phys_sna_bal','b2stbr_first_flight_sna_bal',...
    'b2stbc_sna_bal','b2stbm_sna_bal','ext_sna_bal',...
    'b2stel_sna_ion_bal','b2stel_sna_rec_bal','b2stcx_sna_bal',...
    'b2srsm_sna_bal','b2srdt_sna_bal','b2srst_sna_bal'};
pnew = {'b2scdt_sna_bal'};
spart = zeros(nCv,ns);
for k = 1:numel(pname)
    spart = spart + ncread(balfile,pname{k});
end
for k = 1:numel(pnew)
    spart = spart + ncread_opt(balfile,pnew{k},[nCv ns]);
end
spart_eir = zeros(nCv,ns);
if eirene
    spart_eir = squeeze(sum(ncread(balfile,'eirene_mc_papl_sna_bal') + ...
        ncread(balfile,'eirene_mc_pmpl_sna_bal') + ...
        ncread(balfile,'eirene_mc_pipl_sna_bal') + ...
        ncread(balfile,'eirene_mc_pppl_sna_bal'),3)) + ...
        ncread(balfile,'eirene_mc_core_sna_bal');
end
resco = ncread(balfile,'resco');
ua = ncread(balfile,'ua');

% Kinetic energy terms, summed over the ion species:
% fluxes on the faces (convected, viscous, hybrid) and cell sources
kfx = zeros(nFc,3);
kfy = zeros(nFc,3);
ksrc = zeros(nCv,9);
kres = zeros(nCv,1);
for is = find(comuse.za>0)'
    m = comuse.am(is)*comuse.mp;
    u = ua(:,is);
    uf = intface(u,comuse);
    g = -0.5*m*u.^2;
    gf = -0.5*m*uf.^2;
    for k = 1:3
        [fx,fy,kcell] = kinetic_flux(fmo{k}(:,1,is),fmo{k}(:,2,is),u,uf,comuse);
        kfx(:,k) = kfx(:,k) + fx;
        kfy(:,k) = kfy(:,k) + fy;
        ksrc(:,9) = ksrc(:,9) + kcell;
    end
    [fx,fy,kcell] = kinetic_flux(fna(:,1,is),fna(:,2,is),g,gf,comuse);
    kfx(:,1) = kfx(:,1) + fx;
    kfy(:,1) = kfy(:,1) + fy;
    ksrc(:,9) = ksrc(:,9) + kcell;
    for k = 1:numel(smom)
        ksrc(:,mgroup(k)) = ksrc(:,mgroup(k)) + u.*smom{k}(:,is);
    end
    ksrc(:,7) = ksrc(:,7) + g.*spart(:,is);
    ksrc(:,8) = ksrc(:,8) + g.*spart_eir(:,is);
    kres = kres + u.*resmo(:,is) + g.*resco(:,is);
end
kfname = {'kinetic, convected','kinetic, viscous','kinetic, hybrid'};
ksname = {'u x (ionisation, recombination, CX)',...
    'u x (friction, thermal forces)','u x viscosity',...
    'u x other momentum sources','u x (static pressure, E-field)',...
    'u x EIRENE momentum','-mu^2/2 x B2.5 particle sources',...
    '-mu^2/2 x EIRENE particle sources','kinetic energy: cell to face'};

%% Create the units string
switch areatype
    case {'parallel','contact'}
        units = 'MWm^{-2}';
    case 'none'
        units = 'MW';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end

%% Flux and divergences of all the flux terms
fx = [hfx,kfx];
fy = [hfy,kfy];
switch areatype
    case 'parallel' % Retain only the poloidal component
        flux = fx;
    otherwise % Poloidal + radial component
        flux = fx + fy;
end
nf = size(fx,2);
divrad = zeros(nCv,nf);
divpol = zeros(nCv,nf);
for k = 1:nf
    divrad(:,k) = raddiv(fx(:,k),fy(:,k),comuse,facesup,facesdown,areatype);
    divpol(:,k) = raddiv(fx(:,k),fy(:,k),comuse,[],[],areatype);
end
fluxname = [strrep(hname,'_','\_'),kfname];
srcname = [strcat({'rad. diverg. '},fluxname),hsname,ksname];
res = reshe + reshi + kres;

%% Make plots...
bth = radial_balance(flux/1E6,[divrad,hsrc,ksrc]/1E6,res/1E6,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 fluxname,srcname,comuse,indrad,facesup,facesdown,area_divide,reverse,...
 false,axbal(1:4),units,makeplot,areaend);

if ~makeplot
    return
end

pb = poloidal_balance(flux/1E6,[divpol,hsrc,ksrc]/1E6,res/1E6,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 fluxname,srcname,comuse,indpol,facesup_pol,facesdown_pol,area_divide,...
 reverse,false,axbal(5:7),units,areaend,polbaldist);

if strata_plot && eirene
    eael = ncread(balfile,'eirene_mc_eael_she_bal');
    eapl = ncread(balfile,'eirene_mc_eapl_shi_bal');
    emel = ncread(balfile,'eirene_mc_emel_she_bal');
    empl = ncread(balfile,'eirene_mc_empl_shi_bal');
    eiel = ncread(balfile,'eirene_mc_eiel_she_bal');
    eipl = ncread(balfile,'eirene_mc_eipl_shi_bal');
    epel = ncread(balfile,'eirene_mc_epel_she_bal');
    eppl = ncread(balfile,'eirene_mc_eppl_shi_bal');
    make_strata_plots({eael/1E6,eapl/1E6},{emel/1E6,empl/1E6},...
                      {eiel/1E6,eipl/1E6},{epel/1E6,eppl/1E6},...
                      {['Strata decomp. of (\int_d^uS_{eIE}^{EIR}dV)/dA_{||d} and ',...
                        '(\int_d^uS_{iIE}^{EIR}dV)/dA_{||d} in radial direction'],...
                       ['Strata decomp. of S_{eIE}^{EIR}dV/dA_{||d}$ and ',...
                        'S_{iIE}^{EIR}dV/dA_{||d} in poloidal direction']},...
                      {'el','ion'},comuse,indrad,indpol,nstra,axstrat,axbal,bth.area_divide,pb.area_divide,reverse,false,bth.index,pb.pbCv,pb.pbCvP);
end
%%
end

% Kinetic energy flux on the faces (the multiplier on the face times the
% flux) and the cell term: sum over the faces of the cell of (multiplier in
% the cell - multiplier on the face) times the inflow. Their total over a
% cell is the multiplier in the cell times the net inflow into it.
function [fx,fy,kcell] = kinetic_flux(flx,fly,uc,uf,comuse)
fx = uf.*flx;
fy = uf.*fly;
f = flx + fly;
c1 = double(comuse.fcCv(:,1));
c2 = double(comuse.fcCv(:,2));
kcell = accumarray(c1,-(uc(c1)-uf).*f,[comuse.nCv 1]) + ...
       accumarray(c2,(uc(c2)-uf).*f,[comuse.nCv 1]);
end
