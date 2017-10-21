%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READ DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================


% electron temperature 
if exist([PATH_PREFIX 'b2nph9_te.dat'],'file') == 2
     te=readdatavalue([PATH_PREFIX 'b2nph9_te.dat'],nx,ny);
%     te=readdatavalue([PATH_PREFIX 'b2sifr_te.dat'],nx,ny);
elseif exist([PATH_PREFIX 'b2npht_te.dat'],'file') == 2
     te=readdatavalue([PATH_PREFIX 'b2npht_te.dat'],nx,ny);
elseif exist([PATH_PREFIX 'te.dat'],'file') == 2
     te=readdatavalue([PATH_PREFIX 'te.dat'],nx,ny);
else
    'WARNING!: no data for Te is available'
    stop;
end;
te=te/qe;


% ion temperature
if exist([PATH_PREFIX 'b2nph9_ti.dat'],'file') == 2
     ti=readdatavalue([PATH_PREFIX 'b2nph9_ti.dat'],nx,ny);
%     ti=readdatavalue([PATH_PREFIX 'b2sifr_ti.dat'],nx,ny);
elseif exist([PATH_PREFIX 'b2npht_ti.dat'],'file') == 2
     ti=readdatavalue([PATH_PREFIX 'b2npht_ti.dat'],nx,ny);
elseif exist([PATH_PREFIX 'ti.dat'],'file') == 2
     ti=readdatavalue([PATH_PREFIX 'ti.dat'],nx,ny);
else
    'WARNING!: no data for Ti is available'
    stop;
end;
ti=ti/qe;


% potential
if exist([PATH_PREFIX 'b2npp7_po.dat'],'file') == 2
     po=readdatavalue([PATH_PREFIX 'b2npp7_po.dat'],nx,ny);
elseif exist([PATH_PREFIX 'b2nppo_po.dat'],'file') == 2
     po=readdatavalue([PATH_PREFIX 'b2nppo_po.dat'],nx,ny);
elseif exist([PATH_PREFIX 'po.dat'],'file') == 2
     po=readdatavalue([PATH_PREFIX 'po.dat'],nx,ny);
else
    'WARNING!: no data for potential is available'
    stop;
end;


%electron-ion collision time
tau_ei=readdatavalue([PATH_PREFIX 'b2tqce_taue.dat'],nx,ny);


%++++++++++++++++++++++++++++++++++++++++++++++++
% densities and velocities

na=zeros(ny+2,nx+2,ns);
ua=zeros(ny+2,nx+2,ns);

ua0=zeros(ny+2,nx+2,ns);

nD2=zeros(ny+2,nx+2);

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
sna_sral = zeros(ny+2,nx+2,ns);
snadt = zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% momentum fluxes

fmox=zeros(ny+2,nx+2,ns);
fmoy=zeros(ny+2,nx+2,ns);

% combination of total particle flaux and diamagnetic flux appearing in inertia term
fmo_corx=zeros(ny+2,nx+2,ns);  
fmo_cory=zeros(ny+2,nx+2,ns);

% divergent part of the viscosity
fmo_etaPat_graduax=zeros(ny+2,nx+2,ns);
fmo_etaPat_graduay=zeros(ny+2,nx+2,ns);

%++++++++++++++++++++++++++++++++++++++++++++++++
% momentum sources

smo = zeros(ny+2,nx+2,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% momentum source components

smogp = zeros(ny+2,nx+2,ns);   % sources due to pressure gradient and electric field (old form)
smogpi = zeros(ny+2,nx+2,ns);   % sources due to pressure gradient (new form)
smotf_b2sifr = zeros(ny+2,nx+2,ns);   % sources due to thermal force
smotf_b2npmo = zeros(ny+2,nx+2,ns);   % sources due to thermal force
smotf_b2sifr2 = zeros(ny+2,nx+2,ns);   % sources due to thermal force
smotf_b2npmo_manual0 = zeros(ny+2,nx+2,ns);
smotf_b2npmo_manual1 = zeros(ny+2,nx+2,ns);

smotf_ie_gradTe = zeros(ny+2,nx+2,ns);   % ion-electron thermal force
smotf_ii_gradTi = zeros(ny+2,nx+2,ns);   % ion-ion thermal force
smocf = zeros(ny+2,nx+2,ns);   % sources due to centrifuginal force
smochi = zeros(ny+2,nx+2,ns);   % sources due to ion-ion friction, velocity terms
smoche = zeros(ny+2,nx+2,ns);   % sources due to electron-ion friction, velocity terms
smovv = zeros(ny+2,nx+2,ns);   % sources due to viscosity, first term
smovh = zeros(ny+2,nx+2,ns);   % sources due to viscosity, second term
smoat = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (from eirene)
smoii = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (ion-ion collisions)
smocx = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (charge exchange)
smo_ion = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (ionization)
smo_rec = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (recombination)
smo_smq = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (ion-ion collisions)
smq_sral = zeros(ny+2,nx+2,ns);   % sources due to atomic processes (ion-ion collisions)
smoEprll = zeros(ny+2,nx+2,ns);  % sources due to electric field (new form)
smodt = zeros(ny+2,nx+2,ns);   % time derivatives
smoch_ii_u0 = zeros(ny+2,nx+2,ns,ns);
smoch_ii_u1 = zeros(ny+2,nx+2,ns,ns);


%++++++++++++++++++++++++++++++++++++++++++++++++
% radiation losses

Qrad=zeros(ny+2,nx+2,ns);  % ion line radiation (Watts)
QBR=zeros(ny+2,nx+2,ns);   % ion Bremmstrahlung radiation (Watts)


%++++++++++++++++++++++++++++++++++++++++++++++++
% anomalous transport coefficients

dna = zeros(ny+2,nx+2,ns);  % diffusion coefficient for -D grad n
dpa = zeros(ny+2,nx+2,ns);  % diffusion coefficient for -D grad p (for fluid neutrals)
vlax = zeros(ny+2,nx+2,ns);  % pinch velocity 
vlay = zeros(ny+2,nx+2,ns);  % pinch velocity 
hce = zeros(ny+2,nx+2);     % electron heat conductivity
hci = zeros(ny+2,nx+2,ns+1);  % ion heat conductivity - contribution from each species and total value



if EIRENE_flag 
    Eirene_neutral_counter = 1;
    sna_eir=zeros(ny+2,nx+2,ns);
end;


for is=1:ns
    if SOLPS_ITER==1
          is_string = num2str(is-1,'%0.3i');
          if EIRENE_flag == 1
              Eir_nc_string = num2str(Eirene_neutral_counter,'%0.3i');
          end;
    else
          is_string = num2str(is-1,'%0.2i');
          if EIRENE_flag == 1
              Eir_nc_string = num2str(Eirene_neutral_counter,'%0.2i');
          end;
    end;
    
    % velocities
    ua(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_ua' is_string '.dat'],nx,ny);
    ua0(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_ua_input' is_string '.dat'],nx,ny);
        
    if Za(is)==0  % special treatment of neutral particles because of optional usage of Eirene
        
        if EIRENE_flag == 1 % read output from Eirene
            
            % densities
           if exist([PATH_PREFIX 'b2stbr_dab2_eir' Eir_nc_string '.dat'],'file') == 2
             na(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_dab2_eir' Eir_nc_string '.dat'],nx,ny);
            
%             % fluxes
%             fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_pfluxa_eir' Eir_nc_string '.dat'],nx,ny); %.*hy(:,:).*hz(:,:);
%             fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_rfluxa_eir' Eir_nc_string '.dat'],nx,ny); %.*hx(:,:).*hz(:,:);
            
             if Eirene_neutral_counter == 1
                %molecules density
                nD2=readdatavalue([PATH_PREFIX 'b2stbr_dmb2_eir' Eir_nc_string '.dat'],nx,ny); % Deuterium molecules
%                tD2=readdatavalue([PATH_PREFIX 'b2stbr_tmb2_eir' Eir_nc_string '.dat'],nx,ny); % Deuterium molecules temperature
%                tD2 = tD2/qe;
                
                % fluxes
                fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_pfluxa_eir' Eir_nc_string '.dat'],nx,ny) + ... 
                    2.0*readdatavalue([PATH_PREFIX 'b2stbr_pfluxm_eir' Eir_nc_string '.dat'],nx,ny).*hy1(:,:).*hz(:,:);
                fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_rfluxa_eir' Eir_nc_string '.dat'],nx,ny) + ...
                    2.0*readdatavalue([PATH_PREFIX 'b2stbr_rfluxm_eir' Eir_nc_string '.dat'],nx,ny).*hx(:,:).*hz(:,:);
             else
               % fluxes
               fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_pfluxa_eir' Eir_nc_string '.dat'],nx,ny).*hy1(:,:).*hz(:,:);
               fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_rfluxa_eir' Eir_nc_string '.dat'],nx,ny).*hx(:,:).*hz(:,:);
             end;
           else
               'WARNING!: no output from EIRENE is available.'
               'Neutral densities and fluxes are set to zero.'
           end;
            Eirene_neutral_counter = Eirene_neutral_counter + 1;
            
        else  % read standard B2 output for fluid neutrals
            
            %densities
            na(:,:,is)=readdatavalue([PATH_PREFIX 'b2npco_na' is_string '.dat'],nx,ny);
            
            % fluxes
            if exist([PATH_PREFIX 'b2tfnb_fnbx' is_string '.dat'],'file') == 2
               fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnbx' is_string '.dat'],nx,ny);
               fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnby' is_string '.dat'],nx,ny);
            elseif exist([PATH_PREFIX 'fnax' is_string '.dat'],'file') == 2
               'WARNING!: no output from b2tfnb seems to be available.'
               'Trying to read fluxes from standard output b2wdat=1'
               fnax(:,:,is)=readdatavalue([PATH_PREFIX 'fnax' is_string '.dat'],nx,ny);
               fnay(:,:,is)=readdatavalue([PATH_PREFIX 'fnay' is_string '.dat'],nx,ny);
            else
               'WARNING!: no data for fnax and fnay is available'
               'Fluxes are set to zeros'
            end;
               
            
            % particle sources
            sna(:,:,is)=readdatavalue([PATH_PREFIX 'b2npco_sna' is_string '.dat'],nx,ny);
            sna_sral(:,:,is)=readdatavalue([PATH_PREFIX 'b2sral_sna0' is_string '.dat'],nx,ny)+na(:,:,is).*readdatavalue([PATH_PREFIX 'b2sral_sna1' is_string '.dat'],nx,ny);

            % momentum fluxes
            fmox(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmox' is_string '.dat'],nx,ny);
            fmoy(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmoy' is_string '.dat'],nx,ny);
            if exist([PATH_PREFIX 'b2tfnb_fnb_fcorx' is_string '.dat'],'file') == 2
               fmo_corx(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnb_fcorx' is_string '.dat'],nx,ny);
               fmo_cory(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnb_fcory' is_string '.dat'],nx,ny);
            else
                'WARNING!: no output from b2tfnb seems to be available.'
                'fmo_corx and fmo_cory are set to zeros'
            end;
            fmo_etaPat_graduax(:,:,is)=readdatavalue([PATH_PREFIX 'b2urmo_etaPat_graduax' is_string '.dat'],nx,ny);
            fmo_etaPat_graduay(:,:,is)=readdatavalue([PATH_PREFIX 'b2urmo_etaPat_graduay' is_string '.dat'],nx,ny);

            % momentum sources           
            smo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smo' is_string '.dat'],nx,ny);
   
        end;
        
        fnax_mdf(:,:,is) = fnax(:,:,is);
        fnay_mdf(:,:,is) = fnay(:,:,is);
        
    else   % read standard B2 output for charged particles
        
        % densities
        if exist([PATH_PREFIX 'b2npc9_na' is_string '.dat'],'file') == 2
            na(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_na' is_string '.dat'],nx,ny);
%            na(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_na' is_string '.dat'],nx,ny);
        elseif exist([PATH_PREFIX 'b2npco_na' is_string '.dat'],'file') == 2
            na(:,:,is)=readdatavalue([PATH_PREFIX 'b2npco_na' is_string '.dat'],nx,ny);
        elseif exist([PATH_PREFIX 'na' is_string '.dat'],'file') == 2
            na(:,:,is)=readdatavalue([PATH_PREFIX 'na' is_string '.dat'],nx,ny);
        else
            'No data for na is available'
            stop;
        end;
 
        % fluxes
        if exist([PATH_PREFIX 'b2tfnb_fnbx' is_string '.dat'],'file') == 2
               fnax(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnbx' is_string '.dat'],nx,ny);
               fnay(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnby' is_string '.dat'],nx,ny);
        elseif exist([PATH_PREFIX 'fnax' is_string '.dat'],'file') == 2
               'WARNING!: no output from b2tfnb seems to be available.'
               'Trying to read fluxes from standard output b2wdat=1'
               fnax(:,:,is)=readdatavalue([PATH_PREFIX 'fnax' is_string '.dat'],nx,ny);
               fnay(:,:,is)=readdatavalue([PATH_PREFIX 'fnay' is_string '.dat'],nx,ny);
        else
               'WARNING!: no data for fnax and fnay is available'
               'Fluxes are set to zeros'
        end;
% %         fnax(:,:,is)=readdatavalue([PATH_PREFIX 'fnax' is_string '.dat'],nx,ny);
% %         fnay(:,:,is)=readdatavalue([PATH_PREFIX 'fnay' is_string '.dat'],nx,ny);
        
        fnax_mdf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_fnax' is_string '.dat'],nx,ny);
        fnay_mdf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_fnay' is_string '.dat'],nx,ny);
%         fnax_mdf(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnb_mdfx' is_string '.dat'],nx,ny);
%         fnay_mdf(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnb_mdfy' is_string '.dat'],nx,ny);


        % flux components
        if exist([PATH_PREFIX 'b2tfnb_dPat_mdf_gradnax' is_string '.dat'],'file') == 2
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
        else
           'WARNING!: no output from b2tfnb seems to be available.'
           'Particle flux components and drift velocities are set to zeros'
        end;
        
        % particle sources
        if exist([PATH_PREFIX 'b2npc9_sna' is_string '.dat'],'file') == 2
            sna(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_sna' is_string '.dat'],nx,ny);
        elseif exist([PATH_PREFIX 'b2npco_sna' is_string '.dat'],'file') == 2
            sna(:,:,is)=readdatavalue([PATH_PREFIX 'b2npco_sna' is_string '.dat'],nx,ny);
        elseif exist([PATH_PREFIX 'sna0' is_string '.dat'],'file') == 2
            sna(:,:,is)=readdatavalue([PATH_PREFIX 'sna0' is_string '.dat'],nx,ny) + ...
                na(:,:,is).*readdatavalue([PATH_PREFIX 'sna1' is_string '.dat'],nx,ny);
        else
            'no data for na is available'
            stop;
        end;
%        sna(:,:,is)=readdatavalue([PATH_PREFIX 'b2npc9_sna' is_string '.dat'],nx,ny);
        if exist([PATH_PREFIX 'b2sral_sna0' is_string '.dat'],'file') == 2
            sna_sral(:,:,is)=readdatavalue([PATH_PREFIX 'b2sral_sna0' is_string '.dat'],nx,ny)+na(:,:,is).*readdatavalue([PATH_PREFIX 'b2sral_sna1' is_string '.dat'],nx,ny);
        else
            'WARNING!: No data for particle source from b2sral are available'
            'Particle source is set to zeros'
        end;
        
        if EIRENE_flag == 1 % read output from Eirene
           if exist([PATH_PREFIX 'b2stbr_sna_eir' is_string '.dat'],'file') == 2
              sna_eir(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_sna_eir' is_string '.dat'],nx,ny);
           else
               'WARNING!: no output from EIRENE is available.'
               'Particle source from Eirene is set to zero'
           end;
        end;
        
        % momentum fluxes
        fmox(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmox' is_string '.dat'],nx,ny);
        fmoy(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmoy' is_string '.dat'],nx,ny);
        if exist([PATH_PREFIX 'b2tfnb_fnb_fcorx' is_string '.dat'],'file') == 2
               fmo_corx(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnb_fcorx' is_string '.dat'],nx,ny);
               fmo_cory(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_fnb_fcory' is_string '.dat'],nx,ny);
        else
                'WARNING!: no output from b2tfnb seems to be available.'
                'fmo_corx and fmo_cory are set to zeros'
        end;
        fmo_etaPat_graduax(:,:,is)=readdatavalue([PATH_PREFIX 'b2urmo_etaPat_graduax' is_string '.dat'],nx,ny);
        fmo_etaPat_graduay(:,:,is)=readdatavalue([PATH_PREFIX 'b2urmo_etaPat_graduay' is_string '.dat'],nx,ny);
       

        
        % momentum sources
        smo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smo' is_string '.dat'],nx,ny);
        if exist([PATH_PREFIX 'b2sral_smo0' is_string '.dat'],'file') == 2
            smo_sral(:,:,is)=readdatavalue([PATH_PREFIX 'b2sral_smo0' is_string '.dat'],nx,ny) + ...
                readdatavalue([PATH_PREFIX 'b2sral_smo1' is_string '.dat'],nx,ny).*ua0(:,:,is); % terms #2 and #3 are zeros
            smq_sral(:,:,is)=readdatavalue([PATH_PREFIX 'b2sral_smq0' is_string '.dat'],nx,ny) + ...
                readdatavalue([PATH_PREFIX 'b2sral_smq1' is_string '.dat'],nx,ny).*ua0(:,:,is); % terms #2 and #3 are zeros
        else
            'WARNING!: No data for momentum source from b2sral are available'
            'Particle source is set to zeros'
        end;

            
        % momentum source components
        if exist([PATH_PREFIX 'b2npmo_smogp' is_string '.dat'],'file') == 2
            smogp(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smogp' is_string '.dat'],nx,ny);
        end
        if exist([PATH_PREFIX 'b2sigp_smbgp_wrk0' is_string '.dat'],'file') == 2
            smogpi(:,:,is)=readdatavalue([PATH_PREFIX 'b2sigp_smbgp_wrk0' is_string '.dat'],nx,ny); 
        end;
        if exist([PATH_PREFIX 'b2sigp_smbgp_wrk1' is_string '.dat'],'file') == 2
            smoEprll(:,:,is)=readdatavalue([PATH_PREFIX 'b2sigp_smbgp_wrk1' is_string '.dat'],nx,ny); 
        end;
       
        if exist([PATH_PREFIX 'b2sifr_smotf' is_string '.dat'],'file') == 2
            smotf_b2sifr(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_smotf' is_string '.dat'],nx,ny);
        end;
        if exist([PATH_PREFIX 'b2sifr_smotf' is_string '.dat'],'file') == 2
            smotf_b2sifr2(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf' is_string '.dat'],nx,ny);
        end;
        if exist([PATH_PREFIX 'b2sifr_smotf' is_string '.dat'],'file') == 2
            smotf_b2npmo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smotf' is_string '.dat'],nx,ny);
        end;
%        smotf_b2npmo_manual0(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_0' is_string '.dat'],nx,ny) + ...
%            readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_1' is_string '.dat'],nx,ny).* ...
%            readdatavalue([PATH_PREFIX 'b2npmo_ua_input' is_string '.dat'],nx,ny);
%        smotf_b2npmo_manual1(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_0' is_string '.dat'],nx,ny) + ...
%            readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_1' is_string '.dat'],nx,ny).* ua0(:,:,is);

        if exist([PATH_PREFIX 'b2sifr2_smotf_ii_gTi' is_string '.dat'],'file') == 2
            smotf_ii_gradTi(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ii_gTi' is_string '.dat'],nx,ny);
        end;
        if exist([PATH_PREFIX 'b2sifr2_smotf_ie_gTe' is_string '.dat'],'file') == 2
            smotf_ie_gradTe(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_gTe' is_string '.dat'],nx,ny);
        end;
        
        smocf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smocf' is_string '.dat'],nx,ny);
        if exist([PATH_PREFIX 'b2sifr_smoch' is_string '.dat'],'file') == 2
            smochi(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_smoch' is_string '.dat'],nx,ny);
        end;
        if exist([PATH_PREFIX 'b2sifr2_smotf_ie_u' is_string '.dat'],'file') == 2
            smoche(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u' is_string '.dat'],nx,ny);
        end;

%        smotf_b2npmo_manual0(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_0' is_string '.dat'],nx,ny) + ...
%            readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_1' is_string '.dat'],nx,ny).* ua0(:,:,is) + smotf_ie_gradTe(:,:,is) + smotf_ii_gradTi(:,:,is);
%        smotf_b2npmo_manual1(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_0' is_string '.dat'],nx,ny) + ...
%            readdatavalue([PATH_PREFIX 'b2sifr2_smotf_ie_u_1' is_string '.dat'],nx,ny).* ua(:,:,is)  + smotf_ie_gradTe(:,:,is) + smotf_ii_gradTi(:,:,is);

        
        if is == is_main 
            smovv(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smovv' is_string '.dat'],nx,ny);
            smovh(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smovh' is_string '.dat'],nx,ny);
        end;
        smoii(:,:,is)=readdatavalue([PATH_PREFIX 'b2stcx_smq' is_string '.dat'],nx,ny)+ ...
            readdatavalue([PATH_PREFIX 'b2stel_smq_ion' is_string '.dat'],nx,ny)+ ...
            readdatavalue([PATH_PREFIX 'b2stel_smq_rec' is_string '.dat'],nx,ny);
        smocx(:,:,is) = readdatavalue([PATH_PREFIX 'b2stcx_smq' is_string '.dat'],nx,ny);
        smo_ion(:,:,is) = readdatavalue([PATH_PREFIX 'b2stel_smq_ion' is_string '.dat'],nx,ny);
        smo_rec(:,:,is) = readdatavalue([PATH_PREFIX 'b2stel_smq_rec' is_string '.dat'],nx,ny); 
        
       if exist([PATH_PREFIX 'b2npmo_smq' is_string '.dat'],'file') == 2
          smo_smq(:,:,is) = readdatavalue([PATH_PREFIX 'b2npmo_smq' is_string '.dat'],nx,ny);
       end;
        
        smodt(:,:,is)=readdatavalue([PATH_PREFIX 'b2srdt_smodt' is_string '.dat'],nx,ny);
%++++++++++++++++++++++++++++++++++++++++++++++++
% thermal force coefficients
% % % % % %         smotf_ie_u_0(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_smotf_ie_u_0' is_string '.dat'],nx,ny);
% % % % % %         smotf_ie_u_1(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_smotf_ie_u_1' is_string '.dat'],nx,ny);
% % % % % %         smotf_ie_gradTe(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_smotf_ie_gTe' is_string '.dat'],nx,ny);
% % % % % %         smotf_ii_gradTi(:,:,is)=readdatavalue([PATH_PREFIX 'b2sifr_smotf_ii_gTi' is_string '.dat'],nx,ny);  
% % % % % %         
% % % % % %         for is1 = 1:ns
% % % % % %            is1_string = num2str(is1-1,'%0.3i');
% % % % % %            smoch_ii_u0(:,:,is,is1)=readdatavalue([PATH_PREFIX 'b2sifr_smoch_fric_ii_0_' is_string '_' is1_string '.dat'],nx,ny);
% % % % % %            smoch_ii_u1(:,:,is,is1)=readdatavalue([PATH_PREFIX 'b2sifr_smoch_fric_ii_1_' is_string '_' is1_string '.dat'],nx,ny);
% % % % % %         end;
    
        
%        ue = readdatavalue([PATH_PREFIX 'b2sifr_ue.dat'],nx,ny);  

        if EIRENE_flag
           if exist([PATH_PREFIX 'b2stbr_smo_eir' is_string '.dat'],'file') == 2
               smoat(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_smo_eir' is_string '.dat'],nx,ny);
           else
               'WARNING!: no output from EIRENE is available.'
               'Momentum source from Eirene is set to zero'
           end;
        end;

        snadt(:,:,is)=readdatavalue([PATH_PREFIX 'b2srdt_snadt' is_string '.dat'],nx,ny);
       
    end;
    
    Qrad(:,:,is)=readdatavalue([PATH_PREFIX 'b2stel_rqrad' is_string '.dat'],nx,ny);
    QBR(:,:,is)=readdatavalue([PATH_PREFIX 'b2stel_rqbrm' is_string '.dat'],nx,ny);

    dna(:,:,is) = readdatavalue([PATH_PREFIX 'dna0' is_string '.dat'],nx,ny);
%    dpa(:,:,is) = readdatavalue([PATH_PREFIX 'b2tqna_in_dpa0' is_string '.dat'],nx,ny);
%    vlax(:,:,is) = readdatavalue([PATH_PREFIX 'b2tqna_in_vla0x' is_string '.dat'],nx,ny);
%    vlay(:,:,is) = readdatavalue([PATH_PREFIX 'b2tqna_in_vla0y' is_string '.dat'],nx,ny);
%    hci(:,:,is) = readdatavalue([PATH_PREFIX 'b2tqna_in_hcib' is_string '.dat'],nx,ny);



            
end;

% % % % % % % % % % % %electron-ion collision time, electron collision time
if exist([PATH_PREFIX 'b2sifr_lnlam.dat'],'file') == 2
     Lambda_Coulomb_b2sifr = readdatavalue([PATH_PREFIX 'b2sifr_lnlam.dat'],nx,ny);
elseif exist([PATH_PREFIX 'b2sifr2_lnlam.dat'],'file') == 2
     Lambda_Coulomb_b2sifr = readdatavalue([PATH_PREFIX 'b2sifr2_lnlam.dat'],nx,ny);
end;
% % % % % % tau_ei=readdatavalue([PATH_PREFIX 'b2tqce_taue.dat'],nx,ny);
% % % % % % taue=readdatavalue([PATH_PREFIX 'b2sifr_taue.dat'],nx,ny);
% % % % % % ctaup=readdatavalue([PATH_PREFIX 'b2sifr_ctaup.dat'],nx,ny);
% % % % % % csiglcn=readdatavalue([PATH_PREFIX 'b2sifr_csiglcn.dat'],nx,ny);
% % % % % % cheflim=readdatavalue([PATH_PREFIX 'b2sifr_cheflim.dat'],nx,ny);
% % % % % % smotf_alx=readdatavalue([PATH_PREFIX 'b2sifr_smotf_alx.dat'],nx,ny);
% % % % % % smotf_btx=readdatavalue([PATH_PREFIX 'b2sifr_smotf_btx.dat'],nx,ny);
% % % % % % smotf_alx_imp=readdatavalue([PATH_PREFIX 'b2sifr_smotf_alx_imp.dat'],nx,ny);
% % % % % % smotf_btx_imp=readdatavalue([PATH_PREFIX 'b2sifr_smotf_btx_imp.dat'],nx,ny);
% % % % % % smotf_wrk_nimp2=readdatavalue([PATH_PREFIX 'b2sifr_smotf_wrk_nimp2.dat'],nx,ny);
% % % % % % smotf_delte=readdatavalue([PATH_PREFIX 'b2sifr_delte.dat'],nx,ny);
% % % % % % smotf_delti=readdatavalue([PATH_PREFIX 'b2sifr_delti.dat'],nx,ny);
% ue=readdatavalue([PATH_PREFIX 'b2sifr2_ue.dat'],nx,ny);
% % % % % % smotf_sum_nz2_sqrt_m=readdatavalue([PATH_PREFIX 'b2sifr_sum_nz2_sqrt_m.dat'],nx,ny);

%hci(:,:,is+1) = readdatavalue([PATH_PREFIX 'b2tqna_in_hci0.dat'],nx,ny);
%hce(:,:) = readdatavalue([PATH_PREFIX 'b2tqna_in_hce0.dat'],nx,ny);

%++++++++++++++++++++++++++++++++++++++++++++
% currents
if exist([PATH_PREFIX 'b2npp7_fchx.dat'],'file') == 2
    jx=readdatavalue([PATH_PREFIX 'b2npp7_fchx.dat'],nx,ny);
    jy=readdatavalue([PATH_PREFIX 'b2npp7_fchy.dat'],nx,ny);
elseif exist([PATH_PREFIX 'fchx.dat'])
    jx=readdatavalue([PATH_PREFIX 'fchx.dat'],nx,ny);
    jy=readdatavalue([PATH_PREFIX 'fchy.dat'],nx,ny);
else
    'no data for currents is available'
    stop;
end;

%++++++++++++++++++++++++++++++++++++++++++++
% current components
if exist([PATH_PREFIX 'b2tfhe_fch_px.dat'],'file') == 2
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
    jy_stoch=readdatavalue([PATH_PREFIX 'b2tfhe_fchstoch.dat'],nx,ny); % radial current due to magnetic field stochastisity
elseif exist([PATH_PREFIX 'fchx_p.dat'],'file') == 2
    jx_prll=readdatavalue([PATH_PREFIX 'fchx_p.dat'],nx,ny); %parallel current
    jy_prll = readdatavalue([PATH_PREFIX 'fchy_p.dat'],nx,ny); % should be dummy
    jx_in=readdatavalue([PATH_PREFIX 'fchinx.dat'],nx,ny); % ion-neutral current
    jy_in=readdatavalue([PATH_PREFIX 'fchiny.dat'],nx,ny); % ion-neutral current
    jx_inert=readdatavalue([PATH_PREFIX 'fchinertx.dat'],nx,ny); % inertial current
    jy_inert=readdatavalue([PATH_PREFIX 'fchinerty.dat'],nx,ny); % inertial current
    jx_visper=zeros(ny+2,nx+2); % due to perp viscousity
    jy_visper=readdatavalue([PATH_PREFIX 'fchvispery.dat'],nx,ny); % due to perp viscousity
    jx_vispar=readdatavalue([PATH_PREFIX 'fchvisparx.dat'],nx,ny); % due to parll viscousity
    jy_vispar=readdatavalue([PATH_PREFIX 'fchvispary.dat'],nx,ny); % due to parll viscousity
    jx_visq = zeros(ny+2,nx+2);
    jy_visq = readdatavalue([PATH_PREFIX 'fchvisqy.dat'],nx,ny);
    jx_AN=readdatavalue([PATH_PREFIX 'fchanmlx.dat'],nx,ny); % artificial 'anomalous' current
    jy_AN=readdatavalue([PATH_PREFIX 'fchanmly.dat'],nx,ny); % artificial 'anomalous' current
    jx_dia=readdatavalue([PATH_PREFIX 'fchdiax.dat'],nx,ny); % diamagnetic current
    jy_dia=readdatavalue([PATH_PREFIX 'fchdiay.dat'],nx,ny); % diamagnetic current
    jx_stoch=zeros(ny+2,nx+2);
    jy_stoch=zeros(ny+2,nx+2); 
else
    'no data for currents is available'
    stop;
end;
    
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
sigx=readdatavalue([PATH_PREFIX 'b2tral_csigx.dat'],nx,ny); % classical "conductivity"
sigx_luc=readdatavalue([PATH_PREFIX 'b2trcl_luciani_csigx.dat'],nx,ny); % "conductivity" with flux limiting correction applied


%++++++++++++++++++++++++++++++++++++++++++++++++
% heat sources

if exist([PATH_PREFIX 'b2nph9_she.dat'],'file') == 2
    she = readdatavalue([PATH_PREFIX 'b2nph9_she.dat'],nx,ny);
    shi = readdatavalue([PATH_PREFIX 'b2nph9_shi.dat'],nx,ny);
    shei = readdatavalue([PATH_PREFIX 'b2nph9_shei.dat'],nx,ny);
elseif exist([PATH_PREFIX 'b2npht_she.dat'],'file') == 2
    she = readdatavalue([PATH_PREFIX 'b2npht_she.dat'],nx,ny);
    shi = readdatavalue([PATH_PREFIX 'b2npht_shi.dat'],nx,ny);
    shei = readdatavalue([PATH_PREFIX 'b2npht_shei.dat'],nx,ny);
elseif exist([PATH_PREFIX 'she0.dat'],'file') == 2
    ne=zeros(ny+2,nx+2);
    ni=zeros(ny+2,nx+2);
    for i=1:ns
        ne(:,:)=ne(:,:)+na(:,:,is)*Za(is);
        ni(:,:)=ni(:,:)+na(:,:,is);
    end;
    she = readdatavalue([PATH_PREFIX 'she0.dat'],nx,ny) + readdatavalue([PATH_PREFIX 'she1.dat'],nx,ny).*te*qe + ...
        readdatavalue([PATH_PREFIX 'she2.dat'],nx,ny).*ne + readdatavalue([PATH_PREFIX 'she3.dat'],nx,ny).*te.*ne*qe;
    shi = readdatavalue([PATH_PREFIX 'shi0.dat'],nx,ny) + readdatavalue([PATH_PREFIX 'shi1.dat'],nx,ny).*ti*qe + ...
        readdatavalue([PATH_PREFIX 'shi2.dat'],nx,ny).*ni + readdatavalue([PATH_PREFIX 'shi3.dat'],nx,ny).*ti.*ni*qe;
    shei = zeros(ny+2,nx+2);
else
    'no date for heat sources are available'
    stop;
end;

shedd = readdatavalue([PATH_PREFIX 'b2sihs__shedd.dat'],nx,ny);
shedu = readdatavalue([PATH_PREFIX 'b2sihs__shedu.dat'],nx,ny);
shefr = readdatavalue([PATH_PREFIX 'b2sihs__shefr.dat'],nx,ny);

shidd = readdatavalue([PATH_PREFIX 'b2sihs__shidd.dat'],nx,ny);
shidu = readdatavalue([PATH_PREFIX 'b2sihs__shidu.dat'],nx,ny);
shifr = readdatavalue([PATH_PREFIX 'b2sihs__shifr.dat'],nx,ny);
shiva = readdatavalue([PATH_PREFIX 'b2sihs__shiva.dat'],nx,ny);
shivc = readdatavalue([PATH_PREFIX 'b2sihs__shivc.dat'],nx,ny);

% total electron heat source due to electron-atom/ion collisions (negative
% sign means that in fact it is a sink) (Watts)
she_stel=readdatavalue([PATH_PREFIX 'b2stel_she_rad.dat'],nx,ny);

% electron heat source due to collision with neutrals (from Eirene)  (Watts)
if EIRENE_flag==1
    if exist([PATH_PREFIX 'b2stbr_she_eir.dat'],'file') == 2
        she_eir=readdatavalue([PATH_PREFIX 'b2stbr_she_eir.dat'],nx,ny);
    else
               'WARNING!: no output from EIRENE is available.'
               'Electron heat source from Eirene is set to zero'
    end;
end;

% ion heat source due to ionization (Watts)
shi_ion_stel=readdatavalue([PATH_PREFIX 'b2stel_shi_ion.dat'],nx,ny);

% ion heat source due to recombination (Watts)
shi_rec_stel=readdatavalue([PATH_PREFIX 'b2stel_shi_rec.dat'],nx,ny);

% ion heat source due to collision with neutrals (from Eirene) (Watts)
if EIRENE_flag==1
    if exist([PATH_PREFIX 'b2stbr_shi_eir.dat'],'file') == 2
        shi_eir=readdatavalue([PATH_PREFIX 'b2stbr_shi_eir.dat'],nx,ny);
    else
               'WARNING!: no output from EIRENE is available.'
               'Electron heat source from Eirene is set to zero'
    end;
end;

shi_stbr=readdatavalue([PATH_PREFIX 'b2stbr_shi.dat'],nx,ny);


%++++++++++++++++++++++++++++++++++++++++++++++++
% heat fluxes

if exist([PATH_PREFIX 'b2nph9_fhex.dat'],'file') == 2
    
    fhex_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhex.dat'],nx,ny);
    fhey_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhey.dat'],nx,ny);

    fhix_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhix.dat'],nx,ny);
    fhiy_mdf=readdatavalue([PATH_PREFIX 'b2nph9_fhiy.dat'],nx,ny);

    fhex=readdatavalue([PATH_PREFIX 'b2tfhe_fhe_no_mdfx.dat'],nx,ny);
    fhey=readdatavalue([PATH_PREFIX 'b2tfhe_fhe_no_mdfy.dat'],nx,ny);

%    fhix=readdatavalue([PATH_PREFIX 'b2tfhi_fhix.dat'],nx,ny);
%    fhiy=readdatavalue([PATH_PREFIX 'b2tfhi_fhiy.dat'],nx,ny);
    fhix=zeros(ny+2,nx+2);
    fhiy=zeros(ny+2,nx+2);
    
elseif exist([PATH_PREFIX 'b2npht_fhex.dat'],'file') == 2
    
    fhex_mdf=readdatavalue([PATH_PREFIX 'b2npht_fhex.dat'],nx,ny);
    fhey_mdf=readdatavalue([PATH_PREFIX 'b2npht_fhey.dat'],nx,ny);

    fhix_mdf=readdatavalue([PATH_PREFIX 'b2npht_fhix.dat'],nx,ny);
    fhiy_mdf=readdatavalue([PATH_PREFIX 'b2npht_fhiy.dat'],nx,ny);

    fhex=fhex_mdf;
    fhey=fhey_mdf;

    fhix=fhix_mdf;
    fhiy=fhiy_mdf;

elseif exist([PATH_PREFIX 'fhex.dat'],'file') == 2
    
    fhex_mdf=readdatavalue([PATH_PREFIX 'fhex.dat'],nx,ny);
    fhey_mdf=readdatavalue([PATH_PREFIX 'fhey.dat'],nx,ny);

    fhix_mdf=readdatavalue([PATH_PREFIX 'fhix.dat'],nx,ny);
    fhiy_mdf=readdatavalue([PATH_PREFIX 'fhiy.dat'],nx,ny);

    fhex=fhex_mdf;
    fhey=fhey_mdf;

    fhix=fhix_mdf;
    fhiy=fhiy_mdf;
    
else
    'No data for heat fluxes are available'
    stop;
end;
%++++++++++++++++++++++++++++++++++++++++++++++++
% heat flux components

%============= FIX ME for the case of old numerical scheme without 9 points ==
fhex_ke_gTx=readdatavalue([PATH_PREFIX 'b2tfhe__qe_ke_gTx.dat'],nx,ny);
fhey_ke_gTy=readdatavalue([PATH_PREFIX 'b2tfhe__qe_ke_gTy.dat'],nx,ny);

fhex_32GammaT=readdatavalue([PATH_PREFIX 'b2tfhe__qe_32x.dat'],nx,ny);
fhey_32GammaT=readdatavalue([PATH_PREFIX 'b2tfhe__qe_32y.dat'],nx,ny);

fhex_PSch=readdatavalue([PATH_PREFIX 'b2tfhe_fhePSchx.dat'],nx,ny);
fhey_PSch=readdatavalue([PATH_PREFIX 'b2tfhe_fhePSchy.dat'],nx,ny);

fhix_ki_gTx=readdatavalue([PATH_PREFIX 'b2tfhi__qi_ki_gTx.dat'],nx,ny);
fhiy_ki_gTy=readdatavalue([PATH_PREFIX 'b2tfhi__qi_ki_gTy.dat'],nx,ny);

fhix_32GammaT=readdatavalue([PATH_PREFIX 'b2tfhi__qi_32x.dat'],nx,ny);
fhiy_32GammaT=readdatavalue([PATH_PREFIX 'b2tfhi__qi_32y.dat'],nx,ny);

fhix_PSch=readdatavalue([PATH_PREFIX 'b2tfhi__fhiPSchx.dat'],nx,ny);
fhiy_PSch=readdatavalue([PATH_PREFIX 'b2tfhi__fhiPSchy.dat'],nx,ny);

%============= FIX ME !!!!!!!!!! =============================================

% % % fhex_ke_gTx = zeros(ny+2,nx+2);
% % % fhex_ke_gTx = zeros(ny+2,nx+2);


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
    fhtotX(i+1,1)=1.0e6*fhtot_low_inner(i)*hy(i+1,1)*hz(i+1,1);

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
       fhtotX(i+1,ntt+3)=1.0e6*fhtot_upper_outer(i)*hy(i+1,ntt+3)*hz(i+1,ntt+3);
    end;
end;


%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================
%======= READ NEUTRAL DENSITY AND RELATED QUANTITIES ON EIRENE'S TRIANGULAR MESH
%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================

 if EIRENE_flag
     
     pdena = zeros(Natmi,N_tria); % density of each atom specie in each Eirene triangle
     pdenm = zeros(Nmoli,N_tria); % density of each molecule specie in each Eirene triangle
     pdeni = zeros(Nioni,N_tria); % density of each test ion specie in each Eirene triangle

% READ TRIANGLE VOLUME FROM EIRENE
     vol_eir = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,1,N_tria+3,1]) * 1.0e-6;
     
% READ DENSITIES FROM EIRENE OUTPUT AND CONVERT TO SI UNITS
     pdena = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,1+1,N_tria+3,Natmi+1]) * 1.0e6;
     pdenm = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,Natmi+1+1,N_tria+3,Natmi+Nmoli+1]) * 1.0e6;
     pdeni = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,Natmi+Nmoli+1+1,N_tria+3,Natmi+Nmoli+Nioni+1]) * 1.0e6;
 
     edena = zeros(Natmi,N_tria); % energy density of each atom specie in each Eirene triangle
     edenm = zeros(Nmoli,N_tria); % energy density of each molecule specie in each Eirene triangle
     edeni = zeros(Nioni,N_tria); % energy density of each test ion specie in each Eirene triangle
     
% READ ENERGY DENSITIES FROM EIRENE OUTPUT AND CONVERT TO SI UNITS
     edena = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,Natmi+Nmoli+Nioni+1+1,N_tria+3,2*Natmi+Nmoli+Nioni+1])*1.0e6*qe;
     edenm = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,2*Natmi+Nmoli+Nioni+1+1,N_tria+3,2*Natmi+2*Nmoli+Nioni+1])*1.0e6*qe;
     edeni = dlmread([PATH_PREFIX 'eirmod_extrab25.dat'],'',[4,2*Natmi+2*Nmoli+Nioni+1+1,N_tria+3,2*Natmi+2*Nmoli+2*Nioni+1])*1.0e6*qe;
    
 end;


