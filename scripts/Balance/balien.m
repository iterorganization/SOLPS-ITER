%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balien plots the ion internal energy balance for a given SOLPS simulation.   %
% SIMID:       Specifier for the simulation of interest                        %
% indbal:      Logical matrix of size nx*ny that is true for cells where       %
%              balance should be performed                                     %
% iyplot:      Array of y indices along which poloidal balance will be plotted %
%              (within the volume specified by indbal)                         %
% geomb2:      Geometry structure created by b2getgeom                         %
% axbal:       Array of axes into which balance plots will be placed           %
% reverse:     True if the right-most end of the balance volume is upstream of %
%              the left-most end, otherwise false                              %
% strata_plot: If true then divide the EIRENE source into components from each %
%              stratum (in a new figure)                                       %
% axstrat:     Array of axes into which strata plots will be placed            %
% resaccuracy: The maximum acceptable percentage difference between the code-  %
%              calculated and post-calculated residual that will not throw a   %
%              warning                                                         %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function balien(SIMID,b2fpstr,indrad,indpol,geomb2,axbal,reverse,strata_plot,axstrat,resaccuracy)

% Shorthand for geometry variables:
nx = geomb2.nx;
ny = geomb2.ny;
nstra = geomb2.nstra;
leftix = geomb2.leftix+1;  % Convert to one-based
leftiy = geomb2.leftiy+1;
topix = geomb2.topix+1;
topiy = geomb2.topiy+1;

%% Obtain required arrays from the simulation...
if ~isnumeric(SIMID)
    dv = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'vol'),nx,ny); % Cell volume
    hx = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'hx'),nx,ny); % hx
    B = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'bb'),nx,ny,4);

    b2stbc_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbc_shi'),nx,ny);
    eirene_mc_t0_eapl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eapl'),nx,ny,nstra);
    eirene_mc_t0_empl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_empl'),nx,ny,nstra);
    eirene_mc_t0_eipl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eipl'),nx,ny,nstra);
    eirene_mc_t0_eppl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eppl'),nx,ny,nstra);
    b2stbm_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbm_shi'),nx,ny);
    ext_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'ext_shi'),nx,ny);
    b2stel_shi_ion = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_shi_ion'),nx,ny);
    b2stel_shi_rec = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_shi_rec'),nx,ny);
    b2stcx_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stcx_shi'),nx,ny);

    b2srsm_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srsm_shi'),nx,ny);
    b2srdt_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srdt_shi'),nx,ny);
    b2srst_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srst_shi'),nx,ny);

    b2sihs_diaa = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_diaa'),nx,ny);

    b2sihs_divua = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_divua'),nx,ny);
    b2sihs_exba = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_exba'),nx,ny);
    b2sihs_visa = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_visa'),nx,ny);
    b2sihs_fraa = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_fraa'),nx,ny);

    b2npht_shei = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2npht_shei'),nx,ny);

    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_32'),nx,ny,2);
    fhix_32 = tmp(:,:,1);
    fhiy_32 = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_52'),nx,ny,2);
    fhix_52 = tmp(:,:,1);
    fhiy_52 = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_cond'),nx,ny,2);
    fhix_cond = tmp(:,:,1);
    fhiy_cond = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_dia'),nx,ny,2);
    fhix_dia = tmp(:,:,1);
    fhiy_dia = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_ecrb'),nx,ny,2);
    fhix_ecrb = tmp(:,:,1);
    fhiy_ecrb = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_strange'),nx,ny,2);
    fhix_strange = tmp(:,:,1);
    fhiy_strange = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_pschused'),nx,ny,2);
    fhix_pschused = tmp(:,:,1);
    fhiy_pschused = tmp(:,:,2);

    reshi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'reshi'),nx,ny);
else
    % APPROPRIATE ARRAYS STILL NEED TO BE PUT ON THE MDSPLUS SERVER. TO BE
    % DONE!!!
end
%%

%% Parallel area at left edges:
apll = dv./hx.*abs(B(:,:,1)./B(:,:,4));
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
%%

%% Radial divergences...
raddivi_32 = zeros(nx,ny);
raddivi_52 = zeros(nx,ny);
raddivi_cond = zeros(nx,ny);
raddivi_dia = zeros(nx,ny);
raddivi_ecrb = zeros(nx,ny);
raddivi_strange = zeros(nx,ny);
raddivi_pschused = zeros(nx,ny);
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
    end
end
%%

%% Make plots...
areadownrad = radial_balance(...
 cat(3,fhix_32,fhix_52,fhix_cond,fhix_dia,fhix_ecrb,...
       fhix_strange,fhix_pschused)/1E6,...
 cat(3,raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,b2stbc_shi,...
       sum(eirene_mc_t0_eapl,3),sum(eirene_mc_t0_empl,3),sum(eirene_mc_t0_eipl,3),sum(eirene_mc_t0_eppl,3),...
       b2stbm_shi,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_shi,b2srdt_shi,b2srst_shi,...
       b2sihs_diaa,b2sihs_divua,b2sihs_exba,b2sihs_visa,b2sihs_fraa,b2npht_shei)/1E6,...
 reshi/1E6,resaccuracy,...
 {'$dA_{xu}\tilde q_{ixu}/dA_{\parallel d}$',...
  '$dA_{xd}\tilde q_{ixd}/dA_{\parallel d}$',...
  '$\left(\int_d^u S_{\rm{IE}}^idV\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u {\rm{res.}}dV\right)/dA_{\parallel d}$'},...
 {'fhix\_32','fhix\_52','fhix\_cond','fhix\_dia','fhix\_ecrb',...
  'fhix\_strange','fhix\_pschused'},...
 {'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond',...
  'rad. diverg. fhiy\_dia','rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch','b2stbc\_shi',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_shi','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_shi','b2srdt\_shi','b2srst\_shi',...
  'b2sihs\_diaa','b2sihs\_divua','b2sihs\_exba','b2sihs\_visa','b2sihs\_fraa','equipartition'},...
 geomb2,indrad,apllx,reverse,false,axbal(1:4),'MWm$^{-2}$');

areadownpol = poloidal_balance(...
 cat(3,fhix_32,fhix_52,fhix_cond,fhix_dia,fhix_ecrb,...
       fhix_strange,fhix_pschused)/1E6,...
 cat(3,raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,b2stbc_shi,...
       sum(eirene_mc_t0_eapl,3),sum(eirene_mc_t0_empl,3),sum(eirene_mc_t0_eipl,3),sum(eirene_mc_t0_eppl,3),...
       b2stbm_shi,ext_shi,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_shi,b2srdt_shi,b2srst_shi,...
       b2sihs_diaa,b2sihs_divua,b2sihs_exba,b2sihs_visa,b2sihs_fraa,b2npht_shei)/1E6,...
 reshi/1E6,resaccuracy,...
 {'$dA_x\tilde q_{ix}/dA_{\parallel d}$',...
  '$S_{\rm{IE}}^idV/dA_{\parallel d}$',...
  '${\rm{res.}}dV/dA_{\parallel d}$'},...
 {'fhix\_32','fhix\_52','fhix\_cond','fhix\_dia','fhix\_ecrb',...
  'fhix\_strange','fhix\_pschused'},...
 {'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond',...
  'rad. diverg. fhiy\_dia','rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch','b2stbc\_shi',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_shi','ext\_shi',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_shi','b2srdt\_shi','b2srst\_shi',...
  'b2sihs\_diaa','b2sihs\_divua','b2sihs\_exba','b2sihs\_visa','b2sihs\_fraa','equipartition'},...
 geomb2,indpol,apllx,reverse,false,axbal(5:7),'MWm$^{-2}$');

if strata_plot
    make_strata_plots({eirene_mc_t0_eapl/1E6},{eirene_mc_t0_empl/1E6},{eirene_mc_t0_eipl/1E6},{eirene_mc_t0_eppl/1E6},...
                      {'Strata decomp. of $\left(\int_d^u S_{i\rm{IE}}^{\rm{EIR}}dV\right)/dA_{\parallel d}$ in radial direction',...
                       'Strata decomp. of $S_{i\rm{IE}}^{\rm{EIR}}dV/dA_{\parallel d}$ in poloidal direction'},...
                      {'el','ion'},geomb2,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,false);
end
%%
end




