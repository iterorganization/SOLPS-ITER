%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE SECONDARY QUANTITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================



%-------------------------------------------
% divergence of total flux
%-------------------------------------------
div_f=zeros(ny+2,nx+2);
div_f_x=zeros(ny+2,nx+2);
div_f_y=zeros(ny+2,nx+2);
[div_f_x,div_f_y,div_f]=calc_divergence(fnax_mdf(:,:,is_main),fnay_mdf(:,:,is_main),nx,ny,top,right);
div_f_x=div_f_x./vol;
div_f_y=div_f_y./vol;
div_f=div_f./vol;

%-------------------------------------------
% divergence of neutral flux
%-------------------------------------------
div_f00=zeros(ny+2,nx+2);
div_f00_x=zeros(ny+2,nx+2);
div_f00_y=zeros(ny+2,nx+2);
[div_f00_x,div_f00_y,div_f00]=calc_divergence(fnax(:,:,1),fnay(:,:,1),nx,ny,top,right);
div_f00_x=div_f00_x./vol;
div_f00_y=div_f00_y./vol;
div_f00=div_f00./vol;

%-------------------------------------------
% divergence of Dgradn flux
%-------------------------------------------
div_fDgrn=zeros(ny+2,nx+2);
div_fDgrn_x=zeros(ny+2,nx+2);
div_fDgrn_y=zeros(ny+2,nx+2);
[div_fDgrn_x,div_fDgrn_y,div_fDgrn]=calc_divergence(fnax_Dgradn(:,:,is_main),fnay_Dgradn(:,:,is_main),nx,ny,top,right);
div_fDgrn_x=div_fDgrn_x./vol;
div_fDgrn_y=div_fDgrn_y./vol;
div_fDgrn=div_fDgrn./vol;

%-------------------------------------------
% divergence of ExB flux
%-------------------------------------------
div_fve=zeros(ny+2,nx+2);
div_fve_x=zeros(ny+2,nx+2);
div_fve_y=zeros(ny+2,nx+2);
[div_fve_x,div_fve_y,div_fve]=calc_divergence(fnax_nuExB(:,:,is_main),fnay_nuExB(:,:,is_main),nx,ny,top,right);
%clear div_fve_x;
%clear div_fve_y;
div_fve_x=div_fve_x./vol;
div_fve_y=div_fve_y./vol;
div_fve=div_fve./vol;

%-------------------------------------------
% divergence of diamagnetic flux
%-------------------------------------------
div_fPSch=zeros(ny+2,nx+2);
div_fPSch_x=zeros(ny+2,nx+2);
div_fPSch_y=zeros(ny+2,nx+2);
[div_fPSch_x,div_fPSch_y,div_fPSch]=calc_divergence(-fnax_PSch(:,:,is_main),-fnay_PSch(:,:,is_main),nx,ny,top,right);
%clear div_fve_x;
%clear div_fve_y;
div_fPSch_x=div_fPSch_x./vol;
div_fPSch_y=div_fPSch_y./vol;
div_fPSch=div_fPSch./vol;

%-------------------------------------------
% divergence of parallel flux
%-------------------------------------------
div_fvp=zeros(ny+2,nx+2);
div_fvp_x=zeros(ny+2,nx+2);
div_fvp_y=zeros(ny+2,nx+2);
[div_fvp_x,div_fvp_y,div_fvp]=calc_divergence(fnax_nupar(:,:,is_main),fnay_nupar(:,:,is_main),nx,ny,top,right);
%clear div_fvp_x;
%clear div_fvp_y;
div_fvp_x=div_fvp_x./vol;
div_fvp_y_y=div_fvp_y./vol;
div_fvp=div_fvp./vol;

%-------------------------------------------
% divergence of impurity fluxes
%-------------------------------------------

% Carbon
if exist('is_C01','var')
    div_f_C01=zeros(ny+2,nx+2);
    div_f_x_C01=zeros(ny+2,nx+2);
    div_f_y_C01=zeros(ny+2,nx+2);
    [div_f_x_C01,div_f_y_C01,div_f_C01]=calc_divergence(fnax_mdf(:,:,is_C01),fnay_mdf(:,:,is_C01),nx,ny,top,right);
    div_f_x_C01=div_f_x_C01./vol;
    div_f_y_C01=div_f_y_C01./vol;
    div_f_C01=div_f_C01./vol;
    div_fve_C01=zeros(ny+2,nx+2);
    div_fve_x_C01=zeros(ny+2,nx+2);
    div_fve_y_C01=zeros(ny+2,nx+2);
    [div_fve_x_C01,div_fve_y_C01,div_fve_C01]=calc_divergence(fnax_nuExB(:,:,is_C01),fnay_nuExB(:,:,is_C01),nx,ny,top,right);
    div_fve_x_C01=div_fve_x_C01./vol;
    div_fve_y_C01=div_fve_y_C01./vol;
    div_fve_C01=div_fve_C01./vol;
end;

if exist('is_C02','var')
    div_f_C02=zeros(ny+2,nx+2);
    div_f_x_C02=zeros(ny+2,nx+2);
    div_f_y_C02=zeros(ny+2,nx+2);
    [div_f_x_C02,div_f_y_C02,div_f_C02]=calc_divergence(fnax_mdf(:,:,is_C02),fnay_mdf(:,:,is_C02),nx,ny,top,right);
    div_f_x_C02=div_f_x_C02./vol;
    div_f_y_C02=div_f_y_C02./vol;
    div_f_C02=div_f_C02./vol;
end;

if exist('is_C03','var')
    div_f_C03=zeros(ny+2,nx+2);
    div_f_x_C03=zeros(ny+2,nx+2);
    div_f_y_C03=zeros(ny+2,nx+2);
    [div_f_x_C03,div_f_y_C03,div_f_C03]=calc_divergence(fnax_mdf(:,:,is_C03),fnay_mdf(:,:,is_C03),nx,ny,top,right);
    div_f_x_C03=div_f_x_C03./vol;
    div_f_y_C03=div_f_y_C03./vol;
    div_f_C03=div_f_C03./vol;
end;

% Nitrogen
if exist('is_N01','var')
    div_f_N01=zeros(ny+2,nx+2);
    div_f_x_N01=zeros(ny+2,nx+2);
    div_f_y_N01=zeros(ny+2,nx+2);
    [div_f_x_N01,div_f_y_N01,div_f_N01]=calc_divergence(fnax_mdf(:,:,is_N01),fnay_mdf(:,:,is_N01),nx,ny,top,right);
    div_f_x_N01=div_f_x_N01./vol;
    div_f_y_N01=div_f_y_N01./vol;
    div_f_N01=div_f_N01./vol;
    div_fve_N01=zeros(ny+2,nx+2);
    div_fve_x_N01=zeros(ny+2,nx+2);
    div_fve_y_N01=zeros(ny+2,nx+2);
    [div_fve_x_N01,div_fve_y_N01,div_fve_N01]=calc_divergence(fnax_nuExB(:,:,is_N01),fnay_nuExB(:,:,is_N01),nx,ny,top,right);
    div_fve_x_N01=div_fve_x_N01./vol;
    div_fve_y_N01=div_fve_y_N01./vol;
    div_fve_N01=div_fve_N01./vol;
end;

if exist('is_N02','var')
    div_f_N02=zeros(ny+2,nx+2);
    div_f_x_N02=zeros(ny+2,nx+2);
    div_f_y_N02=zeros(ny+2,nx+2);
    [div_f_x_N02,div_f_y_N02,div_f_N02]=calc_divergence(fnax_mdf(:,:,is_N02),fnay_mdf(:,:,is_N02),nx,ny,top,right);
    div_f_x_N02=div_f_x_N02./vol;
    div_f_y_N02=div_f_y_N02./vol;
    div_f_N02=div_f_N02./vol;
end;

if exist('is_N03','var')
    div_f_N03=zeros(ny+2,nx+2);
    div_f_x_N03=zeros(ny+2,nx+2);
    div_f_y_N03=zeros(ny+2,nx+2);
    [div_f_x_N03,div_f_y_N03,div_f_N03]=calc_divergence(fnax_mdf(:,:,is_N03),fnay_mdf(:,:,is_N03),nx,ny,top,right);
    div_f_x_N03=div_f_x_N03./vol;
    div_f_y_N03=div_f_y_N03./vol;
    div_f_N03=div_f_N03./vol;
end;


%%%%%%%%%%%%%--------------------------------
% divergence of electron heat flux
%%%%%%%%%%%%%-------------------------------
div_fhe_mdf=zeros(ny+2,nx+2);
div_fhe_mdf_x=zeros(ny+2,nx+2);
div_fhe_mdf_y=zeros(ny+2,nx+2);
[div_fhe_mdf_x,div_fhe_mdf_y,div_fhe_mdf]=calc_divergence(fhex_mdf,fhey_mdf,nx,ny,top,right);
%clear div_fvp_x;
%clear div_fvp_y;
div_fhe_mdf_x=div_fhe_mdf_x./vol;
div_fhe_mdf_y=div_fhe_mdf_y./vol;
div_fhe_mdf=div_fhe_mdf./vol;

%%%%%%%%%%%%%--------------------------------
% divergence of ion heat flux
%%%%%%%%%%%%%-------------------------------
div_fhi_mdf=zeros(ny+2,nx+2);
div_fhi_mdf_x=zeros(ny+2,nx+2);
div_fhi_mdf_y=zeros(ny+2,nx+2);
[div_fhi_mdf_x,div_fhi_mdf_y,div_fhi_mdf]=calc_divergence(fhix_mdf,fhiy_mdf,nx,ny,top,right);
%clear div_fvp_x;
%clear div_fvp_y;
div_fhi_mdf_x=div_fhi_mdf_x./vol;
div_fhi_mdf_y=div_fhi_mdf_y./vol;
div_fhi_mdf=div_fhi_mdf./vol;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% electron density, Zeff, pressure etc, and flux surface integrated fluxes 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fnay_core=zeros(nsep+3,ns);
Fnay_mdf_core=zeros(nsep+3,ns);

Fnay_Dgradn_core=zeros(nsep+3,ns);
Fnay_nuExB_core=zeros(nsep+3,ns);
Fnay_nuAN_core=zeros(nsep+3,ns);
Fnay_jAN_core=zeros(nsep+3,1);
Fnay_jvispar_core=zeros(nsep+3,1);
Fnay_jvisper_core=zeros(nsep+3,1);
Fnay_jviq_core=zeros(nsep+3,1);
Fnay_jinert_core=zeros(nsep+3,1);
Fnay_PSch_core=zeros(nsep+3,1);

Fhey_core=zeros(nsep+3,1);
Fhey_mdf_core=zeros(nsep+3,1);
Fhey_52uExB_core=zeros(nsep+3,1);
Fhey_ke_gTy_core=zeros(nsep+3,1);
Fhey_32GammaT_core=zeros(nsep+3,1);
Fhey_PSchy_core=zeros(nsep+3,1);

Fhiy_core=zeros(nsep+3,1);
Fhiy_mdf_core=zeros(nsep+3,1);
Fhiy_52uExB_core=zeros(nsep+3,1);
Fhiy_ke_gTy_core=zeros(nsep+3,1);
Fhiy_32GammaT_core=zeros(nsep+3,1);
Fhiy_PSchy_core=zeros(nsep+3,1);

Snay_core=zeros(nsep+2,ns);
if EIRENE_flag == 1
    Snay_core_eir=zeros(nsep+2,ns);
end;
Snay_core_sral=zeros(nsep+2,ns);
dFnay_mdf_core_dy=zeros(nsep+2,ns);

ne=zeros(ny+2,nx+2);
ni=zeros(ny+2,nx+2,2);
ne2=zeros(ny+2,nx+2);
nas=zeros(ny+2,nx+2);
nasm=zeros(ny+2,nx+2);
pas=zeros(ny+2,nx+2);
Eprll=zeros(ny+2,nx+2);
smoe_grad_pe=zeros(ny+2,nx+2);
ni_imp=zeros(ny+2,nx+2);
ni_impZ=zeros(ny+2,nx+2);
ni_impZ2=zeros(ny+2,nx+2);
ni_Zsqrtm=zeros(ny+2,nx+2);

fhe_ExBy=zeros(ny+2,nx+2);
fhi_ExBy=zeros(ny+2,nx+2);
fhi_curry=zeros(ny+2,nx+2);

for i=2:ny+2
    for j=1:nx+2
        for is=1:ns
            fhe_ExBy(i,j)=fhe_ExBy(i,j)+0.5*(te(i,j)+te(bottom(i,j)+2,j))*fnay_nuExB(i,j,is)*qe*Za(is);
            fhi_ExBy(i,j)=fhi_ExBy(i,j)+0.5*(ti(i,j)+ti(bottom(i,j)+2,j))*fnay_nuExB(i,j,is)*qe;
            fhi_curry(i,j)=0.5*(ti(i,j)+ti(bottom(i,j)+2,j))*(jy_AN(i,j)+jy_vispar(i,j)+jy_visq(i,j)+jy_inert(i,j)+jy_visper(i,j))*qe;
%            fhe_diaY(i,j)=0.5*(te(i,j)+te(bottom(i,j)+2,j))*fyPSch01(i,j)*qe;
        end;
    end;
end;

pa=zeros(ny+2,nx+2,ns);

for is=1:ns

   ne(:,:)=ne(:,:)+na(:,:,is)*Za(is);
   ni(:,:,1)=ni(:,:,1)+na(:,:,is); % total atom and ion density, i.e. sum ove all charge states including neutrals
   ni(:,:,2)=ni(:,:,2)+na(:,:,is)*max(Za(is),0)/max(Za(is),1); % total ion density, i.e. sum over all charged ions without neutrals
   ne2(:,:)=ne2(:,:)+na(:,:,is)*Za(is)*Za(is);
   nas(:,:)=nas(:,:)+na(:,:,is);
   nasm(:,:)=nasm(:,:)+na(:,:,is)*Am(is);
   pa(:,:,is)=(Za(is)*te(:,:)+ti(:,:)).*na(:,:,is)*qe;
   pas(:,:)=pas(:,:)+pa(:,:,is);
   
   if is ~= is_main
      ni_imp(:,:)=ni_imp(:,:)+na(:,:,is)*max(Za(is),0)/max(Za(is),1); % total ion density, i.e. sum over all charged ions without neutrals
      ni_impZ(:,:)=ni_impZ(:,:)+na(:,:,is)*Za(is);
      ni_impZ2(:,:)=ni_impZ2(:,:)+na(:,:,is)*Za(is)*Za(is);
   end;

   ni_Zsqrtm(:,:)=ni_Zsqrtm(:,:)+na(:,:,is)*Za(is)*Za(is)/sqrt(1.0+Am(is_main)/Am(is));
   
   hci(:,:,is) = hci(:,:,is)./na(:,:,is);
   
   %smoEprll(:,:,is) = Za(is)*qe*hz.*Eprll.*vol.*Bx.*na(:,:,is)./B;
   
   fnax_phys(:,:,is) = fnax_mdf(:,:,is) + fnax_dia(:,:,is) + fnax_PSch(:,:,is);
end;

% Coulomb logarithm
% % % Lambda_Coulomb=zeros(ny+2,nx+2);
% % % for i=1:ny+2
% % %     for j=1:nx+2
% % %         if te(i,j)>=50.0
% % %             Lambda_Coulomb(i,j) = 25.3-1.15*log10(ne(i,j))+2.31*log10(te(i,j));
% % %         else
% % %             Lambda_Coulomb(i,j) = 23.4-1.15*log10(ne(i,j))+3.45*log10(te(i,j));
% % %         end;
% % %     end;
% % % end;

% cell centered electric field, mainly for plotting
E_x=zeros(ny+2,nx+2);
E_y=zeros(ny+2,nx+2);

for i=2:ny+1
    for j=2:ntt+1
        E_x(i,j)=(po(i,left(i,j)+2)-po(i,right(i,j)+2))/(hx(i,j)+0.5*(hx(i,right(i,j)+2)+hx(i,left(i,j)+2)));
        E_y(i,j)=(po(i-1,j)-po(i+1,j))/(hy(i,j)+0.5*(hy(i+1,j)+hy(i-1,j)));
    end;
    if nc2==ntt
        for j=ntt+2:ntt+3
            E_x(i,j)=(po(i,left(i,j)+2)-po(i,right(i,j)+2))/(hx(i,j)+0.5*(hx(i,right(i,j)+2)+hx(i,left(i,j)+2)));
            E_y(i,j)=(po(i-1,j)-po(i+1,j))/(hy(i,j)+0.5*(hy(i+1,j)+hy(i-1,j)));
        end;
    end;
    for j=ntt+4:nx+1
        E_x(i,j)=(po(i,left(i,j)+2)-po(i,right(i,j)+2))/(hx(i,j)+0.5*(hx(i,right(i,j)+2)+hx(i,left(i,j)+2)));
        E_y(i,j)=(po(i-1,j)-po(i+1,j))/(hy(i,j)+0.5*(hy(i+1,j)+hy(i-1,j)));
    end;

end;


% Electron force balance components
smoche_tot = zeros(ny+2,nx+2);
smotf_ie_gradTe_tot = zeros(ny+2,nx+2);
smoEprll_tot = zeros(ny+2,nx+2);

for is=1:ns
    if Za(is) > 0
        smoche_tot = smoche_tot + smoche(:,:,is);
        smotf_ie_gradTe_tot = smotf_ie_gradTe_tot + smotf_ie_gradTe(:,:,is);
        smoEprll_tot = smoEprll_tot + smoEprll(:,:,is);
    end;
end;
for i=1:ny+2
    for j=1:nx+2
        if (left(i,j) == -2)
            Eprll(i,j) = 0.0;
            smoe_grad_pe(i,j) = 0.0;
        elseif (right(i,j) == nx+1)
            Eprll(i,j) = 0.0;
            smoe_grad_pe(i,j) = 0.0;
        else
            Eprll(i,j) = (po(i,left(i,j)+2)-po(i,j))/(hx(i,left(i,j)+2)+hx(i,j)) + (po(i,j)-po(i,right(i,j)+2))/(hx(i,j)+hx(i,right(i,j)+2));
            smoe_grad_pe(i,j) = ((ne(i,left(i,j)+2)*te(i,left(i,j)+2)-ne(i,j)*te(i,j))/(hx(i,left(i,j)+2)+hx(i,j)) + ...
                (ne(i,j).*te(i,j)-ne(i,right(i,j)+2)*te(i,right(i,j)+2))/(hx(i,j)+hx(i,right(i,j)+2)))*qe*vol(i,j)*hz(i,j)*Bx(i,j)/B(i,j);
       end;
    end;
end;

% cell-centered parallel  ion temperature gradient
grad_prll_Ti=zeros(ny+2,nx+2);
for i=1:ny+2
    for j=1:nx+2
        if left(i,j) ~= -2 && right(i,j) ~= nx+1
        grad_prll_Ti(i,j) = Bx(i,j)/B(i,j)*((ti(i,right(i,j)+2)-ti(i,j))/(hx(i,right(i,j)+2)+hx(i,j))+(ti(i,j)-ti(i,left(i,j)+2))/(hx(i,j)+hx(i,left(i,j)+2)));
        end;
    end;
end;

 div_fnax_nupar_main=zeros(ny+2,nx+2);
 div_fnay_nupar_main=zeros(ny+2,nx+2);
 [div_fna_nupar_main,div_fnax_nupar_main,div_fnay_nupar_main]=calc_divergence(fnax_nupar(:,:,is_main),fnay_nupar(:,:,is_main),nx,ny,top,right);
 div_fna_nupar_main=div_fna_nupar_main./vol;
 div_fnax_nupar_main=div_fnax_nupar_main./vol;
 div_fnax_nupar_main=div_fnay_nupar_main./vol;
 
 Fnax_nupar_main=zeros(nx+2,1);
  for j=nc1:nc4
     Fnax_nupar_main(j+2)=radial_integral(fnax_nupar(:,:,is_main),nsep-1,nsep,j);
  end;
  

%-------------------------------------------
% total helium fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
if exist('is_He01','var')
    fnax_He_ch     = fnax(:,:,is_He01)+fnax(:,:,is_He02);
    fnay_He_ch     = fnay(:,:,is_He01)+fnay(:,:,is_He02);
    fnax_mdf_He_ch = fnax_mdf(:,:,is_He01)+fnax_mdf(:,:,is_He02);
    fnay_mdf_He_ch = fnay_mdf(:,:,is_He01)+fnay_mdf(:,:,is_He02);
    
    fnax_He_all = fnax_He_ch + fnax(:,:,is_He01-1);
    fnay_He_all = fnay_He_ch + fnay(:,:,is_He01-1);
    fnax_mdf_He_all = fnax_mdf_He_ch + fnax_mdf(:,:,is_He01-1);
    fnay_mdf_He_all = fnay_mdf_He_ch + fnay_mdf(:,:,is_He01-1);
    
    nHe_ch = na(:,:,is_He01)+na(:,:,is_He02);
    nHe_tot = nHe_ch+na(:,:,is_He01-1);
    
    Fnay_He_all=zeros(nsep+3,1);
    Fnay_He_ch=zeros(nsep+3,1);
    Fnay_mdf_He_all=zeros(nsep+3,1);
    Fnay_mdf_He_ch=zeros(nsep+3,1);
    
    smotf_ii_gradTi_Hetot = smotf_ii_gradTi(:,:,is_He01) + smotf_ii_gradTi(:,:,is_He02);

end;

%-------------------------------------------
% total carbon densities - sum over ALL states and sum over CHARGED states
% total carbon fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
if exist('is_C01','var')
    fnax_C_ch     = fnax(:,:,is_C01)+fnax(:,:,is_C02)+fnax(:,:,is_C03)+fnax(:,:,is_C04)+fnax(:,:,is_C05)+fnax(:,:,is_C06);
    fnay_C_ch     = fnay(:,:,is_C01)+fnay(:,:,is_C02)+fnay(:,:,is_C03)+fnay(:,:,is_C04)+fnay(:,:,is_C05)+fnay(:,:,is_C06);
    fnax_mdf_C_ch = fnax_mdf(:,:,is_C01)+fnax_mdf(:,:,is_C02)+fnax_mdf(:,:,is_C03)+fnax_mdf(:,:,is_C04)+fnax_mdf(:,:,is_C05)+fnax_mdf(:,:,is_C06);
    fnay_mdf_C_ch = fnay_mdf(:,:,is_C01)+fnay_mdf(:,:,is_C02)+fnay_mdf(:,:,is_C03)+fnay_mdf(:,:,is_C04)+fnay_mdf(:,:,is_C05)+fnay_mdf(:,:,is_C06);
    fnax_nuExB_C_ch = fnax_nuExB(:,:,is_C01)+fnax_nuExB(:,:,is_C02)+fnax_nuExB(:,:,is_C03)+fnax_nuExB(:,:,is_C04)+fnax_nuExB(:,:,is_C05)+fnax_nuExB(:,:,is_C06);
    fnax_Dgradn_C_ch = fnax_Dgradn(:,:,is_C01)+fnax_Dgradn(:,:,is_C02)+fnax_Dgradn(:,:,is_C03)+fnax_Dgradn(:,:,is_C04)+fnax_Dgradn(:,:,is_C05)+fnax_Dgradn(:,:,is_C06);
    fnax_nupar_C_ch = fnax_nupar(:,:,is_C01)+fnax_nupar(:,:,is_C02)+fnax_nupar(:,:,is_C03)+fnax_nupar(:,:,is_C04)+fnax_nupar(:,:,is_C05)+fnax_nupar(:,:,is_C06);
    
    fnax_C_all = fnax_C_ch + fnax(:,:,is_C01-1);
    fnay_C_all = fnay_C_ch + fnay(:,:,is_C01-1);
    fnax_mdf_C_all = fnax_mdf_C_ch + fnax_mdf(:,:,is_C01-1);
    fnay_mdf_C_all = fnay_mdf_C_ch + fnay_mdf(:,:,is_C01-1);
    
    nC_ch = na(:,:,is_C01)+na(:,:,is_C02)+na(:,:,is_C03)+na(:,:,is_C04)+na(:,:,is_C05)+na(:,:,is_C06);
    nC_tot = nC_ch+na(:,:,is_C01-1);
    
    Fnay_C_all=zeros(nsep+3,1);
    Fnay_C_ch=zeros(nsep+3,1);
    Fnay_mdf_C_all=zeros(nsep+3,1);
    Fnay_mdf_C_ch=zeros(nsep+3,1);
    
    Fnax_mdf_C_ch=zeros(1,nx+2);
    Fnax_nuExB_C_ch=zeros(1,nx+2);
    Fnax_Dgradn_C_ch=zeros(1,nx+2);
    Fnax_nupar_C_ch=zeros(1,nx+2);
    
    smotf_ii_gradTi_Ctot = smotf_ii_gradTi(:,:,is_C01)+smotf_ii_gradTi(:,:,is_C02)+smotf_ii_gradTi(:,:,is_C03)+smotf_ii_gradTi(:,:,is_C04)+smotf_ii_gradTi(:,:,is_C05)+smotf_ii_gradTi(:,:,is_C06);
    
    
    for j=-1:nx
%         Fnax_mdf_C_ch(j+2) = radial_integral(fnax_mdf_C_ch,nsep+1,ny,j);
%         Fnax_nuExB_C_ch (j+2)= radial_integral(fnax_nuExB_C_ch,nsep+1,ny,j);
%         Fnax_Dgradn_C_ch(j+2) = radial_integral(fnax_Dgradn_C_ch,nsep+1,ny,j);
%         Fnax_nupar_C_ch(j+2) = radial_integral(fnax_nupar_C_ch,nsep+1,ny,j);
        Fnax_mdf_C_ch(j+2) = radial_integral(fnax_mdf_C_ch,nsep+1,nsep+3,j);
        Fnax_nuExB_C_ch (j+2)= radial_integral(fnax_nuExB_C_ch,nsep+1,nsep+3,j);
        Fnax_Dgradn_C_ch(j+2) = radial_integral(fnax_Dgradn_C_ch,nsep+1,nsep+3,j);
        Fnax_nupar_C_ch(j+2) = radial_integral(fnax_nupar_C_ch,nsep+1,nsep+3,j);
    end;
    
end;

%-------------------------------------------
% total nitrogen fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
if exist('is_N01','var')
    fnax_N_ch     = fnax(:,:,is_N01)+fnax(:,:,is_N02)+fnax(:,:,is_N03)+fnax(:,:,is_N04)+fnax(:,:,is_N05)+fnax(:,:,is_N06)+fnax(:,:,is_N07);
    fnay_N_ch     = fnay(:,:,is_N01)+fnay(:,:,is_N02)+fnay(:,:,is_N03)+fnay(:,:,is_N04)+fnay(:,:,is_N05)+fnay(:,:,is_N06)+fnay(:,:,is_N07);
    fnax_mdf_N_ch = fnax_mdf(:,:,is_N01)+fnax_mdf(:,:,is_N02)+fnax_mdf(:,:,is_N03)+fnax_mdf(:,:,is_N04)+fnax_mdf(:,:,is_N05)+fnax_mdf(:,:,is_N06)+fnax_mdf(:,:,is_N07);
    fnay_mdf_N_ch = fnay_mdf(:,:,is_N01)+fnay_mdf(:,:,is_N02)+fnay_mdf(:,:,is_N03)+fnay_mdf(:,:,is_N04)+fnay_mdf(:,:,is_N05)+fnay_mdf(:,:,is_N06)+fnay_mdf(:,:,is_N07);
    fnax_nuExB_N_ch = fnax_nuExB(:,:,is_N01)+fnax_nuExB(:,:,is_N02)+fnax_nuExB(:,:,is_N03)+fnax_nuExB(:,:,is_N04)+fnax_nuExB(:,:,is_N05)+fnax_nuExB(:,:,is_N06)+fnax_nuExB(:,:,is_N07);
    fnay_nuExB_N_ch = fnay_nuExB(:,:,is_N01)+fnay_nuExB(:,:,is_N02)+fnay_nuExB(:,:,is_N03)+fnay_nuExB(:,:,is_N04)+fnay_nuExB(:,:,is_N05)+fnay_nuExB(:,:,is_N06)+fnay_nuExB(:,:,is_N07);
    fnax_Dgradn_N_ch = fnax_Dgradn(:,:,is_N01)+fnax_Dgradn(:,:,is_N02)+fnax_Dgradn(:,:,is_N03)+fnax_Dgradn(:,:,is_N04)+fnax_Dgradn(:,:,is_N05)+fnax_Dgradn(:,:,is_N06)+fnax_Dgradn(:,:,is_N07);
    fnay_Dgradn_N_ch = fnay_Dgradn(:,:,is_N01)+fnay_Dgradn(:,:,is_N02)+fnay_Dgradn(:,:,is_N03)+fnay_Dgradn(:,:,is_N04)+fnay_Dgradn(:,:,is_N05)+fnay_Dgradn(:,:,is_N06)+fnay_Dgradn(:,:,is_N07);
    fnax_nupar_N_ch = fnax_nupar(:,:,is_N01)+fnax_nupar(:,:,is_N02)+fnax_nupar(:,:,is_N03)+fnax_nupar(:,:,is_N04)+fnax_nupar(:,:,is_N05)+fnax_nupar(:,:,is_N06)+fnax_nupar(:,:,is_N07);
    fnay_nupar_N_ch = fnay_nupar(:,:,is_N01)+fnay_nupar(:,:,is_N02)+fnay_nupar(:,:,is_N03)+fnay_nupar(:,:,is_N04)+fnay_nupar(:,:,is_N05)+fnay_nupar(:,:,is_N06)+fnay_nupar(:,:,is_N07);
    fnax_PSch_N_ch = fnax_PSch(:,:,is_N01)+fnax_PSch(:,:,is_N02)+fnax_PSch(:,:,is_N03)+fnax_PSch(:,:,is_N04)+fnax_PSch(:,:,is_N05)+fnax_PSch(:,:,is_N06)+fnax_PSch(:,:,is_N07);
    fnay_PSch_N_ch = fnay_PSch(:,:,is_N01)+fnay_PSch(:,:,is_N02)+fnay_PSch(:,:,is_N03)+fnay_PSch(:,:,is_N04)+fnay_PSch(:,:,is_N05)+fnay_PSch(:,:,is_N06)+fnay_PSch(:,:,is_N07);
    fnax_dia_N_ch = fnax_dia(:,:,is_N01)+fnax_dia(:,:,is_N02)+fnax_dia(:,:,is_N03)+fnax_dia(:,:,is_N04)+fnax_dia(:,:,is_N05)+fnax_dia(:,:,is_N06)+fnax_dia(:,:,is_N07);
    fnay_dia_N_ch = fnay_dia(:,:,is_N01)+fnay_dia(:,:,is_N02)+fnay_dia(:,:,is_N03)+fnay_dia(:,:,is_N04)+fnay_dia(:,:,is_N05)+fnay_dia(:,:,is_N06)+fnay_dia(:,:,is_N07);
    
    fnax_N_all = fnax_N_ch + fnax(:,:,is_N01-1);
    fnay_N_all = fnay_N_ch + fnay(:,:,is_N01-1);
    fnax_mdf_N_all = fnax_mdf_N_ch + fnax_mdf(:,:,is_N01-1);
    fnay_mdf_N_all = fnay_mdf_N_ch + fnay_mdf(:,:,is_N01-1);
    
    nN_ch = na(:,:,is_N01)+na(:,:,is_N02)+na(:,:,is_N03)+na(:,:,is_N04)+na(:,:,is_N05)+na(:,:,is_N06)+na(:,:,is_N07);
    uaN_ch_avr = (na(:,:,is_N01).*ua(:,:,is_N01)+na(:,:,is_N02).*ua(:,:,is_N02)+na(:,:,is_N03).*ua(:,:,is_N03)+na(:,:,is_N04).*ua(:,:,is_N04)+na(:,:,is_N05).*ua(:,:,is_N05)+na(:,:,is_N06).*ua(:,:,is_N06)+na(:,:,is_N07).*ua(:,:,is_N07))./nN_ch;
    nN_tot = nN_ch+na(:,:,is_N01-1);
    
    smotf_ii_gradTi_Ntot = smotf_ii_gradTi(:,:,is_N01)+smotf_ii_gradTi(:,:,is_N02)+smotf_ii_gradTi(:,:,is_N03)+smotf_ii_gradTi(:,:,is_N04)+smotf_ii_gradTi(:,:,is_N05)+smotf_ii_gradTi(:,:,is_N06)+smotf_ii_gradTi(:,:,is_N07);

    smogpi_N_ch=(smogpi(:,:,is_N01)+smogpi(:,:,is_N02)+smogpi(:,:,is_N03)+smogpi(:,:,is_N04)+smogpi(:,:,is_N05)+smogpi(:,:,is_N06)+smogpi(:,:,is_N07))./vol./hz;
    smochi_N_ch=(smochi(:,:,is_N01)+smochi(:,:,is_N02)+smochi(:,:,is_N03)+smochi(:,:,is_N04)+smochi(:,:,is_N05)+smochi(:,:,is_N06)+smochi(:,:,is_N07))./vol./hz;
    smotf_ii_gradTi_N_ch=(smotf_ii_gradTi(:,:,is_N01)+smotf_ii_gradTi(:,:,is_N02)+smotf_ii_gradTi(:,:,is_N03)+smotf_ii_gradTi(:,:,is_N04)+smotf_ii_gradTi(:,:,is_N05)+smotf_ii_gradTi(:,:,is_N06)+smotf_ii_gradTi(:,:,is_N07))./vol./hz;
    Eforce_N_ch=(Za(is_N01)*na(:,:,is_N01)+Za(is_N02)*na(:,:,is_N02)+Za(is_N03)*na(:,:,is_N03)+Za(is_N04)*na(:,:,is_N04)+Za(is_N05)*na(:,:,is_N05)+Za(is_N06)*na(:,:,is_N06)+Za(is_N07)*na(:,:,is_N07)).*E_x.*Bx./B*qe;
    
% % % % %     uN_Lizzlans=zeros(ny+2,nx+2);
% % % % %     uN_Lizzlans = ua(:,:,is_main)+smotf(:,:,is_N07).*(ti*qe).^(3/2) ./ ...
% % % % %         ( 4*sqrt(pi)/3 * Za(is_main)^2 * Za(is_N07)^2 * (qe^2/(4*pi*epsilon_0))^2 * sqrt(mp) * na(:,:,is_main) .* na(:,:,is_N07) .* Lambda_Coulomb_b2sifr ...
% % % % %        * sqrt( Am(is_main)*Am(is_N07) / ( Am(is_N07)+Am(is_main) ) ) .* vol .* hz);
% % % % %    
% % % % %     uN_Lizzlans = ua(:,:,is_main)+smotf(:,:,is_N07)./(smoch(:,:,is_N07) ./ (ua(:,:,is_main) - ua(:,:,is_N07)));
% % % % %    
% % % % %     uN_Lizzlans = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb_b2sifr)*sqrt(Am(is_N01)/(Am(is_N01)+Am(is_main)))/Am(is_main); 

    
    % % % %     uN_Lizzlans(:,:,is_N02) = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb)*sqrt(Am(is_N02)*Am(is_main)/(Am(is_N02)+Am(is_main)))/Am(is_main); 
% % % %     uN_Lizzlans(:,:,is_N03) = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb)*sqrt(Am(is_N03)*Am(is_main)/(Am(is_N03)+Am(is_main)))/Am(is_main); 
% % % %     uN_Lizzlans(:,:,is_N04) = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb)*sqrt(Am(is_N04)*Am(is_main)/(Am(is_N04)+Am(is_main)))/Am(is_main); 
% % % %     uN_Lizzlans(:,:,is_N05) = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb)*sqrt(Am(is_N05)*Am(is_main)/(Am(is_N05)+Am(is_main)))/Am(is_main); 
% % % %     uN_Lizzlans(:,:,is_N06) = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb)*sqrt(Am(is_N06)*Am(is_main)/(Am(is_N06)+Am(is_main)))/Am(is_main); 
% % % %     uN_Lizzlans(:,:,is_N07) = ua(:,:,is_main)+1.56*(ti*qe).^(3/2).*grad_prll_Ti*qe./(4*sqrt(pi)/3*Za(is_main)^2*sqrt(mp)*(qe^2/(4*pi*epsilon_0))^2*na(:,:,is_main).*Lambda_Coulomb)*sqrt(Am(is_N07)*Am(is_main)/(Am(is_N07)+Am(is_main)))/Am(is_main); 
    
    Fnay_N_all=zeros(nsep+3,1);
    Fnay_N_ch=zeros(nsep+3,1);
    Fnay_mdf_N_all=zeros(nsep+3,1);
    Fnay_mdf_N_ch=zeros(nsep+3,1);
    
    div_fna_PSch_N_ch=zeros(ny+2,nx+2);
    div_fnax_nupar_N_ch=zeros(ny+2,nx+2);
    div_fnay_nupar_N_ch=zeros(ny+2,nx+2);
    [div_fna_nupar_N_ch,div_fnax_nupar_N_ch,div_fnay_nupar_N_ch]=calc_divergence(fnax_nupar_N_ch,fnay_nupar_N_ch,nx,ny,top,right);
    div_fna_nupar_N_ch=div_fna_nupar_N_ch./vol;
    div_fnax_nupar_N_ch=div_fnax_nupar_N_ch./vol;
    div_fnax_nupar_N_ch=div_fnay_nupar_N_ch./vol;

    div_upar_N_ch_avr=zeros(ny+2,nx+2);
    div_uparx_N_ch_avr=zeros(ny+2,nx+2);
    div_upary_N_ch_avr=zeros(ny+2,nx+2);
    [div_upar_N_ch_avr,div_uparx_N_ch_avr,div_upary_N_ch_avr]=calc_divergence(fnax_nupar_N_ch./nN_ch,fnay_nupar_N_ch./nN_ch,nx,ny,top,right);
    div_upar_N_ch_avr=div_upar_N_ch_avr./vol;
    div_uparx_N_ch_avr=div_uparx_N_ch_avr./vol;
    div_upary_N_ch_avr=div_upary_N_ch_avr./vol;

    div_uExB_N_ch_avr=zeros(ny+2,nx+2);
    div_uExBx_N_ch_avr=zeros(ny+2,nx+2);
    div_uExBy_N_ch_avr=zeros(ny+2,nx+2);
    [div_uExB_N_ch_avr,div_uExBx_N_ch_avr,div_uExBy_N_ch_avr]=calc_divergence(fnax_nuExB_N_ch./nN_ch,fnay_nuExB_N_ch./nN_ch,nx,ny,top,right);
    div_uExB_N_ch_avr=div_uExB_N_ch_avr./vol;
    div_uExBx_N_ch_avr=div_uExBx_N_ch_avr./vol;
    div_uExBy_N_ch_avr=div_uExBy_N_ch_avr./vol;

end;

%-------------------------------------------
% total neon fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
if exist('is_Ne01','var')
    fnax_Ne_ch     = fnax(:,:,is_Ne01)+fnax(:,:,is_Ne02)+fnax(:,:,is_Ne03)+fnax(:,:,is_Ne04)+fnax(:,:,is_Ne05)+fnax(:,:,is_Ne06)+fnax(:,:,is_Ne07)+fnax(:,:,is_Ne08)+fnax(:,:,is_Ne09)+fnax(:,:,is_Ne10);
    fnay_Ne_ch     = fnay(:,:,is_Ne01)+fnay(:,:,is_Ne02)+fnay(:,:,is_Ne03)+fnay(:,:,is_Ne04)+fnay(:,:,is_Ne05)+fnay(:,:,is_Ne06)+fnay(:,:,is_Ne07)+fnay(:,:,is_Ne08)+fnay(:,:,is_Ne09)+fnay(:,:,is_Ne10);
    fnax_mdf_Ne_ch = fnax_mdf(:,:,is_Ne01)+fnax_mdf(:,:,is_Ne02)+fnax_mdf(:,:,is_Ne03)+fnax_mdf(:,:,is_Ne04)+fnax_mdf(:,:,is_Ne05)+fnax_mdf(:,:,is_Ne06)+fnax_mdf(:,:,is_Ne07)+fnax_mdf(:,:,is_Ne08)+fnax_mdf(:,:,is_Ne09)+fnax_mdf(:,:,is_Ne10);
    fnay_mdf_Ne_ch = fnay_mdf(:,:,is_Ne01)+fnay_mdf(:,:,is_Ne02)+fnay_mdf(:,:,is_Ne03)+fnay_mdf(:,:,is_Ne04)+fnay_mdf(:,:,is_Ne05)+fnay_mdf(:,:,is_Ne06)+fnay_mdf(:,:,is_Ne07)+fnay_mdf(:,:,is_Ne08)+fnay_mdf(:,:,is_Ne09)+fnay_mdf(:,:,is_Ne10);
    
    fnax_nuExB_Ne_ch = fnax_nuExB(:,:,is_Ne01)+fnax_nuExB(:,:,is_Ne02)+fnax_nuExB(:,:,is_Ne03)+fnax_nuExB(:,:,is_Ne04)+fnax_nuExB(:,:,is_Ne05)+fnax_nuExB(:,:,is_Ne06)+fnax_nuExB(:,:,is_Ne07)+fnax_nuExB(:,:,is_Ne08)+fnax_nuExB(:,:,is_Ne09)+fnax_nuExB(:,:,is_Ne10);
    fnay_nuExB_Ne_ch = fnay_nuExB(:,:,is_Ne01)+fnay_nuExB(:,:,is_Ne02)+fnay_nuExB(:,:,is_Ne03)+fnay_nuExB(:,:,is_Ne04)+fnay_nuExB(:,:,is_Ne05)+fnay_nuExB(:,:,is_Ne06)+fnay_nuExB(:,:,is_Ne07)+fnay_nuExB(:,:,is_Ne08)+fnay_nuExB(:,:,is_Ne09)+fnay_nuExB(:,:,is_Ne10);
    fnax_Dgradn_Ne_ch = fnax_Dgradn(:,:,is_Ne01)+fnax_Dgradn(:,:,is_Ne02)+fnax_Dgradn(:,:,is_Ne03)+fnax_Dgradn(:,:,is_Ne04)+fnax_Dgradn(:,:,is_Ne05)+fnax_Dgradn(:,:,is_Ne06)+fnax_Dgradn(:,:,is_Ne07)+fnax_Dgradn(:,:,is_Ne08)+fnax_Dgradn(:,:,is_Ne09)+fnax_Dgradn(:,:,is_Ne10);
    fnay_Dgradn_Ne_ch = fnay_Dgradn(:,:,is_Ne01)+fnay_Dgradn(:,:,is_Ne02)+fnay_Dgradn(:,:,is_Ne03)+fnay_Dgradn(:,:,is_Ne04)+fnay_Dgradn(:,:,is_Ne05)+fnay_Dgradn(:,:,is_Ne06)+fnay_Dgradn(:,:,is_Ne07)+fnay_Dgradn(:,:,is_Ne08)+fnay_Dgradn(:,:,is_Ne09)+fnay_Dgradn(:,:,is_Ne10);
    fnax_nupar_Ne_ch = fnax_nupar(:,:,is_Ne01)+fnax_nupar(:,:,is_Ne02)+fnax_nupar(:,:,is_Ne03)+fnax_nupar(:,:,is_Ne04)+fnax_nupar(:,:,is_Ne05)+fnax_nupar(:,:,is_Ne06)+fnax_nupar(:,:,is_Ne07)+fnax_nupar(:,:,is_Ne08)+fnax_nupar(:,:,is_Ne09)+fnax_nupar(:,:,is_Ne10);
    fnay_nupar_Ne_ch = fnay_nupar(:,:,is_Ne01)+fnay_nupar(:,:,is_Ne02)+fnay_nupar(:,:,is_Ne03)+fnay_nupar(:,:,is_Ne04)+fnay_nupar(:,:,is_Ne05)+fnay_nupar(:,:,is_Ne06)+fnay_nupar(:,:,is_Ne07)+fnay_nupar(:,:,is_Ne08)+fnay_nupar(:,:,is_Ne09)+fnay_nupar(:,:,is_Ne10);
    fnax_PSch_Ne_ch = fnax_PSch(:,:,is_Ne01)+fnax_PSch(:,:,is_Ne02)+fnax_PSch(:,:,is_Ne03)+fnax_PSch(:,:,is_Ne04)+fnax_PSch(:,:,is_Ne05)+fnax_PSch(:,:,is_Ne06)+fnax_PSch(:,:,is_Ne07)+fnax_PSch(:,:,is_Ne08)+fnax_PSch(:,:,is_Ne08)+fnax_PSch(:,:,is_Ne10);
    fnay_PSch_Ne_ch = fnay_PSch(:,:,is_Ne01)+fnay_PSch(:,:,is_Ne02)+fnay_PSch(:,:,is_Ne03)+fnay_PSch(:,:,is_Ne04)+fnay_PSch(:,:,is_Ne05)+fnay_PSch(:,:,is_Ne06)+fnay_PSch(:,:,is_Ne07)+fnay_PSch(:,:,is_Ne08)+fnay_PSch(:,:,is_Ne08)+fnay_PSch(:,:,is_Ne10);
    fnax_dia_Ne_ch = fnax_dia(:,:,is_Ne01)+fnax_dia(:,:,is_Ne02)+fnax_dia(:,:,is_Ne03)+fnax_dia(:,:,is_Ne04)+fnax_dia(:,:,is_Ne05)+fnax_dia(:,:,is_Ne06)+fnax_dia(:,:,is_Ne07)+fnax_dia(:,:,is_Ne08)+fnax_dia(:,:,is_Ne09)+fnax_dia(:,:,is_Ne10);
    fnay_dia_Ne_ch = fnay_dia(:,:,is_Ne01)+fnay_dia(:,:,is_Ne02)+fnay_dia(:,:,is_Ne03)+fnay_dia(:,:,is_Ne04)+fnay_dia(:,:,is_Ne05)+fnay_dia(:,:,is_Ne06)+fnay_dia(:,:,is_Ne07)+fnay_dia(:,:,is_Ne08)+fnay_dia(:,:,is_Ne09)+fnay_dia(:,:,is_Ne10);

    fnax_Ne_all = fnax_Ne_ch + fnax(:,:,is_Ne01-1);
    fnay_Ne_all = fnay_Ne_ch + fnay(:,:,is_Ne01-1);
    fnax_mdf_Ne_all = fnax_mdf_Ne_ch + fnax_mdf(:,:,is_Ne01-1);
    fnay_mdf_Ne_all = fnay_mdf_Ne_ch + fnay_mdf(:,:,is_Ne01-1);
    
    nNe_ch = na(:,:,is_Ne01)+na(:,:,is_Ne02)+na(:,:,is_Ne03)+na(:,:,is_Ne04)+na(:,:,is_Ne05)+na(:,:,is_Ne06)+na(:,:,is_Ne07)+na(:,:,is_Ne08)+na(:,:,is_Ne09)+na(:,:,is_Ne10);
    nNe_tot = nNe_ch+na(:,:,is_Ne01-1);

    smotf_ii_gradTi_Netot = smotf_ii_gradTi(:,:,is_Ne01)+smotf_ii_gradTi(:,:,is_Ne02)+smotf_ii_gradTi(:,:,is_Ne03)+smotf_ii_gradTi(:,:,is_Ne04)+smotf_ii_gradTi(:,:,is_Ne05)+...
        smotf_ii_gradTi(:,:,is_Ne06)+smotf_ii_gradTi(:,:,is_Ne07)+smotf_ii_gradTi(:,:,is_Ne08)+smotf_ii_gradTi(:,:,is_Ne09)+smotf_ii_gradTi(:,:,is_Ne10);

    smogpi_Ne_ch=(smogpi(:,:,is_Ne01)+smogpi(:,:,is_Ne02)+smogpi(:,:,is_Ne03)+smogpi(:,:,is_Ne04)+smogpi(:,:,is_Ne05)+smogpi(:,:,is_Ne06)+smogpi(:,:,is_Ne07)+smogpi(:,:,is_Ne08)+smogpi(:,:,is_Ne09)+smogpi(:,:,is_Ne10))./vol./hz;
    smochi_Ne_ch=(smochi(:,:,is_Ne01)+smochi(:,:,is_Ne02)+smochi(:,:,is_Ne03)+smochi(:,:,is_Ne04)+smochi(:,:,is_Ne05)+smochi(:,:,is_Ne06)+smochi(:,:,is_Ne07)+smochi(:,:,is_Ne08)+smochi(:,:,is_Ne09)+smochi(:,:,is_Ne10))./vol./hz;
    smotf_ii_gradTi_Ne_ch=(smotf_ii_gradTi(:,:,is_Ne01)+smotf_ii_gradTi(:,:,is_Ne02)+smotf_ii_gradTi(:,:,is_Ne03)+smotf_ii_gradTi(:,:,is_Ne04)+smotf_ii_gradTi(:,:,is_Ne05)+smotf_ii_gradTi(:,:,is_Ne06)+smotf_ii_gradTi(:,:,is_Ne07)+smotf_ii_gradTi(:,:,is_Ne08)+smotf_ii_gradTi(:,:,is_Ne09)+smotf_ii_gradTi(:,:,is_Ne10))./vol./hz;
    Eforce_Ne_ch=(Za(is_Ne01)*na(:,:,is_Ne01)+Za(is_Ne02)*na(:,:,is_Ne02)+Za(is_Ne03)*na(:,:,is_Ne03)+Za(is_Ne04)*na(:,:,is_Ne04)+Za(is_Ne05)*na(:,:,is_Ne05)+Za(is_Ne06)*na(:,:,is_Ne06)+Za(is_Ne07)*na(:,:,is_Ne07)+Za(is_Ne08)*na(:,:,is_Ne08)+Za(is_Ne09)*na(:,:,is_Ne09)+Za(is_Ne10)*na(:,:,is_Ne10)).*E_x.*Bx./B*qe;

    Fnay_Ne_all=zeros(nsep+3,1);
    Fnay_Ne_ch=zeros(nsep+3,1);
    Fnay_mdf_Ne_all=zeros(nsep+3,1);
    Fnay_mdf_Ne_ch=zeros(nsep+3,1);

end;

for i=nsep+1:-1:-1
    for is=1:ns
      Fnay_core(i+2,is) = poloidal_int_core_DND(fnay(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_mdf_core(i+2,is) = poloidal_int_core_DND(fnay_mdf(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);
      
      Fnay_Dgradn_core(i+2,is) = poloidal_int_core_DND(fnay_Dgradn(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_nuAN_core(i+2,is) = poloidal_int_core_DND(fnay_nuAN(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_nuExB_core(i+2,is) = poloidal_int_core_DND(fnay_nuExB(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_PSch_core(i+2,is) = poloidal_int_core_DND(fnay_PSch(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      
      if i<=nsep
           Snay_core(i+2,is) = poloidal_int_core_DND(sna(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);
           if EIRENE_flag == 1
               Snay_core_eir(i+2,is) = poloidal_int_core_DND(sna_eir(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);
           end;
           Snay_core_sral(i+2,is) = poloidal_int_core_DND(sna_sral(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);
           dFnay_mdf_core_dy(i+2,is)=Fnay_mdf_core(i+3,is) - Fnay_mdf_core(i+2,is);
      end; 
    end;
      
    Fnay_jAN_core(i+2) = poloidal_int_core_DND(jy_AN,nx,ny,nc1,nc2,nc3,nc4,i);  
    Fnay_jvispar_core(i+2) = poloidal_int_core_DND(jy_vispar,nx,ny,nc1,nc2,nc3,nc4,i);  
    Fnay_jvisper_core(i+2) = poloidal_int_core_DND(jy_visper,nx,ny,nc1,nc2,nc3,nc4,i);  
    Fnay_jvisq_core(i+2) = poloidal_int_core_DND(jy_visq,nx,ny,nc1,nc2,nc3,nc4,i);  
    Fnay_jinert_core(i+2) = poloidal_int_core_DND(jy_inert,nx,ny,nc1,nc2,nc3,nc4,i);
    
    if exist('is_He01','var')
        Fnay_mdf_He_ch(i+2)=poloidal_int_core_DND(fnay_mdf_He_ch,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_mdf_He_all(i+2)=poloidal_int_core_DND(fnay_mdf_He_all,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_He_ch(i+2)=poloidal_int_core_DND(fnay_He_ch,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_He_all(i+2)=poloidal_int_core_DND(fnay_He_all,nx,ny,nc1,nc2,nc3,nc4,i);
    end;

    if exist('is_N01','var')
        Fnay_mdf_N_ch(i+2)=poloidal_int_core_DND(fnay_mdf_N_ch,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_mdf_N_all(i+2)=poloidal_int_core_DND(fnay_mdf_N_all,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_N_ch(i+2)=poloidal_int_core_DND(fnay_N_ch,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_N_all(i+2)=poloidal_int_core_DND(fnay_N_all,nx,ny,nc1,nc2,nc3,nc4,i);
    end;
    
    if exist('is_Ne01','var')
        Fnay_mdf_Ne_ch(i+2)=poloidal_int_core_DND(fnay_mdf_Ne_ch,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_mdf_Ne_all(i+2)=poloidal_int_core_DND(fnay_mdf_Ne_all,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_Ne_ch(i+2)=poloidal_int_core_DND(fnay_Ne_ch,nx,ny,nc1,nc2,nc3,nc4,i);
        Fnay_Ne_all(i+2)=poloidal_int_core_DND(fnay_Ne_all,nx,ny,nc1,nc2,nc3,nc4,i);
    end;
    
    Fhey_core(i+2) = poloidal_int_core_DND(fhey,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhey_mdf_core(i+2) = poloidal_int_core_DND(fhey_mdf,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhey_52uExB_core(i+2) = poloidal_int_core_DND(fhey_mdf+fhe_ExBy,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhey_ke_gTy_core(i+2) = poloidal_int_core_DND(fhey_ke_gTy,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhey_32GammaT_core(i+2) = poloidal_int_core_DND(fhey_32GammaT,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhey_PSch_core(i+2) = poloidal_int_core_DND(fhey_PSch,nx,ny,nc1,nc2,nc3,nc4,i);
      
    Fhiy_core(i+2) = poloidal_int_core_DND(fhiy,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhiy_mdf_core(i+2) = poloidal_int_core_DND(fhiy_mdf,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhiy_52uExB_core(i+2) = poloidal_int_core_DND(fhiy_mdf+fhi_ExBy,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhiy_ki_gTy_core(i+2) = poloidal_int_core_DND(fhiy_ki_gTy,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhiy_32GammaT_core(i+2) = poloidal_int_core_DND(fhiy_32GammaT,nx,ny,nc1,nc2,nc3,nc4,i);
    Fhiy_PSch_core(i+2) = poloidal_int_core_DND(fhiy_PSch,nx,ny,nc1,nc2,nc3,nc4,i);
    
    Jy(i+2) = poloidal_int_core_DND(jy,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_in(i+2) = poloidal_int_core_DND(jy_in,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_inert(i+2) = poloidal_int_core_DND(jy_inert,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_visper(i+2) = poloidal_int_core_DND(jy_visper,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_vispar(i+2) = poloidal_int_core_DND(jy_vispar,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_visq(i+2) = poloidal_int_core_DND(jy_visq,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_AN(i+2) = poloidal_int_core_DND(jy_AN,nx,ny,nc1,nc2,nc3,nc4,i);
    Jy_dia(i+2) = poloidal_int_core_DND(jy_dia,nx,ny,nc1,nc2,nc3,nc4,i);
    

end;

for j=-1:nx
        if EIRENE_flag 
             Sna_eir_intx(j+2) = radial_integral(sna_eir(:,:,is_D01),nsep-6,nsep,j);
        end;
        Fnax_D01_intx(j+2) = radial_integral(fnax(:,:,is_D01),nsep-6,nsep,j);
        Fnax_D01_intx_CORE_PFR(j+2) = radial_integral(fnax(:,:,is_D01),0,nsep,j);
        Fnax_mdf_D01_intx(j+2) = radial_integral(fnax_mdf(:,:,is_D01),nsep-6,nsep,j);
        Fnax_tot_D01_intx_CORE_PFR(j+2) = radial_integral(fnax_mdf(:,:,is_D01)+fnax_PSch(:,:,is_D01)+fnax_dia(:,:,is_D01),0,nsep,j);
        Fnax_nupar_D01_intx(j+2) = radial_integral(fnax_nupar(:,:,is_D01),nsep-6,nsep,j); 
        Fnax_nupar_D01_intx_CORE_PFR(j+2) = radial_integral(fnax_nupar(:,:,is_D01),0,nsep,j); 
        Fnax_nuExB_D01_intx_CORE_PFR(j+2) = radial_integral(fnax_nuExB(:,:,is_D01),0,nsep,j); 
        Fnax_Dgradn_D01_intx_CORE_PFR(j+2) = radial_integral(fnax_Dgradn(:,:,is_D01),0,nsep,j); 
        Fnax_D01_intx_SOL(j+2) = radial_integral(fnax(:,:,is_D01),nsep+1,ny-1,j);
        Fnax_tot_D01_intx_SOL(j+2) = radial_integral(fnax_mdf(:,:,is_D01)+fnax_PSch(:,:,is_D01),nsep+1,ny-1,j);
        Fnax_nupar_D01_intx_SOL(j+2) = radial_integral(fnax_nupar(:,:,is_D01),nsep+1,ny-1,j); 
        Fnax_nuExB_D01_intx_SOL(j+2) = radial_integral(fnax_nuExB(:,:,is_D01),nsep+1,ny-1,j); 
        Fnax_Dgradn_D01_intx_SOL(j+2) = radial_integral(fnax_Dgradn(:,:,is_D01),nsep+1,ny-1,j); 
        if exist('is_N01','var')
           Fnax_tot_N_ch_intx_CORE_PFR(j+2) = radial_integral(fnax_mdf_N_ch+fnax_PSch_N_ch+fnax_dia_N_ch,0,nsep,j);
           Fnax_nuExB_N_ch_intx_CORE_PFR(j+2) = radial_integral(fnax_nuExB_N_ch,0,nsep,j);
           Fnax_nupar_N_ch_intx_CORE_PFR(j+2) = radial_integral(fnax_nupar_N_ch,0,nsep,j);
           Fnax_Dgradn_N_ch_intx_CORE_PFR(j+2) = radial_integral(fnax_Dgradn_N_ch,0,nsep,j);
           Fnax_tot_N_ch_intx_SOL(j+2) = radial_integral(fnax_mdf_N_ch+fnax_PSch_N_ch+fnax_dia_N_ch,nsep+1,ny-1,j);
           Fnax_nuExB_N_ch_intx_SOL(j+2) = radial_integral(fnax_nuExB_N_ch,nsep+1,ny-1,j);
           Fnax_nupar_N_ch_intx_SOL(j+2) = radial_integral(fnax_nupar_N_ch,nsep+1,ny-1,j);
           Fnax_Dgradn_N_ch_intx_SOL(j+2) = radial_integral(fnax_Dgradn_N_ch,nsep+1,ny-1,j);
        end;
end;




      
% % % % % % % % % % % % % % %     jx_prll=readdatavalue([PATH_PREFIX 'b2tfhe_fch_px.dat'],nx,ny); %parallel current
% % % % % % % % % % % % % % %     jy_prll = zeros(ny+2,nx+2); % dummy
% % % % % % % % % % % % % % %     jx_in=readdatavalue([PATH_PREFIX 'b2tfhe_fchinx.dat'],nx,ny); % ion-neutral current
% % % % % % % % % % % % % % %     jy_in=readdatavalue([PATH_PREFIX 'b2tfhe_fchiny.dat'],nx,ny); % ion-neutral current
% % % % % % % % % % % % % % %     jx_inert=readdatavalue([PATH_PREFIX 'b2tfhe_fchinertx.dat'],nx,ny); % inertial current
% % % % % % % % % % % % % % %     jy_inert=readdatavalue([PATH_PREFIX 'b2tfhe_fchinerty.dat'],nx,ny); % inertial current
% % % % % % % % % % % % % % %     jx_visper=zeros(ny+2,nx+2); % due to perp viscousity
% % % % % % % % % % % % % % %     jy_visper=readdatavalue([PATH_PREFIX 'b2tfhe_fchvispery.dat'],nx,ny); % due to perp viscousity
% % % % % % % % % % % % % % %     jx_vispar=readdatavalue([PATH_PREFIX 'b2tfhe_fchvisparx.dat'],nx,ny); % due to parll viscousity
% % % % % % % % % % % % % % %     jy_vispar=readdatavalue([PATH_PREFIX 'b2tfhe_fchvispary.dat'],nx,ny); % due to parll viscousity
% % % % % % % % % % % % % % %     jx_visq = zeros(ny+2,nx+2);
% % % % % % % % % % % % % % %     jy_visq = readdatavalue([PATH_PREFIX 'b2tfhe_fchvisqy.dat'],nx,ny);
% % % % % % % % % % % % % % %     jx_AN=readdatavalue([PATH_PREFIX 'b2tfhe_fchanmlx.dat'],nx,ny); % artificial 'anomalous' current
% % % % % % % % % % % % % % %     jy_AN=readdatavalue([PATH_PREFIX 'b2tfhe_fchanmly.dat'],nx,ny); % artificial 'anomalous' current
% % % % % % % % % % % % % % %     jx_dia=readdatavalue([PATH_PREFIX 'b2tfhe_fchdiax.dat'],nx,ny); % diamagnetic current
% % % % % % % % % % % % % % %     jy_dia=readdatavalue([PATH_PREFIX 'b2tfhe_fchdiay.dat'],nx,ny); % diamagnetic current
% % % % % % % % % % % % % % %     jx_stoch=zeros(ny+2,nx+2);
% % % % % % % % % % % % % % %     jy_stoch=readdatavalue([PATH_PREFIX 'b2tfhe_fchstoch.dat'],nx,ny); % radial current due to magnetic field stochastisity
% % % % % % % % % % % % % % % 

% % % %       Fnay_jAN_core(i+2) = poloidal_int_core_DND(jy_AN,nx,ny,nc1,nc2,nc3,nc4,i);  
% % % %       Fnay_jvispar_core(i+2) = poloidal_int_core_DND(jy_vispar,nx,ny,nc1,nc2,nc3,nc4,i);  
% % % %       Fnay_jvisper_core(i+2) = poloidal_int_core_DND(jy_visper,nx,ny,nc1,nc2,nc3,nc4,i);  
% % % %       Fnay_jvisq_core(i+2) = poloidal_int_core_DND(jy_visq,nx,ny,nc1,nc2,nc3,nc4,i);  
% % % %       Fnay_jinert_core(i+2) = poloidal_int_core_DND(jy_inert,nx,ny,nc1,nc2,nc3,nc4,i);
% % % % 
% % % %       Fhey_core(i+2) = poloidal_int_core_DND(fhey,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhey_mdf_core(i+2) = poloidal_int_core_DND(fhey_mdf,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhey_52uExB_core(i+2) = poloidal_int_core_DND(fhey_mdf+fhe_ExBy,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhey_ke_gTy_core(i+2) = poloidal_int_core_DND(fhey_ke_gTy,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhey_32GammaT_core(i+2) = poloidal_int_core_DND(fhey_32GammaT,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhey_PSch_core(i+2) = poloidal_int_core_DND(fhey_PSch,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       
% % % %       Fhiy_core(i+2) = poloidal_int_core_DND(fhiy,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhiy_mdf_core(i+2) = poloidal_int_core_DND(fhiy_mdf,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhiy_52uExB_core(i+2) = poloidal_int_core_DND(fhiy_mdf+fhi_ExBy,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhiy_ki_gTy_core(i+2) = poloidal_int_core_DND(fhiy_ki_gTy,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhiy_32GammaT_core(i+2) = poloidal_int_core_DND(fhiy_32GammaT,nx,ny,nc1,nc2,nc3,nc4,i);
% % % %       Fhiy_PSch_core(i+2) = poloidal_int_core_DND(fhiy_PSch,nx,ny,nc1,nc2,nc3,nc4,i);
      

Zeff=ne2./ne;
Zimp2=ni_impZ2./na(:,:,is_main);
cs=sqrt(1.0/mp.*pas./nasm);
cs_mi=sqrt((te+ti)/(Amain*mp/qe)); % sound speed computed through the main ion pressure only
jsat=Bx./B.*na(:,:,2)*qe.*cs_mi;

hce = hce ./ ne;
hci(:,:,ns+1) = hci(:,:,ns+1) ./ ni(:,:,1);

%-------------------------------------------
% divergence of momentum fluxes (as tensor)
%-------------------------------------------

div_fmo=zeros(ny+2,nx+2,ns);
div_fmo_x=zeros(ny+2,nx+2,ns);
div_fmo_y=zeros(ny+2,nx+2,ns);

for is=1:ns
    
    if Za(is) >0 
        
        [div_fmo_x(:,:,is),div_fmo_y(:,:,is),div_fmo(:,:,is)]=calc_divergence(fmox(:,:,is),fmoy(:,:,is),nx,ny,top,right);
%clear div_fve_x;
%clear div_fve_y;
        div_fmo_x(:,:,is)=div_fmo_x(:,:,is);%./vol./hz;
        div_fmo_y(:,:,is)=div_fmo_y(:,:,is);%./vol./hz;
        div_fmo(:,:,is)=div_fmo(:,:,is);%./vol./hz;
    end;
end;

%-------------------------------------------
% temperature gradients
%-------------------------------------------

zlamee=1.5e16.*te(:,:).*te(:,:)./ne(:,:);
zlamii=1.5e16.*ti(:,:).*te(:,:)./ne2(:,:);

dti=zeros(ny+2,nx+2);
dte=zeros(ny+2,nx+2);

for i=2:ny+1
    for j=2:nx+1
        if right(i,j) ~= nx+1 && left(i,j) ~= -2
            dte(i,j) =(te(i,j)-te(i,right(i,j)+2))./(hx(i,j)+hx(i,right(i,j)+2))+(te(i,left(i,j)+2)-te(i,j))./(hx(i,left(i,j)+2)+hx(i,j));
            dti(i,j) =(ti(i,j)-ti(i,right(i,j)+2))./(hx(i,j)+hx(i,right(i,j)+2))+(ti(i,left(i,j)+2)-ti(i,j))./(hx(i,left(i,j)+2)+hx(i,j));
        end;
    end;
end;

dteapr(:,:)=0.3./zlamee.*te(:,:)./abs(Bx(:,:)./B(:,:));
dtiapr(:,:)=0.3./zlamii.*ti(:,:)./abs(Bx(:,:)./B(:,:));

dte(:,:)=sign(dte(:,:)).*min(abs(dte(:,:)),dteapr(:,:));
dti(:,:)=sign(dti(:,:)).*min(abs(dti(:,:)),dtiapr(:,:));

%-------------------------------------------
% thermal force coefficients
%-------------------------------------------

% % % % % % % % smotf_ie_u_0_c=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ie_u_1_c=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ie_gradTe_c=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ii_gradTi_c=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ie_u_0_cc=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ie_u_1_cc=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ie_gradTe_cc=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ii_gradTi_cc=zeros(ny+2,nx+2,ns);
% % % % % % % % smotf_ii_gradTi_ccc=zeros(ny+2,nx+2,ns);
% % % % % % % % 
% % % % % % % % smoch_ii=zeros(ny+2,nx+2,ns,ns);
% % % % % % % % 
% % % % % % % % alx=zeros(ny+2,nx+2);
% % % % % % % % alx_imp=zeros(ny+2,nx+2);
% % % % % % % % btx=zeros(ny+2,nx+2);
% % % % % % % % btx_imp=zeros(ny+2,nx+2);
% % % % % % % % 
% % % % % % % % 
% % % % % % % % alx=(1+0.24.*Zeff).*(1+0.93.*Zeff)./(1+2.56.*Zeff)./(1+0.29.*Zeff);
% % % % % % % % alx_imp=(1+0.24.*Zimp2).*(1+0.93.*Zimp2)./(1+2.56.*Zimp2)./(1+0.29.*Zimp2);
% % % % % % % % btx=1.56.*(1+1.4.*Zeff).*(1+0.52.*Zeff)./(1+2.56.*Zeff)./(1+0.29.*Zeff);
% % % % % % % % btx_imp=1.56.*(1+1.4.*Zimp2).*(1+0.52.*Zimp2)./(1+2.56.*Zimp2)./(1+0.29.*Zimp2);
% % % % % % % % 
% % % % % % % % 
% % % % % % % % for is=1:ns
% % % % % % % %    smotf_ie_u_1_c(:,:,is)=-0.51*me.*na(:,:,is)*Za(is)*Za(is).*vol(:,:).*hz(:,:)./(csiglcn(:,:).*taue(:,:));
% % % % % % % %    smotf_ie_u_0_c(:,:,is)=0.51*me.*na(:,:,is)*Za(is)*Za(is).*vol(:,:).*hz(:,:).*ue(:,:)./(csiglcn(:,:).*taue(:,:));
% % % % % % % %    smotf_ie_gradTe_c(:,:,is)=-0.71*qe.*na(:,:,is)*Za(is)*Za(is).*cheflim(:,:).*dte(:,:).*vol(:,:).*hz(:,:).*Bx(:,:)./B(:,:);
% % % % % % % %    smotf_ii_gradTi_c(:,:,is)=-1.56*qe.*na(:,:,is)*Za(is)*Za(is).*cheflim(:,:).*dti(:,:).*vol(:,:).*hz(:,:).*Bx(:,:)./B(:,:);
% % % % % % % % 
% % % % % % % %    %coeff2e(:,:)=1.56/(1+1/sqrt(2)).*(1+1.4.*Zeff(:,:)).*(1+0.52.*Zeff(:,:))./(1+2.65.*Zeff(:,:))./(1+0.29.*Zeff(:,:));
% % % % % % % %    coeff2e(:,:)=1.56./(Zeff(:,:)+sqrt(2)/2).*(1+1.4.*Zeff(:,:)).*(1+0.52.*Zeff(:,:))./(1+2.65.*Zeff(:,:))./(1+0.29.*Zeff(:,:));
% % % % % % % %    coeff3(:,:)=2.2.*Zeff(:,:).*(1+0.52.*Zeff(:,:))./(1+2.65.*Zeff(:,:))./(1+0.29.*Zeff);
% % % % % % % % 
% % % % % % % %    smotf_ie_u_1_cc(:,:,is) = -me.* alx .* na(:,:,is) * Za(is)*Za(is) .* vol .* hz ./ (csiglcn .* taue) .* ne./ne2;
% % % % % % % %    smotf_ie_u_0_cc(:,:,is) =  me.* alx .* na(:,:,is) * Za(is)*Za(is) .* vol .* hz ./(csiglcn .* taue ) .* ne./ne2 .* ue;
% % % % % % % %    %wrk2cc(:,:,is)=-qe.* coeff3(:,:).*na(:,:,is)*Za(is)*Za(is).*cheflim(:,:).*dte(:,:).*vol(:,:).*hz(:,:).*Bx(:,:)./B(:,:);
% % % % % % % %    smotf_ie_gradTe_cc(:,:,is) = - qe.* btx ./ (Zeff + sqrt(2)/2) .* na(:,:,is) * Za(is)*Za(is) .* cheflim .* dte .* vol .* hz .* Bx ./ B;
% % % % % % % %    %wrk3cc(:,:,is)=-qe.* coeff2(:,:).*na(:,:,is)*Za(is)*Za(is).*cheflim(:,:).*dti(:,:).*vol(:,:).*hz(:,:).*Bx(:,:)./B(:,:);
% % % % % % % %    if is ~= is_main 
% % % % % % % %        smotf_ii_gradTi_cc(:,:,is)= - qe.* btx_imp .* na(:,:,is).* na(:,:,is_main) * Za(is)*Za(is)/sqrt(1.0+Am(is_main)/Am(is)) .* cheflim .* dti .* vol .* hz .* Bx ./ B ./ ni_Zsqrtm;
% % % % % % % %    end;
% % % % % % % % end;
% % % % % % % % 
% % % % % % % % for is=1:ns
% % % % % % % %       if is ~= is_main 
% % % % % % % %          smotf_ii_gradTi_cc(:,:,is_main) = smotf_ii_gradTi_cc(:,:,is_main) - smotf_ii_gradTi_cc(:,:,is);
% % % % % % % %    end;
% % % % % % % % end;
% % % % % % % % 
% % % % % % % % %-------------------------------------------
% % % % % % % % % thermal force 
% % % % % % % % %-------------------------------------------
% % % % % % % % 
% % % % % % % % %smotfc=zeros(ny+2,nx+2,ns);
% % % % % % % % %smotfcc=zeros(ny+2,nx+2,ns);
% % % % % % % % %smotfccc=zeros(ny+2,nx+2,ns);
% % % % % % % % 
% % % % % % % % %for is=1:ns
% % % % % % % %     smotf_c = smotf_ie_u_1_c.*ua + smotf_ie_u_0_c + smotf_ie_gradTe_c + smotf_ii_gradTi_c;
% % % % % % % %     smotf_cc = smotf_ie_u_1_cc.*ua + smotf_ie_u_0_cc + smotf_ie_gradTe_cc + smotf_ii_gradTi_cc;
% % % % % % % % %    smotfccc(:,:,is) = wrk0cc(:,:,is).*ua(:,:,is)+wrk1cc(:,:,is)+wrk2cc(:,:,is)+wrk3ccc(:,:,is);
% % % % % % % % 
% % % % % % % % %end;
% % % % % % % % 
% % % % % % % % 
% % % % % % % % %-------------------------------------------
% % % % % % % % % friction force
% % % % % % % % %-------------------------------------------
% % % % % % % % 
% % % % % % % % taue_cc = 1.0 ./ ( 4/3 * sqrt(pi*2/me) .* Lambda_Coulomb_b2sifr * qe^4 / (4*pi*epsilon_0)^2 .* ne2 ./ (te(:,:)*qe) ./ sqrt((te(:,:))*qe) );
% % % % % % % % 
% % % % % % % % zeta_p =  1.0 ./ ( 4/3 * sqrt(pi*2/mp) .* Lambda_Coulomb_b2sifr * qe^4 / (4*pi*epsilon_0)^2 ./ (ti(:,:)*qe) ./ sqrt((ti(:,:))*qe) );
% % % % % % % % sqrt2mp_over_zeta_p = sqrt(2)*mp ./ zeta_p;
% % % % % % % % 
% % % % % % % % smoch_ii_u0_cc = zeros(ny+2,nx+2,ns,ns);
% % % % % % % % smoch_ii_u1_cc = zeros(ny+2,nx+2,ns,ns);
% % % % % % % % 
% % % % % % % % smoch_c=zeros(ny+2,nx+2,ns);
% % % % % % % % smoch_cc=zeros(ny+2,nx+2,ns);
% % % % % % % % 
% % % % % % % % 
% % % % % % % % for is1=1:ns
% % % % % % % %     for is2=1:ns
% % % % % % % %         smoch_ii_0_cc(:,:,is1,is2) =   sqrt2mp_over_zeta_p .* na(:,:,is1) .* na(:,:,is2) * (Za(is1)*Za(is1) * Za(is2)*Za(is2)) * sqrt(Am(is1)*Am(is2)/(Am(is1)+Am(is2))) .* vol .* hz .* ua(:,:,is2);
% % % % % % % %         smoch_ii_1_cc(:,:,is1,is2) = - sqrt2mp_over_zeta_p .* na(:,:,is1) .* na(:,:,is2) * (Za(is1)*Za(is1) * Za(is2)*Za(is2)) * sqrt(Am(is1)*Am(is2)/(Am(is1)+Am(is2))) .* vol .* hz;
% % % % % % % %         if is1 == is_main || is2 == is_main
% % % % % % % %             smoch_ii_0_cc(:,:,is1,is2) = smoch_ii_0_cc(:,:,is1,is2) .* alx_imp;
% % % % % % % %             smoch_ii_1_cc(:,:,is1,is2) = smoch_ii_1_cc(:,:,is1,is2) .* alx_imp;
% % % % % % % %         end;
% % % % % % % %         smoch_cc(:,:,is1) = smoch_cc(:,:,is1) + smoch_ii_0_cc(:,:,is1,is2) + smoch_ii_1_cc(:,:,is1,is2) .* ua(:,:,is1);
% % % % % % % %     end;
% % % % % % % % end;
% % % % % % % %         
% % % % % % % % 
% % % % % % % % %frbase(:,:)=  8/3*sqrt(pi*2*mp).*(Lambda_Coulomb_b2sifr(:,:).*qe^4)/(4*pi*epsilon_0)^2.*vol(:,:).*hz(:,:).*na(:,:,2)./(ti(:,:)*qe)./sqrt((ti(:,:))*qe);
% % % % % % % % %frbasecc(:,:)=8/3*sqrt(pi*2*mp).*(Lambda_Coulomb_b2sifr(:,:).*qe^4)/(4*pi*epsilon_0)^2.*coeff1i(:,:).*vol(:,:).*hz(:,:).*na(:,:,2)./(ti(:,:)*qe)./sqrt((ti(:,:))*qe);
% % % % % % % % 
% % % % % % % % %----------------------------------------
% % % % % % % % % sum of the friction and thermal forces over all ions
% % % % % % % % %-----------------------------------
% % % % % % % % 
% % % % % % % % smoch_sum=zeros(ny+2,nx+2);
% % % % % % % % smotf_ii_sum =zeros(ny+2,nx+2);
% % % % % % % % 
% % % % % % % % for is=1:ns
% % % % % % % %     smoch_sum = smoch_sum + smoch_cc(:,:,is);
% % % % % % % %     smotf_ii_sum = smotf_ii_sum + smotf_ii_gradTi_cc(:,:,is);
% % % % % % % % end;


% [div_fmo_x(:,:,4),div_fmo_y(:,:,4),div_fmo(:,:,4)]=calc_divergence(fmox(:,:,4),fmoy(:,:,4),nx,ny,top,right);
% %clear div_fve_x;
% %clear div_fve_y;
% div_fmo_x(:,:,4)=div_fmo_x(:,:,4);%./vol./hz;
% div_fmo_y(:,:,4)=div_fmo_y(:,:,4);%./vol./hz;
% div_fmo(:,:,4)=div_fmo(:,:,4);%./vol./hz;
% 
% [div_fmo_x(:,:,5),div_fmo_y(:,:,5),div_fmo(:,:,5)]=calc_divergence(fmox(:,:,5),fmoy(:,:,5),nx,ny,top,right);
% %clear div_fve_x;
% %clear div_fve_y;
% div_fmo_x(:,:,5)=div_fmo_x(:,:,5);%./vol./hz;
% div_fmo_y(:,:,5)=div_fmo_y(:,:,5);%./vol./hz;
% div_fmo(:,:,5)=div_fmo(:,:,5);%./vol./hz;
% 
% [div_fmo_x(:,:,6),div_fmo_y(:,:,6),div_fmo(:,:,6)]=calc_divergence(fmox(:,:,6),fmoy(:,:,6),nx,ny,top,right);
% %clear div_fve_x;
% %clear div_fve_y;
% div_fmo_x(:,:,6)=div_fmo_x(:,:,6);%./vol./hz;
% div_fmo_y(:,:,6)=div_fmo_y(:,:,6);%./vol./hz;
% div_fmo(:,:,6)=div_fmo(:,:,6);%./vol./hz;

%--------------------------------------------
% current density
% -------------------------------------------

jx_dens=zeros(ny+2,nx+2);
jxc_dens=zeros(ny+2,nx+2);
jx_prll_dens=zeros(ny+2,nx+2);
j_prllc_dens=zeros(ny+2,nx+2);   % reserved for true parallel current density, j_prll * bx = jx_prll
jx_prllc_dens=zeros(ny+2,nx+2);  % reserved for poloidal projection of parallel current density
jy_dens=zeros(ny+2,nx+2);
jyc_dens=zeros(ny+2,nx+2);
sigx_Ebx=zeros(ny+2,nx+2);
sigx_luc_Ebx=zeros(ny+2,nx+2);
sigxc_Ebx=zeros(ny+2,nx+2);
sigxc_luc_Ebx=zeros(ny+2,nx+2);
sigxc_luc_true=zeros(ny+2,nx+2);
Ohm_ratio=zeros(ny+2,nx+2);
Ohm_ratio_c=zeros(ny+2,nx+2);


for i=1:ny+2
    for j=1:nx+2
    if left(i,j) ~= -2 
        jx_dens(i,j) = qe*jx(i,j)*(hx(i,j)+hx(i,left(i,j)+2))/(vol(i,j)+vol(i,left(i,j)+2));
        jxc_dens(i,j) = 0.5*(jx_dens(i,j)+jx_dens(i,left(i,j)+2));
        jx_prll_dens(i,j) = qe*jx_prll(i,j)*(hx(i,j)+hx(i,left(i,j)+2))/(vol(i,j)+vol(i,left(i,j)+2));
        jx_prllc_dens(i,j) = 0.5*(jx_prll_dens(i,j)+jx_prll_dens(i,left(i,j)+2));
        j_prllc_dens(i,j) = jx_prllc_dens(i,j) / 0.5 / (Bx(i,left(i,j)+2)/B(i,left(i,j)+2) + Bx(i,j)/B(i,j)); 
        sigx_Ebx(i,j) = sigx(i,j)*(po(i,left(i,j)+2)-po(i,j))*(hx(i,j)+hx(i,left(i,j)+2))/(vol(i,j)+vol(i,left(i,j)+2));
        sigx_luc_Ebx(i,j) = sigx_luc(i,j)*(po(i,left(i,j)+2)-po(i,j))*(hx(i,j)+hx(i,left(i,j)+2))/(vol(i,j)+vol(i,left(i,j)+2));
        sigxc_Ebx(i,j)=0.5*(sigx_Ebx(i,j)+sigx_Ebx(i,left(i,j)+2));
        sigxc_luc_Ebx(i,j)=0.5*(sigx_luc_Ebx(i,j)+sigx_luc_Ebx(i,left(i,j)+2));
        sigxc_luc_true(i,j)= sigxc_luc_Ebx(i,j) * (hx(i,j)+hx(i,left(i,j)+2)) / ( 0.5 * (Bx(i,left(i,j)+2)/B(i,left(i,j)+2) + Bx(i,j)/B(i,j)))^2 / (po(i,left(i,j)+2)-po(i,j));
        
        Ohm_ratio(i,j)=abs( jx_prll(i,j) / sigx(i,j) ) / (abs( jx_prll(i,j) / sigx(i,j) ) + abs( jx_prll(i,j) / sigx(i,j) + (po(i,j) - po(i,left(i,j)+2))/qe ) );
        Ohm_ratio_c(i,j)=0.5*(Ohm_ratio(i,j)+Ohm_ratio(i,left(i,j)+2));
    end;
    if bottom(i,j) ~= -2 
        jy_dens(i,j) = qe*jy(i,j)*(hy1(i,j)+hy1(bottom(i,j)+2,j))/(vol(i,j)+vol(bottom(i,j)+2,j));
        jyc_dens(i,j) = 0.5*(jy_dens(i,j)+jy_dens(bottom(i,j)+2,j));
    end;
    end;
end;


%-------------------------------------------
% divergence of parallel current
%-------------------------------------------

div_j_prll=zeros(ny+2,nx+2);
div_j_prll_x=zeros(ny+2,nx+2);
div_j_prll_y=zeros(ny+2,nx+2);
[div_j_prll_x,div_j_prll_y,div_j_prll]=calc_divergence(jx_prll,jy_prll,nx,ny,top,right);
clear div_j_prll_x;
clear div_j_prll_y;
div_j_prll=div_j_prll*qe./vol;


%-------------------------------------------
% divergence of diamagnetic current
%-------------------------------------------

div_j_dia=zeros(ny+2,nx+2);
div_j_dia_x=zeros(ny+2,nx+2);
div_j_dia_y=zeros(ny+2,nx+2);
[div_j_dia_x,div_j_dia_y,div_j_dia]=calc_divergence(jx_dia,jy_dia,nx,ny,top,right);
clear div_j_dia_x;
clear div_j_dia_y;
div_j_dia=div_j_dia*qe./vol;

%-------------------------------------------
% divergence of curvature current
%-------------------------------------------

div_j_inert=zeros(ny+2,nx+2);
div_j_inert_x=zeros(ny+2,nx+2);
div_j_inert_y=zeros(ny+2,nx+2);
[div_j_inert_x,div_j_inert_y,div_j_inert]=calc_divergence(jx_inert,jy_inert,nx,ny,top,right);
clear div_j_inert_x;
clear div_j_inert_y;
div_j_inert=div_j_inert*qe./vol;

%-------------------------------------------
% divergence of ion-neutral friction current
%-------------------------------------------

div_j_in=zeros(ny+2,nx+2);
div_j_in_x=zeros(ny+2,nx+2);
div_j_in_y=zeros(ny+2,nx+2);
[div_j_in_x,div_j_in_y,div_j_in]=calc_divergence(jx_in,jy_in,nx,ny,top,right);
clear div_j_in_x;
clear div_j_in_y;
div_j_in=div_j_in*qe./vol;

%-------------------------------------------
% divergence of viscous current
%-------------------------------------------

div_j_vispar=zeros(ny+2,nx+2);
div_j_vispar_x=zeros(ny+2,nx+2);
div_j_vispar_y=zeros(ny+2,nx+2);
[div_j_vispar_x,div_j_vispar_y,div_j_vispar]=calc_divergence(jx_vispar,jy_vispar,nx,ny,top,right);
clear div_j_vispar_x;
clear div_j_vispar_y;
div_j_vispar=div_j_vispar*qe./vol;

div_j_visper=zeros(ny+2,nx+2);
div_j_visper_x=zeros(ny+2,nx+2);
div_j_visper_y=zeros(ny+2,nx+2);
[div_j_visper_x,div_j_visper_y,div_j_visper]=calc_divergence(jx_visper,jy_visper,nx,ny,top,right);
clear div_j_visper_x;
clear div_j_visper_y;
div_j_visper=div_j_visper*qe./vol;

div_j_visq=zeros(ny+2,nx+2);
div_j_visq_x=zeros(ny+2,nx+2);
div_j_visq_y=zeros(ny+2,nx+2);
[div_j_visq_x,div_j_visq_y,div_j_visq]=calc_divergence(jx_visq,jy_visq,nx,ny,top,right);
clear div_j_visq_x;
clear div_j_visq_y;
div_j_visq=div_j_visq*qe./vol;

%-------------------------------------------
% divergence of anomalous current
%-------------------------------------------

div_j_AN=zeros(ny+2,nx+2);
div_j_AN_x=zeros(ny+2,nx+2);
div_j_AN_y=zeros(ny+2,nx+2);
[div_j_AN_x,div_j_AN_y,div_j_AN]=calc_divergence(jx_AN,jy_AN,nx,ny,top,right);
clear div_j_AN_x;
clear div_j_AN_y;
div_j_AN=div_j_AN*qe./vol;

%-------------------------------------------
% divergence of total current
%-------------------------------------------
div_j=zeros(ny+2,nx+2);
div_j_x=zeros(ny+2,nx+2);
div_j_y=zeros(ny+2,nx+2);
[div_j_x,div_j_y,div_j]=calc_divergence(jx,jy,nx,ny,top,right);
%clear div_j_x;
%clear div_j_y;
div_j_x=div_j_x*qe./vol;
div_j_y=div_j_y*qe./vol;
div_j=div_j*qe./vol;


%---------------------------------------
% Radiation losses in the CORE
%---------------------------------------

for is=1:ns
    Qrad_int_CORE(is)=volume_integral_region(Qrad(:,:,is),nc1,0,nc4,nsep,nx,ny,left,right);
end;



ddr=zeros(ny+2,nx+2);
for i=2:ny+1
ddr(i,:)=((na(i+1,:,2)-na(i-1,:,2))./na(i,:,2).*ti(i,:)+po(i+1,:)-po(i-1,:))./(hy1(i,:)+0.5*hy1(i-1,:)+0.5*hy1(i+1,:));
end;
upar=-ddr./Bx;

Bsqr_avr=zeros(ny+2,1);
uparB_avr=zeros(ny+2,1);
uPS=zeros(ny+2,nx+2);

for i=1:nsep+2
    Bsqr_avr(i)=poloidal_int_core_DND(B.*B.*vol,nx,ny,nc1,nc2,nc3,nc4,i)/poloidal_int_core_DND(vol,nx,ny,nc1,nc2,nc3,nc4,i);
    uparB_avr(i)=poloidal_int_core_DND(ua(:,:,2).*B.*vol,nx,ny,nc1,nc2,nc3,nc4,i)/poloidal_int_core_DND(vol,nx,ny,nc1,nc2,nc3,nc4,i);
end;

for i=nsep+2+1:nsep2+2
   Bsqr_avr(i)=poloidal_int_core_DND(B.*B.*vol,nx,ny,-1,nc2,nc3,nx,i)/poloidal_int_core_DND(vol,nx,ny,-1,nc2,nc3,nx,i);
   uparB_avr(i)=poloidal_int_core_DND(ua(:,:,2).*B.*vol,nx,ny,-1,nc2,nc3,nx,i)/poloidal_int_core_DND(vol,nx,ny,-1,nc2,nc3,nx,i);
end;

for i=nsep+2+1:nsep2+2
    uPS(i,:)=(Bz(i,:)./Bx(i,:).*((na(i+1,:,2).*ti(i+1,:)-na(i-1,:,2).*ti(i-1,:))./na(i,:,2)+po(i+1,:)-po(i-1,:))./...
        (hy1(i,:)+0.5*hy1(i-1,:)+0.5*hy1(i+1,:)))./B(i,:).*(1-B(i,:).*B(i,:)/Bsqr_avr(i));
end;

Ey=zeros(ny+2,1);

for i=2:ny+2-1
    Ey(i)=-(po(i+1,nout+2)-po(i-1,nout+2))/(hy(i,nout+2)+0.5*(hy(i+1,nout+2)+hy(i-1,nout+2)));
end;

% Neoclassical radial electric field at outer midplane
Ey_neo=zeros(ny+2,1);
Ey_neo_term1=zeros(ny+2,1);
Ey_neo_term2=zeros(ny+2,1);

% ion-ion collisional time
tau = 3/4*sqrt(Amain*mp*qe^3/pi)*(4*pi*epsilon_0)^2/(Lambda_Coulomb*qe^4).*ti(:,nout+2).*sqrt(ti(:,nout+2))./ne(:,nout+2);

% reversed aspect ratio
eps=zeros(ny+2,1); 
for i=2:nsep+2-1
    eps(i)=(poloidal_int_core_DND(hx,nx,ny,nc1,nc2,nc3,nc4,i-2))^2/poloidal_int_core_DND(vol./hy,nx,ny,nc1,nc2,nc3,nc4,i-2);
end;


nu1=1./tau./cs(:,nout+2);
for i=2:nsep+2-1
        nu1(i) = nu1(i)*poloidal_int_core_DND(hx.*B./Bx,nx,ny,nc1,nc2,nc3,nc4,i-2)/(2*pi*eps(i)*sqrt(eps(i)));
end;

ti1=zeros(ny+2,1);
ni1=zeros(ny+2,1);
vp1=zeros(ny+2,1);

for i=2:ny+2-1
        ti1(i) = 0.25*(ti(i-1,nout+2)+2*ti(i,nout+2)+ti(i+1,nout+2));
        ni1(i) = 0.25*(na(i-1,nout+2,2)+2*na(i,nout+2,2)+na(i+1,nout+2,2));
        vp1(i) = 0.25*(ua(i-1,nout+2,2)+2*ua(i,nout+2,2)+ua(i+1,nout+2,2));
end;


for i=2:nsep+2-1
    Ey_neo_term1(i) = 0.75*(2.7*(nu1(i))^2.*(eps(i))^3-0.17+1.05.*sqrt(nu1(i)))./(1+0.7*sqrt(nu1(i))+(nu1(i))^2.*(eps(i))^3)+0.25;
    Ey_neo_term1(i) = 2*(Ey_neo_term1(i)*(ti1(i)-ti1(i-1))/(ti1(i)+ti(i-1))+(ni1(i)-ni1(i-1))/(ni1(i)+ni1(i-1)))*(ti1(i)+ti1(i-1))/(hy(i,nout+2)+hy(i-1,nout+2));
    Ey_neo_term2(i) = -0.75*poloidal_int_core_DND(ua(:,:,2).*vol.*B,nx,ny,nc1,nc2,nc3,nc4,i-2)/poloidal_int_core_DND(vol,nx,ny,nc1,nc2,nc3,nc4,i-2)*Bx(i,nout+2)/Bz(i,nout+2);
end;

Ey_neo = Ey_neo_term1 + Ey_neo_term2;
Ey_neo(2) = 0;


if EIRENE_flag
    N_tot_eir = zeros(Natmi+Nmoli+Nioni,1);
    pdenN_tot = zeros(1:N_tria,1);
    edenN_tot = zeros(1:N_tria,1);
    for ieir=1:Natmi
        N_tot_eir(ieir) = sum(pdena(1:N_tria,ieir).*vol_eir(1:N_tria));
        pdenN_tot = pdenN_tot + pdena(1:N_tria,ieir);
        edenN_tot = edenN_tot + edena(1:N_tria,ieir);        
    end;
    for ieir=1:Nmoli
        N_tot_eir(ieir+Natmi) = sum(pdenm(1:N_tria,ieir).*vol_eir(1:N_tria));
        pdenN_tot = pdenN_tot + pdenm(1:N_tria,ieir);
        edenN_tot = edenN_tot + edenm(1:N_tria,ieir);        
    end;
    for ieir=1:Nioni
        N_tot_eir(ieir+Natmi+Nmoli) = sum(pdeni(1:N_tria,ieir).*vol_eir(1:N_tria));
    end;
end;


npl=nx;
profiles_DATA_out = zeros(ny+2,20);
for i=1:ny+1
   profiles_DATA_out(i,1) = 0.5*(R0(i,npl+2)+R0(i+1,npl+2));
   profiles_DATA_out(i,2) = y2(i,npl+2);
   profiles_DATA_out(i,3) = ne(i,npl+2);
   profiles_DATA_out(i,4) = te(i,npl+2)/1000;
   profiles_DATA_out(i,5) = ti(i,npl+2)/1000;
   profiles_DATA_out(i,6) = po(i,npl+2);
   profiles_DATA_out(i,7) = Bx(i,npl+2);
   profiles_DATA_out(i,8) = Bz(i,npl+2);
   profiles_DATA_out(i,9) = B(i,npl+2);
   profiles_DATA_out(i,10) = hy(i,npl+2);
   profiles_DATA_out(i,11) = hy1(i,npl+2);
end;

fid = fopen([PATH_PREFIX 'profiles_OUT.dat'],'w');
fprintf(fid,'      Rmaj(m)   R-R_sep(m)      ne(m^3)      Te(keV)      Ti(keV)       phi(V)        Bx(T)        Bz(T)          B(T)       hy(m)       hy1(m)\n');
fclose(fid);
dlmwrite([PATH_PREFIX 'profiles_OUT.dat'],profiles_DATA_out,'delimiter', '', 'precision', '%13.5e', '-append');


