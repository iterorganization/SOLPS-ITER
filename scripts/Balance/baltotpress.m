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
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function baltotpress(balfile,indrad,indpol,facesup,facesdown,facesup_pol,facesdown_pol,comuse,axbal,reverse,strata_plot,axstrat,makeplot,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nFc = comuse.nFc;
nstra = comuse.nstra;
za = comuse.za;

%% Obtain required arrays from the simulation...
% Fluxes:
tmp = ncread(balfile,'fmo_flua');
fmox_flua = sum(tmp(:,1,za>0),3);
fmoy_flua = sum(tmp(:,2,za>0),3);
tmp = ncread(balfile,'fmo_cvsa');
fmox_cvsa = sum(tmp(:,1,za>0),3);
fmoy_cvsa = sum(tmp(:,2,za>0),3);
tmp = ncread(balfile,'fmo_hybr');
fmox_hybr = sum(tmp(:,1,za>0),3);
fmoy_hybr = sum(tmp(:,2,za>0),3);
% Sources:
tmp = ncread(balfile,'b2stbr_phys_smo_bal');
b2stbr_phys_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2stbr_bas_smo_bal');
b2stbr_bas_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2stbc_smo_bal');
b2stbc_smo = sum(tmp(:,za>0),2);
if (comuse.b2mndr_eirene~=0)
    tmp = ncread(balfile,'eirene_mc_mapl_smo_bal');
    eirene_mc_mapl_smo = sum(tmp(:,za>0,:),2);
    tmp = ncread(balfile,'eirene_mc_mmpl_smo_bal');
    eirene_mc_mmpl_smo = sum(tmp(:,za>0,:),2);
    tmp = ncread(balfile,'eirene_mc_mipl_smo_bal');
    eirene_mc_mipl_smo = sum(tmp(:,za>0,:),2);
    tmp = ncread(balfile,'eirene_mc_cppv_smo_bal');
    eirene_mc_cppv_smo = sum(tmp(:,za>0,:),2);
else
    eirene_mc_mapl_smo = zeros(nCv,1,nstra);
    eirene_mc_mmpl_smo = zeros(nCv,1,nstra);
    eirene_mc_mipl_smo = zeros(nCv,1,nstra);
    eirene_mc_cppv_smo = zeros(nCv,1,nstra);
end
tmp = ncread(balfile,'b2stbm_smo_bal');
b2stbm_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'ext_smo_bal');
ext_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2stel_smq_ion_bal');
b2stel_smq_ion = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2stel_smq_rec_bal');
b2stel_smq_rec = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2stcx_smq_bal');
b2stcx_smq = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2srsm_smo_bal');
b2srsm_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2srdt_smo_bal');
b2srdt_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2srst_smo_bal');
b2srst_smo = sum(tmp(:,za>0),2);

% b2sigp_style=='1':
tmp = ncread(balfile,'b2sifr_smoch_bal');
b2sifr_smoch = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sifr_smotf_ehxp_bal');
b2sifr_smotf_ehxb = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sifr_smotf_cthe_bal');
b2sifr_smotf_cthe = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sifr_smotf_cthi_bal');
b2sifr_smotf_cthi = sum(tmp(:,za>0),2);
% b2sigp_style=='2':
tmp = ncread(balfile,'b2sifr_smofrea_bal');
b2sifr_smofrea = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sifr_smofria_bal');
b2sifr_smofria = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sifr_smotfea_bal');
b2sifr_smotfea = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sifr_smotfia_bal');
b2sifr_smotfia = sum(tmp(:,za>0),2);

tmp = ncread(balfile,'b2siav_smovh_bal');
b2siav_smovh = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2siav_smovv_bal');
b2siav_smovv = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sicf_smo_bal');
b2sicf_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sian_smo_bal');
b2sian_smo = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2nxdv_smo_bal');
b2nxdv_smo = sum(tmp(:,za>0),2);

tmp = ncread(balfile,'b2sigp_smogpi_bal');
b2sigp_smogpi = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sigp_smogpe_bal');
b2sigp_smogpe = sum(tmp(:,za>0),2);
tmp = ncread(balfile,'b2sigp_smogpgr_bal');
b2sigp_smogpgr = sum(tmp(:,za>0),2);

% Residual:
tmp = ncread(balfile,'resmo');
resmo = sum(tmp(:,za>0),2);
%%

%% Parallel area at cell centres:
hz = (1-comuse.b2mndr_hz)+comuse.b2mndr_hz*comuse.cvHz;
apll = comuse.cvVol.*hz./comuse.cvHx.*comuse.cvBb(:,1)./comuse.cvBb(:,4);
% Area at cell faces
hzf = (1-comuse.b2mndr_hz)+comuse.b2mndr_hz*comuse.fcHz;
apllf = comuse.fcS.*abs(comuse.fcQalf(:,1)).*hzf.*...
    comuse.fcBb(:,1)./comuse.fcBb(:,4);
%%

%% Calculate the radial divergence...
% Radial balance
raddiv_flua = raddiv(fmox_flua,fmoy_flua,comuse,facesup,facesdown,'parallel');
raddiv_visc = raddiv(zeros(size(fmox_cvsa)),fmoy_cvsa,comuse,facesup,facesdown,'parallel');
raddiv_hybr = raddiv(zeros(size(fmox_hybr)),fmoy_hybr,comuse,facesup,facesdown,'parallel');

% Poloidal balance
raddiv_flua_pol = raddiv(fmox_flua,fmoy_flua,comuse,[],[],'parallel');
raddiv_visc_pol = raddiv(zeros(size(fmox_cvsa)),fmoy_cvsa,comuse,[],[],'parallel');
raddiv_hybr_pol = raddiv(zeros(size(fmox_hybr)),fmoy_hybr,comuse,[],[],'parallel');
%%

%% Calculate the poloidal divergence of the viscous, hybrid correction and new ion viscosity form parts...
% Radial balance
raddiv_viscx = raddiv(zeros(size(fmox_cvsa)),fmox_cvsa,comuse,facesup,facesdown,'parallel');
raddiv_hybrx = raddiv(zeros(size(fmox_hybr)),fmox_hybr,comuse,facesup,facesdown,'parallel');

% Poloidal balance
raddiv_viscx_pol = raddiv(zeros(size(fmox_cvsa)),fmox_cvsa,comuse,[],[],'parallel');
raddiv_hybrx_pol = raddiv(zeros(size(fmox_hybr)),fmox_hybr,comuse,[],[],'parallel');
%%

%% Calculate the geometric term...
geomterm = zeros(nCv,1);
for iCv = 1:nCv
    iFc1 = comuse.cvFcP(iCv,1);
    iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
    for i = iFc1:iFc2
        iFc = comuse.cvFc(i);
        if iCv == comuse.fcCv(iFc,1)
            geomterm(iCv) = geomterm(iCv) - fmox_flua(iFc)*...
                (1 - apll(iCv)/(apllf(iFc) + 1.0e-30));
        else
            geomterm(iCv) = geomterm(iCv) + fmox_flua(iFc)*...
                (1 - apll(iCv)/(apllf(iFc) + 1.0e-30));
        end
    end
end

%%

%% Calculate the static pressure on poloidal cell faces...
ne = ncread(balfile,'ne');
te = ncread(balfile,'te');
na = ncread(balfile,'na');
ti = ncread(balfile,'ti');
pe = ne.*te;
pi = ti.*sum(na(:,za>0),2);
pef = intface(pe,comuse);
pif = intface(pi,comuse);
% Radial balance
pex = zeros(nFc,1);
pix = zeros(nFc,1);
pex(facesdown) = -pef(facesdown);
pix(facesdown) = -pif(facesdown);
pe0 = zeros(comuse.nFt,1);
pi0 = zeros(comuse.nFt,1);
% Correct sign
for i = 1:length(facesdown)
    iFc = facesdown(i);
    if indrad(comuse.fcCv(iFc,1))
        iFt = comuse.cvFt(comuse.fcCv(iFc,1));
    else
        iFt = comuse.cvFt(comuse.fcCv(iFc,2));
        pex(iFc) = -pex(iFc);
        pix(iFc) = -pix(iFc);
    end
    pe0(iFt) = pe0(iFt) + abs(pex(iFc));
    pi0(iFt) = pi0(iFt) + abs(pix(iFc));
end
% Integrate pressure gradient over the flux tubes in indrad
inte = zeros(comuse.nFt,1);
inti = zeros(comuse.nFt,1);
for iFt = 1:comuse.nFt % integration in flux tube
    iCv1 = comuse.ftCvP(iFt,1);
    iCv2 = iCv1 + comuse.ftCvP(iFt,2) - 1;
    for i = iCv1:iCv2
        iCv = comuse.ftCv(i);
        if indrad(iCv)
            inte(iFt) = inte(iFt) + b2sigp_smogpe(iCv)/apll(iCv);
            inti(iFt) = inti(iFt) + b2sigp_smogpi(iCv)/apll(iCv);
        end
    end
end
for i = 1:length(facesup)
    iFc = facesup(i);
    if indrad(comuse.fcCv(iFc,1))
        iFt = comuse.cvFt(comuse.fcCv(iFc,1));
        pex(iFc) = pex(iFc) - inte(iFt) + pe0(iFt);
        pix(iFc) = pix(iFc) - inti(iFt) + pi0(iFt);
    else
        iFt = comuse.cvFt(comuse.fcCv(iFc,2));
        pex(iFc) = pex(iFc) + inte(iFt) - pe0(iFt);
        pix(iFc) = pix(iFc) + inti(iFt) - pi0(iFt);
    end
end
% Poloidal balance
pex2 = zeros(nFc,1);
pix2 = zeros(nFc,1);
pex2(facesdown_pol) = -pef(facesdown_pol);
pix2(facesdown_pol) = -pif(facesdown_pol);
sign2 = ones(nFc,1);
% Correct sign
for i = 1:length(facesdown_pol)
    iFc = facesdown_pol(i);
    if indpol(comuse.fcCv(iFc,2))
        pex2(iFc) = -pex2(iFc);
        pix2(iFc) = -pix2(iFc);
        sign2(iFc) = -1;
    end
end  
% Integrate pressure gradient over the flux tubes in indpol
for i = 1:length(facesdown_pol)
    iFc = facesdown_pol(i);
    if indpol(comuse.fcCv(iFc,1))
        iCv = comuse.fcCv(iFc,1);
    elseif indpol(comuse.fcCv(iFc,2))
        iCv = comuse.fcCv(iFc,2);
    else
        error('facesdown_pol is not bordering the indpol region')
    end
    while true
        % Look for the face that is not bordering a flux tube
        iFc1 = comuse.cvFcP(iCv,1);
        iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
        for j = iFc1:iFc2
            iFc_new = comuse.cvFc(j);
            if iFc_new == iFc
                continue; % Face is already used
            end
            if comuse.cvFt(comuse.fcCv(iFc_new,1)) == comuse.cvFt(comuse.fcCv(iFc_new,2))
                pex2(iFc_new) = sign2(iFc)*pex2(iFc) + b2sigp_smogpe(iCv)/apll(iCv);
                pix2(iFc_new) = sign2(iFc)*pix2(iFc) + b2sigp_smogpi(iCv)/apll(iCv);
                if iCv == comuse.fcCv(iFc_new,1)
                    pex2(iFc_new) = -pex2(iFc_new);
                    pix2(iFc_new) = -pix2(iFc_new);
                    sign2(iFc_new) = -1;
                end
                break;
            end
        end
        if any(facesup_pol == iFc_new)
            break;
        else
            iFc = iFc_new;
            if iCv == comuse.fcCv(iFc,1)
                iCv = comuse.fcCv(iFc,2);
            else
                iCv = comuse.fcCv(iFc,1);
            end
        end
    end
end

%%

%% Make plots...
bm = radial_balance(...
 cat(2,fmox_flua./(apllf+1.0e-30),pex,pix),...
 cat(2,raddiv_flua./apll,raddiv_visc./apll,raddiv_hybr./apll,raddiv_viscx./apll,raddiv_hybrx./apll,...
       sum(eirene_mc_mapl_smo,3)./apll,sum(eirene_mc_mmpl_smo,3)./apll,sum(eirene_mc_mipl_smo,3)./apll,sum(eirene_mc_cppv_smo,3)./apll,...
       b2stel_smq_ion./apll,b2stel_smq_rec./apll,b2stcx_smq./apll,...
       b2sifr_smoch./apll+b2sifr_smotf_ehxb./apll+b2sifr_smotf_cthe./apll+b2sifr_smotf_cthi./apll,...
       b2sifr_smofrea./apll+b2sifr_smofria./apll+b2sifr_smotfea./apll+b2sifr_smotfia./apll,...
       b2siav_smovh./apll,b2siav_smovv./apll,b2sicf_smo./apll,b2sian_smo./apll,b2nxdv_smo./apll,...
       b2sigp_smogpgr./apll,...
       b2stbr_phys_smo./apll,b2stbr_bas_smo./apll,...
       b2stbm_smo./apll,ext_smo./apll,...
       b2srsm_smo./apll,b2srdt_smo./apll,b2srst_smo./apll,b2stbc_smo./apll,geomterm./apll),...
 resmo./apll,...
 {'total upstream flux',...
  'total downstream flux',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 {'convected','electron static','ion static'},...
 {'net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'viscous','hybrid',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'sum b2sifr (b2sigp==1)',...
  'sum b2sifr (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc','geometric term'},...
 comuse,indrad,facesup,facesdown,ones(nFc),reverse,true,axbal(1:4),'Nm^{-2}',makeplot,'right');

if ~makeplot
    return
end

areadownpol = poloidal_balance(...
 cat(2,fmox_flua./(apllf+1.0e-30),pex2,pix2),...
 cat(2,raddiv_flua_pol./apll,raddiv_visc_pol./apll,raddiv_hybr_pol./apll,...
       raddiv_viscx_pol./apll,raddiv_hybrx_pol./apll,...
       sum(eirene_mc_mapl_smo,3)./apll,sum(eirene_mc_mmpl_smo,3)./apll,sum(eirene_mc_mipl_smo,3)./apll,sum(eirene_mc_cppv_smo,3)./apll,...
       b2stel_smq_ion./apll,b2stel_smq_rec./apll,b2stcx_smq./apll,...
       b2sifr_smoch./apll+b2sifr_smotf_ehxb./apll+b2sifr_smotf_cthe./apll+b2sifr_smotf_cthi./apll,...
       b2sifr_smofrea./apll+b2sifr_smofria./apll+b2sifr_smotfea./apll+b2sifr_smotfia./apll,...
       b2siav_smovh./apll,b2siav_smovv./apll,b2sicf_smo./apll,b2sian_smo./apll,b2nxdv_smo./apll,...
       b2sigp_smogpgr./apll,...
       b2stbr_phys_smo./apll,b2stbr_bas_smo./apll,...
       b2stbm_smo./apll,ext_smo./apll,...
       b2srsm_smo./apll,b2srdt_smo./apll,b2srst_smo./apll,b2stbc_smo./apll,geomterm./apll),...
 resmo./apll,...
 {'total radially-integrated flux',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 {'convected','electron static','ion static'},...
 {'net radial convected flux','net radial viscous flux','net radial hybrid flux',...
  'viscous','hybrid',...
  'EIRENE atm.-plasma','EIRENE mol.-plasma','EIRENE t.ion-plasma','EIRENE recomb.',...
  'B2 ionisation','B2 recombination','B2 charge exchange',...
  'sum b2sifr (b2sigp==1)',...
  'sum b2sifr (b2sigp==2)',...
  'b2siav\_smovh','b2siav\_smovv','b2sicf','b2sian','b2nxdv',...
  'pressure gradient restriction',...
  'b2stbr\_phys','b2stbr\_bas',...
  'b2stbm','external source',...
  'b2srsm','b2srdt','b2srst','b2stbc','geometric term'},...
 comuse,indpol,facesup_pol,facesdown_pol,ones(nFc),reverse,true,axbal(5:7),'Nm^{-2}','right',polbaldist,1);

if strata_plot
    make_strata_plots({squeeze(eirene_mc_mapl_smo)},{squeeze(eirene_mc_mmpl_smo)},{squeeze(eirene_mc_mipl_smo)},{squeeze(eirene_mc_cppv_smo)},...
                      {'Strata decomp. of \int_d^uS_{mom}^{EIR}ds_{||} in radial direction',...
                       'Strata decomp. of S_{mom}^{EIR}ds_{||} in poloidal direction'},...
                      {''},comuse,indrad,indpol,nstra,axstrat,axbal,bm.area_divide,areadownpol,reverse,true);
end    
%%
end




