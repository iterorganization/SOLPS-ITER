%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balmom plots the momentum balance for a given SOLPS simulation.              %
% SIMID:       Specifier for the simulation of interest                        %
% indbal:      Logical matrix of size nx*ny that is true for cells where       %
%              balance should be performed                                     %
% iyplot:      Array of y indices along which poloidal balance will be plotted %
%              (within the volume specified by indbal)                         %
% isplot:      Species index to be plotted                                     %
% geomb2:      Geometry structure created by b2getgeom                         %
% axbal:       Array of axes into which balance plots will be placed           %
% reverse:     True if the right-most end of the balance volume is upstream of %
%              the left-most end, otherwise false                              %
% strata_plot: If true then divide the EIRENE source into components from each %
%              stratum (in a new figure)                                       %
% axstrat:     Array of aces into which strata plots will be placed            % 
% resaccuracy: The maximum acceptable percentage difference between the code-  %
%              calculated and post-calculated residual that will not throw a   %
%              warning                                                         %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function balmom(SIMID,b2fpstr,indrad,indpol,isplot,geomb2,axbal,reverse,strata_plot,axstrat,resaccuracy)

% Shorthand for geometry variables:
nx = geomb2.nx;
ny = geomb2.ny;
ns = geomb2.ns;
nstra = geomb2.nstra;
leftix = geomb2.leftix+1;  % Convert to one-based
leftiy = geomb2.leftiy+1;
rightix = geomb2.rightix+1;
rightiy = geomb2.rightiy+1;

topix = geomb2.topix+1;
topiy = geomb2.topiy+1;

%% Obtain required arrays from the simulation...
if ~isnumeric(SIMID)
    dv = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'vol'),nx,ny); % Cell volume
    hx = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'hx'),nx,ny); % hx
    B = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'bb'),nx,ny,4);

    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbc_smo'),nx,ny,ns);
    b2stbc_smo = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_mapl'),nx,ny,ns,nstra);
    eirene_mc_t0_mapl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_mmpl'),nx,ny,ns,nstra);
    eirene_mc_t0_mmpl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_mipl'),nx,ny,ns,nstra);
    eirene_mc_t0_mipl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_cppv'),nx,ny,ns,nstra);
    eirene_mc_t0_cppv = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbm_smo'),nx,ny,ns);
    b2stbm_smo = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'ext_smo'),nx,ny,ns);
    ext_smo = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_smq_ion'),nx,ny,ns);
    b2stel_smq_ion = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_smq_rec'),nx,ny,ns);
    b2stel_smq_rec = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stcx_smq'),nx,ny,ns);
    b2stcx_smq = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srsm_smo'),nx,ny,ns);
    b2srsm_smo = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srdt_smo'),nx,ny,ns);
    b2srdt_smo = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srst_smo'),nx,ny,ns);
    b2srst_smo = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sifr_smoch'),nx,ny,ns);
    b2sifr_smoch = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sifr_smotf'),nx,ny,ns);
    b2sifr_smotf = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2siav_smovh'),nx,ny,ns);
    b2siav_smovh = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2siav_smovv'),nx,ny,ns);
    b2siav_smovv = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'smcf'),nx,ny,ns);
    smcf = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2nxdv_smo'),nx,ny,ns);
    b2nxdv_smo = sum(tmp(:,:,isplot),3);
    
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sigp_smogp'),nx,ny,ns);
    b2sigp_smogp = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fmo_b2nxfv'),nx,ny,2,ns);
    fmox_b2nxfv = sum(tmp(:,:,1,isplot),4);
    fmoy_b2nxfv = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fmo_flua'),nx,ny,2,ns);
    fmox_flua = sum(tmp(:,:,1,isplot),4);
    fmoy_flua = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fmo_cvsa'),nx,ny,2,ns);
    fmox_cvsa = sum(tmp(:,:,1,isplot),4);
    fmoy_cvsa = sum(tmp(:,:,2,isplot),4);

    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'resmo'),nx,ny,ns);
    resmo = sum(tmp(:,:,isplot),3);
else
    % APPROPRIATE ARRAYS STILL NEED TO BE PUT ON THE MDSPLUS SERVER. TO BE
    % DONE!!!
end
%%

%% Parallel area at cell centres...
apll = dv./hx.*abs(B(:,:,1)./B(:,:,4));
% Map to left cell face:
apllx = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if leftix(ix,iy)<1
            continue;
        end
        apllx(ix,iy) = (apll(leftix(ix,iy),leftiy(ix,iy))*dv(ix,iy)+...
                        apll(ix,iy)*dv(leftix(ix,iy),leftiy(ix,iy)))/...
                       (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)));
    end
end

%% Calculate the radial divergence...
raddiv_flua = zeros(nx,ny);
raddiv_vis = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddiv_flua(ix,iy) = fmoy_flua(ix,iy)-fmoy_flua(topix(ix,iy),topiy(ix,iy));
        raddiv_vis(ix,iy) = (fmoy_cvsa(ix,iy)+fmoy_b2nxfv(ix,iy))-...
                            (fmoy_cvsa(topix(ix,iy),topiy(ix,iy))+fmoy_b2nxfv(topix(ix,iy),topiy(ix,iy)));
    end
end
%%

%% Calculate the poloidal divergence of the viscous part...
visc = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx
            continue;
        end
        visc(ix,iy) = (fmox_cvsa(ix,iy)+fmox_b2nxfv(ix,iy))-...
                        (fmox_cvsa(rightix(ix,iy),rightiy(ix,iy))+fmox_b2nxfv(rightix(ix,iy),rightiy(ix,iy)));
    end
end
%%

% Calculate the friction term between species (should sum to zero)
b2sifr_smo = b2sifr_smoch+b2sifr_smotf;

%% Make plots...
areadownrad = radial_balance(...
 fmox_flua,...
 cat(3,visc,raddiv_flua,raddiv_vis,b2stbc_smo,sum(eirene_mc_t0_mapl,4),...
       sum(eirene_mc_t0_mmpl,4),sum(eirene_mc_t0_mipl,4),sum(eirene_mc_t0_cppv,4),b2stbm_smo,ext_smo,...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smo,...
       b2siav_smovh,b2siav_smovv,smcf,b2nxdv_smo,b2sigp_smogp),...      
 resmo,resaccuracy,...
 {'$dA_{xu}n_umu_{\parallel u}u_{xu}/dA_{\parallel d}$',...
  '$n_dmu_{\parallel d}^2$',...
  '$\left(\int_d^u S_{\rm{mom}}^{\rm{tot}}dV\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u {\rm{res.}}dV\right)/dA_{\parallel d}$'},...
 {' '},...
 {'parallel viscosity','rad. diverg. $nmu_\parallel u_y$','rad. diverg. visc.','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','b2sifr','b2siav\_smovh','b2siav\_smovv','b2sicf','b2nxdv\_smo','stat. press. gradient'},...
 geomb2,indrad,apllx,reverse,true,axbal(1:4),'Nm$^{-2}$');

areadownpol = poloidal_balance(...
 fmox_flua,...
 cat(3,visc,raddiv_flua,raddiv_vis,b2stbc_smo,sum(eirene_mc_t0_mapl,4),...
       sum(eirene_mc_t0_mmpl,4),sum(eirene_mc_t0_mipl,4),sum(eirene_mc_t0_cppv,4),b2stbm_smo,ext_smo,...
       b2stel_smq_ion,b2stel_smq_rec,b2stcx_smq,b2srsm_smo,b2srdt_smo,b2srst_smo,b2sifr_smo,...
       b2siav_smovh,b2siav_smovv,smcf,b2nxdv_smo,b2sigp_smogp),...  
 resmo,resaccuracy,...
 {'$dA_xnmu_\parallel u_x/dA_{\parallel d}$',...
  '$S_{\rm{mom}}^{\rm{tot}}dV/dA_{\parallel d}$',...
  '${\rm{res.}}dV/dA_{\parallel d}$'},...
 {' '},...
 {'parallel viscosity','rad. diverg. $nmu_\parallel u_y$','rad. diverg. visc.','b2stbc',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','b2stbm','source\_input','b2stel\_ion',...
  'b2stel\_rec','b2stcx','b2srsm','b2srdt','b2srst','b2sifr','b2siav\_smovh','b2siav\_smovv','b2sicf','b2nxdv\_smo','stat. press. gradient'},...
 geomb2,indpol,apllx,reverse,true,axbal(5:7),'Nm$^{-2}$');

if strata_plot
    make_strata_plots({squeeze(eirene_mc_t0_mapl)},{squeeze(eirene_mc_t0_mmpl)},{squeeze(eirene_mc_t0_mipl)},{squeeze(eirene_mc_t0_cppv)},...
                      {'Strata decomp. of $\int_d^u S_{\rm{mom}}^{\rm{EIR}}ds_\parallel$ in radial direction',...
                       'Strata decomp. of $S_{\rm{mom}}^{\rm{EIR}}ds_\parallel$ in poloidal direction'},...
                      {''},geomb2,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,true);
end    
%%
end




