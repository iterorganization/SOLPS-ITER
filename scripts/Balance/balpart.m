%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balpart plots the particle balance for a given SOLPS simulation.             %
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
function balpart(SIMID,b2fpstr,indrad,indpol,isplot,geomb2,axbal,reverse,strata_plot,axstrat,resaccuracy)

% Shorthand for geometry variables:
nx = geomb2.nx;
ny = geomb2.ny;
ns = geomb2.ns;
nstra = geomb2.nstra;
leftix = geomb2.leftix+1;  % Convert to one-based
leftiy = geomb2.leftiy+1;

topix = geomb2.topix+1;
topiy = geomb2.topiy+1;

%% Obtain required arrays from the simulation...
if ~isnumeric(SIMID)
    dv = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'vol'),nx,ny); % Cell vol.
    hx = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'hx'),nx,ny); % hx
    B = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'bb'),nx,ny,4); % Mag. field
    
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbc_sna'),nx,ny,ns);
    b2stbc_sna = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_papl'),nx,ny,ns,nstra);
    eirene_mc_t0_papl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_pmpl'),nx,ny,ns,nstra);
    eirene_mc_t0_pmpl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_pipl'),nx,ny,ns,nstra);
    eirene_mc_t0_pipl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_pppl'),nx,ny,ns,nstra);
    eirene_mc_t0_pppl = sum(tmp(:,:,isplot,:),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_core'),nx,ny,ns);
    eirene_mc_t0_core = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbm_sna'),nx,ny,ns);
    b2stbm_sna = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'ext_sna'),nx,ny,ns);
    ext_sna = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_sna_ion'),nx,ny,ns);
    b2stel_sna_ion = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_sna_rec'),nx,ny,ns);
    b2stel_sna_rec = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stcx_sna'),nx,ny,ns);
    b2stcx_sna = sum(tmp(:,:,isplot),3);
    
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srsm_sna'),nx,ny,ns);
    b2srsm_sna = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srdt_sna'),nx,ny,ns);
    b2srdt_sna = sum(tmp(:,:,isplot),3);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srst_sna'),nx,ny,ns);
    b2srst_sna = sum(tmp(:,:,isplot),3);
    
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_pinch'),nx,ny,2,ns);
    fnbx_pinch = sum(tmp(:,:,1,isplot),4);
    fnby_pinch = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_pll'),nx,ny,2,ns);
    fnbx_pll = sum(tmp(:,:,1,isplot),4);
    fnby_pll = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_drift'),nx,ny,2,ns);
    fnbx_drift = sum(tmp(:,:,1,isplot),4);
    fnby_drift = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_nanom'),nx,ny,2,ns);
    fnbx_nanom = sum(tmp(:,:,1,isplot),4);
    fnby_nanom = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_panom'),nx,ny,2,ns);
    fnbx_panom = sum(tmp(:,:,1,isplot),4);
    fnby_panom = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_ch'),nx,ny,2,ns);
    fnbx_ch = sum(tmp(:,:,1,isplot),4);
    fnby_ch = sum(tmp(:,:,2,isplot),4);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fna_pschused'),nx,ny,2,ns);
    fnbx_pschused = sum(tmp(:,:,1,isplot),4);
    fnby_pschused = sum(tmp(:,:,2,isplot),4);
    
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'resco'),nx,ny,ns);
    rescb = sum(tmp(:,:,isplot),3);
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
raddiv_pinch = zeros(nx,ny);
raddiv_pll = zeros(nx,ny);
raddiv_drift = zeros(nx,ny);
raddiv_nanom = zeros(nx,ny);
raddiv_panom = zeros(nx,ny);
raddiv_ch = zeros(nx,ny);
raddiv_pschused = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddiv_pinch(ix,iy) = fnby_pinch(ix,iy)-fnby_pinch(topix(ix,iy),topiy(ix,iy));
        raddiv_pll(ix,iy) = fnby_pll(ix,iy)-fnby_pll(topix(ix,iy),topiy(ix,iy));
        raddiv_drift(ix,iy) = fnby_drift(ix,iy)-fnby_drift(topix(ix,iy),topiy(ix,iy));
        raddiv_nanom(ix,iy) = fnby_nanom(ix,iy)-fnby_nanom(topix(ix,iy),topiy(ix,iy));
        raddiv_panom(ix,iy) = fnby_panom(ix,iy)-fnby_panom(topix(ix,iy),topiy(ix,iy));
        raddiv_ch(ix,iy) = fnby_ch(ix,iy)-fnby_ch(topix(ix,iy),topiy(ix,iy));
        raddiv_pschused(ix,iy) = fnby_pschused(ix,iy)-fnby_pschused(topix(ix,iy),topiy(ix,iy));                    
    end
end
%%

%% Make plots...
areadownrad = radial_balance(...
 cat(3,fnbx_pll,fnbx_drift,fnbx_nanom,fnbx_panom,fnbx_pinch,fnbx_ch,fnbx_pschused),...
 cat(3,raddiv_drift,raddiv_pll,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_t0_papl,4),sum(eirene_mc_t0_pmpl,4),sum(eirene_mc_t0_pipl,4),sum(eirene_mc_t0_pppl,4),eirene_mc_t0_core,...
       b2stel_sna_ion,b2stel_sna_rec,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna),...
 rescb,resaccuracy,...
 {'$dA_{xu}\Gamma_{xu}/dA_{\parallel d}$',...
  '$\Gamma_{\parallel d}$',...
  '$\left(\int_d^u S_{\rm{part}}^{\rm{tot}}dV\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u {\rm{res.}}dV\right)/dA_{\parallel d}$'},...
 {'poloidal projection of $nv_{||}$','drift component','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnbx\_ch','Pfirsch-Schl\"{u}ter'},...
 {'rad. drift diverg.','rad. diverg. $nv_{||}$','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion','b2stel rec','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst'},...
 geomb2,indrad,apllx,reverse,false,axbal(1:4),'m$^{-2}$s$^{-1}$');

areadownpol = poloidal_balance(...
 cat(3,fnbx_pll,fnbx_drift,fnbx_nanom,fnbx_panom,fnbx_pinch,fnbx_ch,fnbx_pschused),...
 cat(3,raddiv_drift,raddiv_pll,raddiv_nanom,raddiv_panom,raddiv_pinch,raddiv_ch,raddiv_pschused,...
       sum(eirene_mc_t0_papl,4),sum(eirene_mc_t0_pmpl,4),sum(eirene_mc_t0_pipl,4),sum(eirene_mc_t0_pppl,4),eirene_mc_t0_core,...
       b2stel_sna_ion,b2stel_sna_rec,b2stbc_sna,b2stbm_sna,b2stcx_sna,ext_sna,b2srdt_sna,b2srsm_sna,b2srst_sna),...
 rescb,resaccuracy,...
 {'$dA_x\Gamma_x/dA_{\parallel d}$',...
  '$S_{\rm{part}}^{\rm{tot}}dV/dA_{\parallel d}$',...
  '${\rm{res.}}dV/dA_{\parallel d}$'},...
 {'poloidal projection of $nv_{||}$','dia.+E$\times$B drifts','anomalous density diffusion','anomalous pressure diffusion','anomalous pinch','fnbx_ch','PS'},...
 {'rad. drift diverg.','rad. diverg. $nv_{||}$','rad. density diffusion diverg.','rad. pressure diffusion diverg.','rad. pinch diverg.','rad. diverg. fnby\_ch','rad. P-S diverg.',...
  'eirene\_mc atm.-plasma','eirene\_mc mol.-plasma','eirene\_mc t.ion-plasma','eirene\_mc recomb.','eirene\_mc core',...
  'b2stel ion','b2stel rec','b2stbc','b2stbm','b2stcx','source\_input','b2srdt','b2srsm','b2srst'},...
 geomb2,indpol,apllx,reverse,false,axbal(5:7),'m$^{-2}$s$^{-1}$');

if strata_plot
    make_strata_plots({squeeze(eirene_mc_t0_papl)},{squeeze(eirene_mc_t0_pmpl)},{squeeze(eirene_mc_t0_pipl)},{squeeze(eirene_mc_t0_pppl)},...
                      {'Strata decomp. of $\left(\int_d^u S_{\rm{part}}^{\rm{EIR}}dV\right)/dA_{\parallel d}$ in radial direction',...
                       'Strata decomp. of $S_{\rm{part}}^{\rm{EIR}}dV/dA_{\parallel d}$ in poloidal direction'},...
                      {''},geomb2,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,false);
end              
%%
end




