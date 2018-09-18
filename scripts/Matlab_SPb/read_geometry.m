%%%%%%%% READ GEOMETRY DATA

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

hx=readdatavalue([PATH_PREFIX 'hx.dat'],nx,ny);
hy=readdatavalue([PATH_PREFIX 'hy.dat'],nx,ny);
hy1=readdatavalue([PATH_PREFIX 'hy1.dat'],nx,ny);
hz=readdatavalue([PATH_PREFIX 'hz.dat'],nx,ny);
pbsx=readdatavalue([PATH_PREFIX 'pbsx.dat'],nx,ny);

OnedBsqc=zeros(ny+2,nx+2);
%OnedBsqc=readdatavalue([PATH_PREFIX 'OnedBsqc.dat'],nx+1,ny+1);

vol=readdatavalue([PATH_PREFIX 'vol.dat'],nx,ny);

Bx=readdatavalue([PATH_PREFIX 'bbx.dat'],nx,ny);
Bz=readdatavalue([PATH_PREFIX 'bbz.dat'],nx,ny);
B=readdatavalue([PATH_PREFIX 'bb.dat'],nx,ny);

R0=readdatavalue([PATH_PREFIX 'crx0.dat'],nx,ny);
R1=readdatavalue([PATH_PREFIX 'crx1.dat'],nx,ny);
R2=readdatavalue([PATH_PREFIX 'crx2.dat'],nx,ny);
R3=readdatavalue([PATH_PREFIX 'crx3.dat'],nx,ny);
Z0=readdatavalue([PATH_PREFIX 'cry0.dat'],nx,ny);
Z1=readdatavalue([PATH_PREFIX 'cry1.dat'],nx,ny);
Z2=readdatavalue([PATH_PREFIX 'cry2.dat'],nx,ny);
Z3=readdatavalue([PATH_PREFIX 'cry3.dat'],nx,ny);
%Z=readdatavalue([PATH_PREFIX 'cry0.dat'],nx,ny);

left=readdatavalue([PATH_PREFIX 'leftix.dat'],nx,ny);
right=readdatavalue([PATH_PREFIX 'rightix.dat'],nx,ny);
top=readdatavalue([PATH_PREFIX 'topiy.dat'],nx,ny);
bottom=readdatavalue([PATH_PREFIX 'bottomiy.dat'],nx,ny);

%Rmaj0=readdatavalue([PATH_PREFIX 'crx0.dat'],nx,ny);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% distance from separatrix

%y1=cumsum(hy,1);
%x1=cumsum(hx,2);

% yc contains distance from southern boundary,
%    either from core boundary or from boundary between divertor targets
for j=1:nx+2
    yc(1,j) = hy(1,j)/2;
    y1(1,j) = hy(1,j);
    for i=2:ny+2
        yc(i,j)=yc(i-1,j)+(hy(i,j)+hy(i-1,j))/2;
        y1(i,j)=y1(i-1,j)+hy(i,j);
    end;
end;
% y2 is a distance from the inner separatrix
%    negative values mean either core or PRF,
%    positive values mean SOL

for j=1:nx+2
    y1_zero=y1(nsep+2,j);
    for i=1:ny+2
    y1(i,j)=y1(i,j)-y1_zero; 
    y2(i,j)=yc(i,j)-yc(nsep+2,j)-hy(nsep+2,j)/2;
    if i>1
        y1_shift(i,j)=y1(i-1,j);
    else
        y1_shift(i,j)=y1(i,j)-hy(i,j);
    end;
    end;
end;

% In the bottom PFR, outer SOL left and inner SOL the array xc contains the
%   distance from inner bottom target
% In the CORE the array xc contains distance from the bottom cut

xc=zeros(ny+2,nx+2);
x1=zeros(ny+2,nx+2);

for i=1:ny+2
    xc(i,1) = hx(i,1)/2;
    x1(i,1) = hx(i,1);
    for j=2:nc1-1+2 % SOL and bottom PFR near the inner bottom target
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    if i <= nsep+2 % CORE region (left part)
      xc(i,nc1+2) = hx(i,nc1+2)/2;
      x1(i,nc1+2) = hx(i,nc1+2);
    else % inner SOL and outer SOL left
      j=nc1+2;  
      xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
      x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    for j=nc1+1+2:nc2+2
       xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
       x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    if nc2+1 == nc3 && ntt == nc2 % single null case
        j=ntt+2+1;  
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j); 
    else % Double null case  
        xc(i,ntt+2+1) = hx(i,ntt+2+1)/2;
        x1(i,ntt+2+1) = hx(i,ntt+2+1);         
    end;
    for j=ntt+2+2:nc3-1+2 % top PFR and outer SOL right
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    if i <= nsep2+2 % CORE (right part) - continue to count distance 
                    % along poloidal coordinate surface
                    % from the bottom cut
      xc(i,nc2+2+1)=xc(i,nc3-1+2)+(hx(i,nc3-1+2)+hx(i,nc2+2+1))/2;
      x1(i,nc2+2+1)=x1(i,nc3-1+2)+hx(i,nc2+2+1);
    else % inner SOL and outer SOL right - continue to count distance
      j=nc2+1+2;  
      xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
      x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    for j=nc2+2+2:ntt+2 % inner part of top PFR and outer SOL left
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    if i<= nsep2+2 % CORE and inner SOL (right part)
      xc(i,nc3+2)=xc(i,nc2+2)+(hx(i,nc3+2)+hx(i,nc2+2))/2;
      x1(i,nc3+2)=x1(i,nc2+2)+hx(i,nc2+2)/2;
    else % outer SOL right
      j=nc3+2;  
      xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
      x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    for j=nc3+1+2:nc4+2 % CORE (right part), inner SOL (right part) and 
                        % outer SOL right
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j);
    end; 
    if i <= nsep+2 % CORE (right part)
      xc(i,nc4+2+1)=xc(i,nc1-1+2)+(hx(i,nc1-1+2)+hx(i,nc4+2+1))/2;
      x1(i,nc4+2+1)=x1(i,nc1-1+2)+hx(i,nc4+2+1);
    else % SOL
      j=nc4+1+2;  
      xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
      x1(i,j)=x1(i,j-1)+hx(i,j);
    end;
    for j=nc4+2+2:nx+2     
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j);
    end;       
end;
for i=1:ny+2
    for j=1:nx+2
        if i <= nsep+2 && (j < nc1+2 || j > nc4+2) % Bottom PFR
            xzero = 0; % to measure distance from inner bottom targer
        elseif i<=nsep2+2 && j > nc2+2 && j < nc3+2 % Top PFR
            xzero = 0; % to measure distance from outer top target
        elseif i>nsep2+2 % outer SOL left
            if nc2+1 == nc3 && ntt == nc2 % Single null with lower X-point active
                xzero = 0; % to measure distance from inner target 
            else
                if j<=ntt+2
                    xzero = 0;
                else
                    xzero = xc(i,nx+2)+hy(i,nx+2); % to measure distance to outer bottom target
                end;
            end;
        else % CORE, inner SOL and outer SOL left
            xzero = xc(i,nout+2); % to measure distance from outer midplane
        end;
    x2(i,j)=xc(i,j)-xzero;
    x1(i,j)=x1(i,j)-xzero;
    end;
end;

%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================
%======= READ EIRENE'S TRIANGULAR MESH
%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================
%========================================================================================================

if EIRENE_flag
    
    if exist([PATH_PREFIX 'fort.33'],'file') == 2
        Possible_Relative_Path='';
    elseif exist([PATH_PREFIX '../fort.33'],'file') == 2
        Possible_Relative_Path='../';
    elseif exist([PATH_PREFIX '../../baserun/fort.33'],'file') == 2
        Possible_Relative_Path='../../baserun/';
    else
    end;
    
    global N_apex
    
    % N_apex is a number of apexes
    N_apex = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.33'],'',[0,0,0,0]);
    
    if (SOLPS_ITER) 
%        % Major radii of apexes as they are stored in fort.33
            R_apex_shaped = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.33'],'',[1,0,ceil(N_apex/4),3]);
    
        % Heigh of apexes as they are stored in fort.33
            Z_apex_shaped = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.33'],'',[ceil(N_apex/4)+1,0,ceil(N_apex/4)*2,3]);
%        else
%            R_apex_shaped = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.33'],'',[1,0,mod(N_apex,4)+1,3]);
%        end;
            
    
        % Reshape these arrays to store coordinates as 1D arrays and convert
        % from centimeters to meters
        global R_apex
        global Z_apex
        R_apex = 0.01*reshape(R_apex_shaped',1,ceil(N_apex/4)*4);
        Z_apex = 0.01*reshape(Z_apex_shaped',1,ceil(N_apex/4)*4);
    else
         % Major radii of apexes as they are stored in fort.33
         R_apex_shaped = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.33'],'',[1,1,N_apex,1]);
    
         % Heigh of apexes as they are stored in fort.33
         Z_apex_shaped = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.33'],'',[1,2,N_apex,2]);
         % Reshape these arrays to store coordinates as 1D arrays and convert
         % from centimeters to meters
         global R_apex
         global Z_apex
         R_apex = 0.01*R_apex_shaped;
         Z_apex = 0.01*Z_apex_shaped;
   end;
        
    
    % Ntria is a number of triangles
    global N_tria
    N_tria = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.34'],'',[0,0,0,0]);
    
    % apex indices
    global i_apex1
    global i_apex2
    global i_apex3
    i_apex1 = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.34'],'',[1,1,N_tria,1]);
    i_apex2 = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.34'],'',[1,2,N_tria,2]);
    i_apex3 = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.34'],'',[1,3,N_tria,3]);
    
    i_Neighb_tria_side1 = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.35'],'',[1,1,N_tria,1]);
    i_Neighb_tria_side2 = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.35'],'',[1,4,N_tria,4]);
    i_Neighb_tria_side3 = dlmread([PATH_PREFIX Possible_Relative_Path 'fort.35'],'',[1,7,N_tria,7]);
    
%++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Find the center of a triangle (cross of medians)
    
    global RC_tria
    global ZC_tria
    RC_tria = zeros(N_tria,1);
    ZC_tria = zeros(N_tria,1);
    
    for itria=1:N_tria
        
        detC = ( R_apex(i_apex2(itria))*Z_apex(i_apex1(itria)) - R_apex(i_apex1(itria))*Z_apex(i_apex2(itria)) + ...
                 R_apex(i_apex1(itria))*Z_apex(i_apex3(itria)) - R_apex(i_apex3(itria))*Z_apex(i_apex1(itria)) + ...
                 R_apex(i_apex3(itria))*Z_apex(i_apex2(itria)) - R_apex(i_apex2(itria))*Z_apex(i_apex3(itria)) ) * 3.0;
             
        detR = (R_apex(i_apex1(itria)))^2 * (Z_apex(i_apex3(itria))-Z_apex(i_apex2(itria))) + ...
               (R_apex(i_apex2(itria)))^2 * (Z_apex(i_apex1(itria))-Z_apex(i_apex3(itria))) + ...
               (R_apex(i_apex3(itria)))^2 * (Z_apex(i_apex2(itria))-Z_apex(i_apex1(itria))) + ...
                Z_apex(i_apex1(itria))*R_apex(i_apex1(itria)) * (R_apex(i_apex2(itria))-R_apex(i_apex3(itria))) + ...
                Z_apex(i_apex2(itria))*R_apex(i_apex2(itria)) * (R_apex(i_apex3(itria))-R_apex(i_apex1(itria))) + ...
                Z_apex(i_apex3(itria))*R_apex(i_apex3(itria)) * (R_apex(i_apex1(itria))-R_apex(i_apex2(itria)));
 
        detZ = (Z_apex(i_apex1(itria)))^2 * (R_apex(i_apex3(itria))-R_apex(i_apex2(itria))) + ...
               (Z_apex(i_apex2(itria)))^2 * (R_apex(i_apex1(itria))-R_apex(i_apex3(itria))) + ...
               (Z_apex(i_apex3(itria)))^2 * (R_apex(i_apex2(itria))-R_apex(i_apex1(itria))) + ...
                Z_apex(i_apex1(itria))*R_apex(i_apex1(itria)) * (Z_apex(i_apex2(itria))-Z_apex(i_apex3(itria))) + ...
                Z_apex(i_apex2(itria))*R_apex(i_apex2(itria)) * (Z_apex(i_apex3(itria))-Z_apex(i_apex1(itria))) + ...
                Z_apex(i_apex3(itria))*R_apex(i_apex3(itria)) * (Z_apex(i_apex1(itria))-Z_apex(i_apex2(itria)));
            
        RC_tria(itria) = detR/detC;
        ZC_tria(itria) = - detZ/detC;
        
    end;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % For each apex find all the triangles which this apex belongs to
    %               and find all the neighbouring apexes
    global neighb_apex;
    global neighb_tria;
    global N_neighb_apex;
    global N_neighb_tria;
    neighb_apex=zeros(25,N_apex);
    neighb_tria=zeros(12,N_apex);
    N_neighb_apex=zeros(N_apex,1);
    N_neighb_tria=zeros(N_apex,1);
    for iapex = 1:N_apex
        i_neighb_apex = 1;
        i_neighb_tria = 1;
        for itria=1:N_tria
            if iapex == i_apex1(itria) || iapex == i_apex2(itria) || iapex == i_apex2(itria) 
                neighb_tria(i_neighb_tria,iapex) = itria;
                i_neighb_tria = i_neighb_tria + 1;
                apex1_already_counted = 0;
                apex2_already_counted = 0;
                apex3_already_counted = 0;
                for i=1:i_neighb_apex
                    if i_apex1(itria) == neighb_apex(i) || iapex == i_apex1(itria)
                        apex1_already_counted = 1;
                    end;
                    if i_apex2(itria) == neighb_apex(i) || iapex == i_apex2(itria)
                        apex2_already_counted = 1;
                    end;
                    if i_apex3(itria) == neighb_apex(i) || iapex == i_apex3(itria)
                        apex3_already_counted = 1;
                    end;
                end;
                if apex1_already_counted == 0                     
                    neighb_apex(i_neighb_apex,iapex) = i_apex1(itria);
                    i_neighb_apex = i_neighb_apex + 1;
                end;
                if apex2_already_counted == 0                     
                    neighb_apex(i_neighb_apex,iapex) = i_apex2(itria);
                    i_neighb_apex = i_neighb_apex + 1;
                end;
                if apex3_already_counted == 0                     
                    neighb_apex(i_neighb_apex,iapex) = i_apex3(itria);
                    i_neighb_apex = i_neighb_apex + 1;
                end;
             end;
        end;
        N_neighb_apex(iapex) = i_neighb_apex - 1;
        N_neighb_tria(iapex) = i_neighb_tria - 1;
%        iapex
    end;
                
    
        

    
end;
