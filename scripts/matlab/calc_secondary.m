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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% electron density, Zeff, pressure etc, and flux surface integrated fluxes 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fnay_core=zeros(nsep+2,ns);
Fnay_mdf_core=zeros(nsep+2,ns);

Fnay_Dgradn_core=zeros(nsep+2,ns);
Fnay_nuExB_core=zeros(nsep+2,ns);
Fnay_nuAN_core=zeros(nsep+2,ns);
Fnay_jAN_core=zeros(nsep+2,1);
Fnay_jvispar_core=zeros(nsep+2,1);
Fnay_jvisper_core=zeros(nsep+2,1);
Fnay_jviq_core=zeros(nsep+2,1);
Fnay_jinert_core=zeros(nsep+2,1);
Fnay_PSch_core=zeros(nsep+2,1);

Fhey_core=zeros(nsep+2,ns);
Fhey_mdf_core=zeros(nsep+2,ns);
Fhey_52uExB_core=zeros(nsep+2,ns);
Fhiy_core=zeros(nsep+2,ns);
Fhiy_mdf_core=zeros(nsep+2,ns);
Fhiy_52uExB_core=zeros(nsep+2,ns);

ne=zeros(ny+2,nx+2);
ni=zeros(ny+2,nx+2);
ne2=zeros(ny+2,nx+2);
nas=zeros(ny+2,nx+2);
nasm=zeros(ny+2,nx+2);
pas=zeros(ny+2,nx+2);

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
   ni(:,:)=ni(:,:)+na(:,:,is)*max(Za(is),0)/max(Za(is),1);
   ne2(:,:)=ne2(:,:)+na(:,:,is)*Za(is)*Za(is);
   nas(:,:)=nas(:,:)+na(:,:,is);
   nasm(:,:)=nasm(:,:)+na(:,:,is)*Am(is);
   pa(:,:,is)=(Za(is)*te(:,:)+ti(:,:)).*na(:,:,is)*qe;
   pas(:,:)=pas(:,:)+pa(:,:,is);

   for i=-1:nsep
      Fnay_core(i+2,is) = poloidal_int_core_DND(fnay(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_mdf_core(i+2,is) = poloidal_int_core_DND(fnay_mdf(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);
      
      Fnay_Dgradn_core(i+2,is) = poloidal_int_core_DND(fnay_Dgradn(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_nuAN_core(i+2,is) = poloidal_int_core_DND(fnay_nuAN(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_nuExB_core(i+2,is) = poloidal_int_core_DND(fnay_nuExB(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_PSch_core(i+2,is) = poloidal_int_core_DND(fnay_PSch(:,:,is),nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_jAN_core(i+2) = poloidal_int_core_DND(jy_AN,nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_jvispar_core(i+2) = poloidal_int_core_DND(jy_vispar,nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_jvisper_core(i+2) = poloidal_int_core_DND(jy_visper,nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_jvisq_core(i+2) = poloidal_int_core_DND(jy_visq,nx,ny,nc1,nc2,nc3,nc4,i);  
      Fnay_jinert_core(i+2) = poloidal_int_core_DND(jy_inert,nx,ny,nc1,nc2,nc3,nc4,i);
      
      Fhey_core(i+2) = poloidal_int_core_DND(fhey,nx,ny,nc1,nc2,nc3,nc4,i);
      Fhey_mdf_core(i+2) = poloidal_int_core_DND(fhey_mdf,nx,ny,nc1,nc2,nc3,nc4,i);
      Fhey_52uExB_core(i+2) = poloidal_int_core_DND(fhey_mdf+fhe_ExBy,nx,ny,nc1,nc2,nc3,nc4,i);
      Fhiy_core(i+2) = poloidal_int_core_DND(fhiy,nx,ny,nc1,nc2,nc3,nc4,i);
      Fhiy_mdf_core(i+2) = poloidal_int_core_DND(fhiy_mdf,nx,ny,nc1,nc2,nc3,nc4,i);
      Fhiy_52uExB_core(i+2) = poloidal_int_core_DND(fhiy_mdf+fhi_ExBy,nx,ny,nc1,nc2,nc3,nc4,i);

    end;  
end;

Zeff=ne2./ne;
cs=sqrt(1.0/mp.*pas./nasm);
cs_mi=sqrt((te+ti)/(Amain*mp/qe)); % sound speed computed through the main ion pressure only
jsat=Bx./B.*na(:,:,2)*qe.*cs_mi;


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
   Bsqr_avr(i)=poloidal_int_innerSOL_DND(B.*B.*vol,nx,ny,nc2,nc3,i)/poloidal_int_innerSOL_DND(vol,nx,ny,nc2,nc3,i);
   uparB_avr(i)=poloidal_int_innerSOL_DND(ua(:,:,2).*B.*vol,nx,ny,nc2,nc3,i)/poloidal_int_innerSOL_DND(vol,nx,ny,nc2,nc3,i);
end;

for i=nsep+2+1:nsep2+2
    uPS(i,:)=(Bz(i,:)./Bx(i,:).*((na(i+1,:,2).*ti(i+1,:)-na(i-1,:,2).*ti(i-1,:))./na(i,:,2)+po(i+1,:)-po(i-1,:))./...
        (hy1(i,:)+0.5*hy1(i-1,:)+0.5*hy1(i+1,:)))./B(i,:).*(1-B(i,:).*B(i,:)/Bsqr_avr(i));
end;

Ey=zeros(ny+2,1);
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

for i=2:ny+2-1
    Ey(i)=-(po(i+1,nout+2)-po(i-1,nout+2))/(hy(i,nout+2)+0.5*(hy(i+1,nout+2)+hy(i-1,nout+2)));
end;

% Neoclassical radial electric field at outer midplane
Ey_neo=zeros(ny+2,1);
Ey_neo_term1=zeros(ny+2,1);
Ey_neo_term2=zeros(ny+2,1);

% ion-ion collisional time
tau = 3/4*sqrt(Amain*mp*qe^3/pi)*(4*pi*epsilon_0)^2/(Lambda_Coulomb*qe^4)*ti(:,nout+2).*sqrt(ti(:,nout+2))./ne(:,nout+2);

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


