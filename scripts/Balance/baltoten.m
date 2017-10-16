%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baltoten plots the total internal energy balance for a given SOLPS           %
% simulation.                                                                  %
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
% axstrat:     Array of aces into which strata plots will be placed            % 
% resaccuracy: The maximum acceptable percentage difference between the code-  %
%              calculated and post-calculated residual that will not throw a   %
%              warning                                                         %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function baltoten(SIMID,b2fpstr,indrad,indpol,geomb2,axbal,reverse,strata_plot,axstrat,resaccuracy)

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
    
    b2stbc_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbc_she'),nx,ny);
    b2stbc_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbc_shi'),nx,ny);
    eirene_mc_t0_eael = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eael'),nx,ny,nstra);
    eirene_mc_t0_emel = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_emel'),nx,ny,nstra);
    eirene_mc_t0_eiel = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eiel'),nx,ny,nstra);
    eirene_mc_t0_epel = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_epel'),nx,ny,nstra);
    eirene_mc_t0_eapl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eapl'),nx,ny,nstra);
    eirene_mc_t0_empl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_empl'),nx,ny,nstra);
    eirene_mc_t0_eipl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eipl'),nx,ny,nstra);
    eirene_mc_t0_eppl = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'eirene_mc_t0_eppl'),nx,ny,nstra);
    b2stbm_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbm_she'),nx,ny);
    b2stbm_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stbm_shi'),nx,ny);
    ext_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'ext_she'),nx,ny);
    ext_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'ext_shi'),nx,ny);
    b2stel_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_she'),nx,ny);
    b2stel_shi_ion = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_shi_ion'),nx,ny);
    b2stel_shi_rec = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stel_shi_rec'),nx,ny);
    b2stcx_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2stcx_shi'),nx,ny);
    
    b2srsm_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srsm_she'),nx,ny);
    b2srsm_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srsm_shi'),nx,ny);
    b2srdt_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srdt_she'),nx,ny);
    b2srdt_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srdt_shi'),nx,ny);
    b2srst_she = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srst_she'),nx,ny);
    b2srst_shi = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2srst_shi'),nx,ny);
    
    b2sihs_diae = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_diae'),nx,ny);
    b2sihs_diaa = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_diaa'),nx,ny);
    
    b2sihs_divue = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_divue'),nx,ny);
    b2sihs_divua = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_divua'),nx,ny);
    b2sihs_exbe = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_exbe'),nx,ny);
    b2sihs_exba = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_exba'),nx,ny);
    b2sihs_visa = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_visa'),nx,ny);
    b2sihs_joule = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_joule'),nx,ny);
    b2sihs_fraa = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'b2sihs_fraa'),nx,ny);

    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_32'),nx,ny,2);
    fhex_32 = tmp(:,:,1);
    fhey_32 = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_32'),nx,ny,2);
    fhix_32 = tmp(:,:,1);
    fhiy_32 = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_52'),nx,ny,2);
    fhex_52 = tmp(:,:,1);
    fhey_52 = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_52'),nx,ny,2);
    fhix_52 = tmp(:,:,1);
    fhiy_52 = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_thermj'),nx,ny,2);
    fhex_thermj = tmp(:,:,1);
    fhey_thermj = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_cond'),nx,ny,2);
    fhex_cond = tmp(:,:,1);
    fhey_cond = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_cond'),nx,ny,2);
    fhix_cond = tmp(:,:,1);
    fhiy_cond = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_dia'),nx,ny,2);
    fhex_dia = tmp(:,:,1);
    fhey_dia = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_dia'),nx,ny,2);
    fhix_dia = tmp(:,:,1);
    fhiy_dia = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_ecrb'),nx,ny,2);
    fhex_ecrb = tmp(:,:,1);
    fhey_ecrb = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_ecrb'),nx,ny,2);
    fhix_ecrb = tmp(:,:,1);
    fhiy_ecrb = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_strange'),nx,ny,2);
    fhex_strange = tmp(:,:,1);
    fhey_strange = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_strange'),nx,ny,2);
    fhix_strange = tmp(:,:,1);
    fhiy_strange = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhe_pschused'),nx,ny,2);
    fhex_pschused = tmp(:,:,1);
    fhey_pschused = tmp(:,:,2);
    tmp = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'fhi_pschused'),nx,ny,2);
    fhix_pschused = tmp(:,:,1);
    fhiy_pschused = tmp(:,:,2);

    reshe = reshape(getdata(b2fpstr,[SIMID,'b2fplasma'],'reshe'),nx,ny);
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
 cat(3,fhex_32,fhix_32,fhex_52,fhix_52,fhex_cond,fhix_cond,fhex_thermj,fhex_dia,fhix_dia,fhex_ecrb,fhix_ecrb,fhex_strange,...
       fhix_strange,fhex_pschused,fhix_pschused)/1E6,...
 cat(3,raddive_32,raddive_52,raddive_cond,raddive_thermj,raddive_dia,raddive_ecrb,raddive_strange,raddive_pschused,...
       raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,...
       b2stbc_she,b2stbc_shi,...
       sum(eirene_mc_t0_eael,3),sum(eirene_mc_t0_emel,3),sum(eirene_mc_t0_eiel,3),sum(eirene_mc_t0_epel,3),...
       sum(eirene_mc_t0_eapl,3),sum(eirene_mc_t0_empl,3),sum(eirene_mc_t0_eipl,3),sum(eirene_mc_t0_eppl,3),...
       b2stbm_she,b2stbm_shi,ext_she,ext_shi,b2stel_she,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_she,b2srsm_shi,b2srdt_she,b2srdt_shi,b2srst_she,b2srst_shi,...
       b2sihs_diae,b2sihs_diaa,b2sihs_divue,b2sihs_divua,b2sihs_exbe,b2sihs_exba,b2sihs_visa,b2sihs_joule,b2sihs_fraa)/1E6,...
 (reshe+reshi)/1E6,resaccuracy,...
 {'$dA_{xu}\left(\tilde q_{exu}+\tilde q_{ixu}\right)/dA_{\parallel d}$',...
  '$dA_{xd}\left(\tilde q_{exd}+\tilde q_{ixd}\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u S_{\rm{IE}}^{\rm{tot}}dV\right)/dA_{\parallel d}$',...
  '$\left(\int_d^u {\rm{res.}}dV\right)/dA_{\parallel d}$'},...
 {'fhex\_32','fhix\_32','fhex\_52','fhix\_52','fhex\_cond','fhix\_cond','fhex\_thermj','fhex\_dia','fhix\_dia','fhex\_ecrb','fhix\_ecrb','fhex\_strange',...
  'fhix\_strange','fhex\_pschused','fhix\_pschused'},...
 {'rad. diverg. fhey\_32','rad. diverg. fhey\_52','rad. diverg. fhey\_cond','rad. diverg. fhey\_thermj',...
  'rad. diverg. fhey\_dia','rad. diverg. fhey\_ecrb','rad. diverg. fhey\_strange','rad. diverg. fhey\_psch',...
  'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond',...
  'rad. diverg. fhiy\_dia','rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch',...
  'b2stbc\_she','b2stbc\_shi',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_she','b2stbm\_shi','ext\_she','ext\_shi','b2stel\_she',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_she','b2srsm\_shi','b2srdt\_she','b2srdt\_shi','b2srst\_she','b2srst\_shi',...
  'b2sihs\_diae','b2sihs\_diaa','b2sihs\_divue','b2sihs\_divua','b2sihs\_exbe','b2sihs\_exba','b2sihs\_visa','b2sihs\_joule','b2sihs\_fraa'},...
 geomb2,indrad,apllx,reverse,false,axbal(1:4),'MWm$^{-2}$');

areadownpol = poloidal_balance(...
 cat(3,fhex_32,fhix_32,fhex_52,fhix_52,fhex_cond,fhix_cond,fhex_thermj,fhex_dia,fhix_dia,fhex_ecrb,fhix_ecrb,fhex_strange,...
       fhix_strange,fhex_pschused,fhix_pschused)/1E6,...
 cat(3,raddive_32,raddive_52,raddive_cond,raddive_thermj,raddive_dia,raddive_ecrb,raddive_strange,raddive_pschused,...
       raddivi_32,raddivi_52,raddivi_cond,raddivi_dia,raddivi_ecrb,raddivi_strange,raddivi_pschused,...
       b2stbc_she,b2stbc_shi,...
       sum(eirene_mc_t0_eael,3),sum(eirene_mc_t0_emel,3),sum(eirene_mc_t0_eiel,3),sum(eirene_mc_t0_epel,3),...
       sum(eirene_mc_t0_eapl,3),sum(eirene_mc_t0_empl,3),sum(eirene_mc_t0_eipl,3),sum(eirene_mc_t0_eppl,3),...
       b2stbm_she,b2stbm_shi,ext_she,ext_shi,b2stel_she,...
       b2stel_shi_ion,b2stel_shi_rec,b2stcx_shi,b2srsm_she,b2srsm_shi,b2srdt_she,b2srdt_shi,b2srst_she,b2srst_shi,...
       b2sihs_diae,b2sihs_diaa,b2sihs_divue,b2sihs_divua,b2sihs_exbe,b2sihs_exba,b2sihs_visa,b2sihs_joule,b2sihs_fraa)/1E6,...
 (reshe+reshi)/1E6,resaccuracy,...
 {'$dA_x\left(\tilde q_{ex}+\tilde q_{ix}\right)/dA_{\parallel d}$',...
  '$S_{\rm{IE}}^{\rm{tot}}dV/dA_{\parallel d}$',...
  '${\rm{res.}}dV/dA_{\parallel d}$'},...
 {'fhex\_32','fhix\_32','fhex\_52','fhix\_52','fhex\_cond','fhix\_cond','fhex\_thermj','fhex\_dia','fhix\_dia','fhex\_ecrb','fhix\_ecrb','fhex\_strange',...
  'fhix\_strange','fhex\_pschused','fhix\_pschused'},...
 {'rad. diverg. fhey\_32','rad. diverg. fhey\_52','rad. diverg. fhey\_cond','rad. diverg. fhey\_thermj',...
  'rad. diverg. fhey\_dia','rad. diverg. fhey\_ecrb','rad. diverg. fhey\_strange','rad. diverg. fhey\_psch',...
  'rad. diverg. fhiy\_32','rad. diverg. fhiy\_52','rad. diverg. fhiy\_cond',...
  'rad. diverg. fhiy\_dia','rad. diverg. fhiy\_ecrb','rad. diverg. fhiy\_strange','rad. diverg. fhiy\_psch',...
  'b2stbc\_she','b2stbc\_shi',...
  'eirene\_mc atm.-plasma el.','eirene\_mc mol.-plasma el.','eirene\_mc t.ion-plasma el.','eirene\_mc recomb. el.',...
  'eirene\_mc atm.-plasma ion','eirene\_mc mol.-plasma ion','eirene\_mc t.ion-plasma ion','eirene\_mc recomb. ion',...
  'b2stbm\_she','b2stbm\_shi','ext\_she','ext\_shi','b2stel\_she',...
  'b2stel\_shi\_ion','b2stel\_shi\_rec','b2stcx\_shi','b2srsm\_she','b2srsm\_shi','b2srdt\_she','b2srdt\_shi','b2srst\_she','b2srst\_shi',...
  'b2sihs\_diae','b2sihs\_diaa','b2sihs\_divue','b2sihs\_divua','b2sihs\_exbe','b2sihs\_exba','b2sihs\_visa','b2sihs\_joule','b2sihs\_fraa'},...
 geomb2,indpol,apllx,reverse,false,axbal(5:7),'MWm$^{-2}$');

if strata_plot
    make_strata_plots({eirene_mc_t0_eael/1E6,eirene_mc_t0_eapl/1E6},{eirene_mc_t0_emel/1E6,eirene_mc_t0_empl/1E6},...
                      {eirene_mc_t0_eiel/1E6,eirene_mc_t0_eipl/1E6},{eirene_mc_t0_epel/1E6,eirene_mc_t0_eppl/1E6},...
                      {['Strata decomp. of $\left(\int_d^u S_{e\rm{IE}}^{\rm{EIR}}dV\right)/dA_{\parallel d}$ and ',...
                        '$\left(\int_d^u S_{i\rm{IE}}^{\rm{EIR}}dV\right)/dA_{\parallel d}$ in radial direction'],...
                       ['Strata decomp. of $S_{e\rm{IE}}^{\rm{EIR}}dV/dA_{\parallel d}$ and ',...
                        '$S_{i\rm{IE}}^{\rm{EIR}}dV/dA_{\parallel d}$ in poloidal direction']},...
                      {'el','ion'},geomb2,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,false);
end              
%%
end




