%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================


% electron temperature           
te=readdatavalue([PATH_PREFIX 'b2nph9_te.dat'],nx,ny);
te=te/qe;


% ion temperature
ti=readdatavalue([PATH_PREFIX 'b2nph9_ti.dat'],nx,ny);
ti=ti/qe;


% potential
po=readdatavalue([PATH_PREFIX 'b2npp7_po.dat'],nx,ny);


%electron-ion collision time
tau_ei=readdatavalue([PATH_PREFIX 'b2tqce_taue.dat'],nx,ny);


%++++++++++++++++++++++++++++++++++++++++++++++++
% densities and velocities

na=zeros(ny+2,nx+2,ns);
ua=zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% fluxes

fnax=zeros(ny+2,nx+2,ns);  % fluxes according to B2 5.0 
fnay=zeros(ny+2,nx+2,ns);

fnax_mdf=zeros(ny+2,nx+2,ns); % fluxes according to B2 5.2
fnay_mdf=zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% flux components

fnax_Dgradn=zeros(ny+2,nx+2,ns);  % Diffusive fluxes of charged species driven by density gradient 
fnay_Dgradn=zeros(ny+2,nx+2,ns);  % (assumend to be anomalous)

fnax_Dgradp=zeros(ny+2,nx+2,ns);  % Diffusive fluxes of neutral species driven by pressure gradient 
fnay_Dgradp=zeros(ny+2,nx+2,ns);  % (used for fluid neutrals only)

fnax_nuExB=zeros(ny+2,nx+2,ns);   % ExB drift fluxes
fnay_nuExB=zeros(ny+2,nx+2,ns);   % (for charged species only)

fnax_PSch=zeros(ny+2,nx+2,ns);    % Artificial fluxes with the same divergence as diamagnetic fluxes
fnay_PSch=zeros(ny+2,nx+2,ns);    % (they are special feature of B2 5.2 version, for charged species only)
                                  % Note that they appear with opposite
                                  % signs in output and in equation

fnax_nuAN=zeros(ny+2,nx+2,ns);    % Anomalous pinch fluxes
fnay_nuAN=zeros(ny+2,nx+2,ns);    % (for charged species only)

fnax_uDPC=zeros(ny+2,nx+2,ns);    % Artificial fluxes for numerical stability
fnay_uDPC=zeros(ny+2,nx+2,ns);

fnax_nupar=zeros(ny+2,nx+2,ns);   % Parallel fluxes
fnay_nupar=zeros(ny+2,nx+2,ns);

fnax_dia=zeros(ny+2,nx+2,ns);     % grad(B)-fluxes with the same divergence as diamagnetic fluxes
fnay_dia=zeros(ny+2,nx+2,ns);     % (they are special feature of B2 5.2 version, for charged species only)


%++++++++++++++++++++++++++++++++++++++++++++++++
% velocities

ux_ExB=zeros(ny+2,nx+2,ns);   % ExB drift velocities
uy_ExB=zeros(ny+2,nx+2,ns);

ux_dia=zeros(ny+2,nx+2,ns);   % 
uy_dia=zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% particle sources

sna = zeros(ny+2,nx+2,ns);
snadt = zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% momentum fluxes

fmox=zeros(ny+2,nx+2,ns);
fmoy=zeros(ny+2,nx+2,ns);

%++++++++++++++++++++++++++++++++++++++++++++++++
% momentum sources

smo = zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% momentum source components

smogp = zeros(ny+2,nx+2,ns);  % sources due to pressure gradient and electric field (old form)
smotf = zeros(ny+2,nx+2,ns);  % sources due to thermal force
smocf = zeros(ny+2,nx+2,ns);  % sources due to centrifuginal force
smoch = zeros(ny+2,nx+2,ns);  % sources due to friction, velocity terms
smovv = zeros(ny+2,nx+2,ns);  % sources due to viscosity, first term
smovh = zeros(ny+2,nx+2,ns);  % sources due to viscosity, second term
smoat = zeros(ny+2,nx+2,ns);  % sources due to atomic processes (from eirene)
smoii = zeros(ny+2,nx+2,ns);  % sources due to atomic processes (ion-ion collisions)
smodt = zeros(ny+2,nx+2,ns);  % time derivatives


%++++++++++++++++++++++++++++++++++++++++++++++++
% radiation losses

Qrad=zeros(ny+2,nx+2,ns);  % ion line radiation (Watts)
QBR=zeros(ny+2,nx+2,ns);   % ion Bremmstrahlung radiation (Watts)

if EIRENE_flag 
    Eirene_neutral_counter = 1;
end;


for is=1:ns
    if SOLPS_ITER==1
          is_string = num2str(is-1,'%0.3i');
    else
          is_string = num2str(is-1,'%0.2i');
    end;
    
    % velocities
    ua(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_ua' is_string '.dat'],nx,ny);
        
    if Za(is)==0  % special treatment of neutral particles because of optional usage of Eirene
        
        if EIRENE_flag == 1 % read output from Eirene
            
            % densities
            na(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_dab2_eir' num2str(Eirene_neutral_counter,'%0.3i') '.dat'],nx,ny);
            
            % fluxes
            fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_pfluxa_eir' num2str(Eirene_neutral_counter,'%0.3i') '.dat'],nx,ny).*hy(:,:).*hz(:,:);
            fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_rfluxa_eir' num2str(Eirene_neutral_counter,'%0.3i') '.dat'],nx,ny).*hx(:,:).*hz(:,:);

            if Eirene_neutral_counter == 1
                nD2=readdatavalue([PATH_PREFIX 'b2stbr_dmb2_eir001.dat'],nx,ny); % Deuterium molecules
            end;
            
            Eirene_neutral_counter = Eirene_neutral_counter + 1;
            
        else  % read standard B2 output for fluid neutrals
            
            %densities
            na(:,:,is)=readdatavalue([PATH_PREFIX 'b2npco_na' is_string '.dat'],nx,ny);
            
            % fluxes
            fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnbx' is_string '.dat'],nx,ny);
            fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnby' is_string '.dat'],nx,ny);
            
            % particle sources
            sna(:,:,is)=readdatavalue([PATH_PREFIX 'b2npco_sna' is_string '.dat'],nx,ny);

            % momentum fluxes
            fmox(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmox' is_string '.dat'],nx,ny);
            fmoy(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmoy' is_string '.dat'],nx,ny);

            % momentum sources           
            smo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smb' is_string '.dat'],nx,ny);
   
        end;
        
        fnax_mdf(:,:,is) = fnax(:,:,is);
        fnay_mdf(:,:,is) = fnay(:,:,is);
        
    else   % read standard B2 output for charged particles
        
        % densities
        na(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_na' is_string '.dat'],nx,ny);
 
        % fluxes
        fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnbx' is_string '.dat'],nx,ny);
        fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnby' is_string '.dat'],nx,ny);
        
        fnax_mdf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_fnax' is_string '.dat'],nx,ny);
        fnay_mdf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_fnay' is_string '.dat'],nx,ny);


        % flux components
        fnax_Dgradn(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_dPat_mdf_gradnax' is_string '.dat'],nx,ny);
        fnay_Dgradn(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_dPat_mdf_gradnay' is_string '.dat'],nx,ny);
        fnax_nuExB(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vaecrbnax' is_string '.dat'],nx,ny);
        fnay_nuExB(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vaecrbnay' is_string '.dat'],nx,ny);
        fnax_PSch(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnbPSchx' is_string '.dat'],nx,ny);
        fnay_PSch(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnbPSchy' is_string '.dat'],nx,ny);
        fnax_dia(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vadianax' is_string '.dat'],nx,ny);
        fnay_dia(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vadianay' is_string '.dat'],nx,ny);
        fnax_nuAN(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_cvlbnax' is_string '.dat'],nx,ny);
        fnay_nuAN(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_cvlbnay' is_string '.dat'],nx,ny);
        
        fnax_uDPC(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_dpccornax' is_string '.dat'],nx,ny);
        fnax_nupar(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_bxuanax' is_string '.dat'],nx,ny);

        % velocities
        ux_ExB(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbecrbx' is_string '.dat'],nx,ny);
        uy_ExB(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbecrby' is_string '.dat'],nx,ny);
        ux_dia(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbdiax' is_string '.dat'],nx,ny);
        uy_dia(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbdiay' is_string '.dat'],nx,ny);
        
        % particle sources
        sna(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_sna' is_string '.dat'],nx,ny);
        
        % momentum fluxes
        fmox(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmox' is_string '.dat'],nx,ny);
        fmoy(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmoy' is_string '.dat'],nx,ny);
        
        % momentum sources
        smo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smb' is_string '.dat'],nx,ny);

            
        % momentum source components
        smogp(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smogp' is_string '.dat'],nx,ny);
        smotf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smotf' is_string '.dat'],nx,ny);
        smocf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smocf' is_string '.dat'],nx,ny);
        smoch(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smoch' is_string '.dat'],nx,ny);
        smovv(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smovv' is_string '.dat'],nx,ny);
        smovh(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smovh' is_string '.dat'],nx,ny);
        smoii(:,:,is)=readdatavalue([PATH_PREFIX 'b2stcx_smq' is_string '.dat'],nx,ny)+ ...
            readdatavalue([PATH_PREFIX 'b2stel_smq_ion' is_string '.dat'],nx,ny)+ ...
            readdatavalue([PATH_PREFIX 'b2stel_smq_rec' is_string '.dat'],nx,ny);
        smodt(:,:,is)=readdatavalue([PATH_PREFIX 'b2srdt_smodt' is_string '.dat'],nx,ny);
        
        if EIRENE_flag
            smoat(:,:,2)=readdatavalue([PATH_PREFIX 'b2stbr_smo_eir' is_string '.dat'],nx,ny);
        end;
       
    end;
    
    Qrad(:,:,is)=readdatavalue([PATH_PREFIX 'b2stel_rqrad' is_string '.dat'],nx,ny);
    QBR(:,:,is)=readdatavalue([PATH_PREFIX 'b2stel_rqbrm' is_string '.dat'],nx,ny);

    snadt(:,:,is)=readdatavalue([PATH_PREFIX 'b2srdt_snadt' is_string '.dat'],nx,ny);

            
end;


%++++++++++++++++++++++++++++++++++++++++++++
% currents
jx=readdatavalue([PATH_PREFIX 'b2npp7_fchx.dat'],nx,ny);
jy=readdatavalue([PATH_PREFIX 'b2npp7_fchy.dat'],nx,ny);

%++++++++++++++++++++++++++++++++++++++++++++
% current components
jx_prll=readdatavalue([PATH_PREFIX 'b2tfhe_fch_px.dat'],nx,ny); %parallel current
jy_prll = zeros(ny+2,nx+2); % dummy
jx_in=readdatavalue([PATH_PREFIX 'b2tfhe_fchinx.dat'],nx,ny); % ion-neutral current
jy_in=readdatavalue([PATH_PREFIX 'b2tfhe_fchiny.dat'],nx,ny); % ion-neutral current
jx_inert=readdatavalue([PATH_PREFIX 'b2tfhe_fchinertx.dat'],nx,ny); % inertial current
jy_inert=readdatavalue([PATH_PREFIX 'b2tfhe_fchinerty.dat'],nx,ny); % inertial current
jx_visper=zeros(ny+2,nx+2); % due to perp viscousity
jy_visper=readdatavalue([PATH_PREFIX 'b2tfhe_fchvispery.dat'],nx,ny); % due to perp viscousity
jx_vispar=readdatavalue([PATH_PREFIX 'b2tfhe_fchvisparx.dat'],nx,ny); % due to parll viscousity
jy_vispar=readdatavalue([PATH_PREFIX 'b2tfhe_fchvispary.dat'],nx,ny); % due to parll viscousity
jx_visq = zeros(ny+2,nx+2);
jy_visq = readdatavalue([PATH_PREFIX 'b2tfhe_fchvisqy.dat'],nx,ny);
jx_AN=readdatavalue([PATH_PREFIX 'b2tfhe_fchanmlx.dat'],nx,ny); % artificial 'anomalous' current
jy_AN=readdatavalue([PATH_PREFIX 'b2tfhe_fchanmly.dat'],nx,ny); % artificial 'anomalous' current
jx_dia=readdatavalue([PATH_PREFIX 'b2tfhe_fchdiax.dat'],nx,ny); % diamagnetic current
jy_dia=readdatavalue([PATH_PREFIX 'b2tfhe_fchdiay.dat'],nx,ny); % diamagnetic current
jx_stoch=zeros(ny+2,nx+2);
jy_stoch=readdatavalue([PATH_PREFIX 'b2tfhe_fchstoch.dat'],nx,ny); % diamagnetic current

% convert currents from Amperes to particles per second
jx=jx/qe;
jy=jy/qe;
jx_prll=jx_prll/qe;
jx_in=jx_in/qe;
jy_in=jy_in/qe;
jx_inert=jx_inert/qe;
jy_inert=jy_inert/qe;
jx_visper=jx_visper/qe;
jy_visper=jy_visper/qe;
jx_vispar=jx_vispar/qe;
jy_vispar=jy_vispar/qe;
jx_visq=jx_visq/qe;
jy_visq=jy_visq/qe;
jx_AN=jx_AN/qe;
jy_AN=jy_AN/qe;
jx_dia=jx_dia/qe;
jy_dia=jy_dia/qe;
jx_stoch=jx_stoch/qe;
jy_stoch=jy_stoch/qe;

%--------------------------------------------
% "conductivity" after Braams
% stupid is that this "conductivity" is multiplied by (b_x)^2
sigx=readdatavalue([PATH_PREFIX 'b2trcl_csigx.dat'],nx,ny); % classical "conductivity"
sigx_luc=readdatavalue([PATH_PREFIX 'b2trcl_luciani_csigx.dat'],nx,ny); % "conductivity" with flux limiting correction applied


%++++++++++++++++++++++++++++++++++++++++++++++++
% heat sources

% total electron heat source due to electron-atom/ion collisions (negative
% sign means that in fact it is a sink) (Watts)
she_stel=readdatavalue([PATH_PREFIX 'b2stel_she_rad.dat'],nx,ny);

% electron heat source due to collision with neutrals (from Eirene)  (Watts)
if EIRENE_flag==1
    she_eir=readdatavalue([PATH_PREFIX 'b2stbr_she_eir.dat'],nx,ny);
end;

% ion heat source due to ionization (Watts)
shi_ion_stel=readdatavalue([PATH_PREFIX 'b2stel_shi_ion.dat'],nx,ny);

% ion heat source due to recombination (Watts)
shi_ion_stel=readdatavalue([PATH_PREFIX 'b2stel_shi_rec.dat'],nx,ny);

% ion heat source due to collision with neutrals (from Eirene) (Watts)
if EIRENE_flag==1
    shi_eir=readdatavalue([PATH_PREFIX 'b2stbr_shi_eir.dat'],nx,ny);
end;

shi_stbr=readdatavalue([PATH_PREFIX 'b2stbr_shi.dat'],nx,ny);


%++++++++++++++++++++++++++++++++++++++++++++++++
% heat fluxes

fhex_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhex.dat'],nx,ny);
fhey_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhey.dat'],nx,ny);

fhix_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhix.dat'],nx,ny);
fhiy_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhiy.dat'],nx,ny);

fhex=readdatavalue([PATH_PREFIX 'fhex.dat'],nx,ny);
fhey=readdatavalue([PATH_PREFIX 'fhey.dat'],nx,ny);

fhix=readdatavalue([PATH_PREFIX 'fhix.dat'],nx,ny);
fhiy=readdatavalue([PATH_PREFIX 'fhiy.dat'],nx,ny);


%++++++++++++++++++++++++++++++++++++++++++++++++
% heat flux components

fhex_ke_gTx=readdatavalue([PATH_PREFIX 'b2tfhe__qe_ke_gTx.dat'],nx,ny);
fhey_ke_gTy=readdatavalue([PATH_PREFIX 'b2tfhe__qe_ke_gTy.dat'],nx,ny);


%++++++++++++++++++++++++++++++++++++++++++++++++
% energy fluxes to targets

fhtotX=zeros(ny+2,nx+2);  % probaly, they are meaningless
fhtotY=zeros(ny+2,nx+2); % probaly, they are meaningless


fhe_low_outer=dlmread([PATH_PREFIX 'table_low_outer.dat'],'',[1,6,ny+1,6]);
fhi_low_outer=dlmread([PATH_PREFIX 'table_low_outer.dat'],'',[1,7,ny+1,7]);
fhtot_low_outer=dlmread([PATH_PREFIX 'table_low_outer.dat'],'',[1,8,ny+1,8]);

fhe_low_inner=dlmread([PATH_PREFIX 'table_low_inner.dat'],'',[1,6,ny+1,6]);
fhi_low_inner=dlmread([PATH_PREFIX 'table_low_inner.dat'],'',[1,7,ny+1,7]);
fhtot_low_inner=dlmread([PATH_PREFIX 'table_low_inner.dat'],'',[1,8,ny+1,8]);

if ntt ~= nc2  % Double null topology
    fhe_upper_outer=dlmread([PATH_PREFIX 'table_upper_outer.dat'],'',[1,6,ny+1,6]);
    fhi_y_outer=dlmread([PATH_PREFIX 'table_upper_outer.dat'],'',[1,7,ny+1,7]);
    fhtot_upper_outer=dlmread([PATH_PREFIX 'table_upper_outer.dat'],'',[1,8,ny+1,8]);

    fhe_upper_inner=dlmread([PATH_PREFIX 'table_upper_inner.dat'],'',[1,6,ny+1,6]);
    fhi_upper_inner=dlmread([PATH_PREFIX 'table_upper_inner.dat'],'',[1,7,ny+1,7]);
    fhtot_upper_inner=dlmread([PATH_PREFIX 'table_upper_inner.dat'],'',[1,8,ny+1,8]);
end;

for i=1:ny+1
    %%%fheX(i+1,2)=-1.0e6*fhe_low_inner(i)*hy(i+1,1)*hz(i+1,1);
    %%%fhiX(i+1,2)=-1.0e6*fhi_low_inner(i)*hy(i+1,1)*hz(i+1,1);
    fhtotX(i+1,1)=-1.0e6*fhtot_low_inner(i)*hy(i+1,1)*hz(i+1,1);

    %%%fheX(i+1,nx+2)=1.0e6*fhe_low_outer(i)*hy(i+1,nx+2)*hz(i+1,nx+2);
    %%%fhiX(i+1,nx+2)=1.0e6*fhi_low_outer(i)*hy(i+1,nx+2)*hz(i+1,nx+2);
    fhtotX(i+1,nx+2)=1.0e6*fhtot_low_outer(i)*hy(i+1,nx+2)*hz(i+1,nx+2);

    if ntt ~= nc2  % Double null topology
        %
        %%%fheX(i+1,ntt+2)=1.0e6*fhe_up_inner(i)*hy(i+1,ntt+2)*hz(i+1,ntt+2);
        %%%fhiX(i+1,ntt+2)=1.0e6*fhi_up_inner(i)*hy(i+1,ntt+2)*hz(i+1,ntt+2);
        fhtotX(i+1,ntt+2)=1.0e6*fhtot_upper_inner(i)*hy(i+1,ntt+2)*hz(i+1,ntt+2);
    
       %%%fheX(i+1,ntt+4)=-1.0e6*fhe_up_outer(i)*hy(i+1,ntt+3)*hz(i+1,ntt+3);
       %%%fhiX(i+1,ntt+4)=-1.0e6*fhi_up_outer(i)*hy(i+1,ntt+3)*hz(i+1,ntt+3);
       fhtotX(i+1,ntt+3)=-1.0e6*fhtot_upper_outer(i)*hy(i+1,ntt+3)*hz(i+1,ntt+3);
    end;
end;

