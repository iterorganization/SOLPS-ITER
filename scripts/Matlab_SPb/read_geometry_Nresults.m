%%%%%%%% READ GEOMETRY DATA

%===================================================
% This script is a part of Compare_B2.m script
%===================================================


hx=zeros(max(ny)+2,max(nx)+2,Nresults);
hy=zeros(max(ny)+2,max(nx)+2,Nresults);
hy1=zeros(max(ny)+2,max(nx)+2,Nresults);
hz=zeros(max(ny)+2,max(nx)+2,Nresults);
vol=zeros(max(ny)+2,max(nx)+2,Nresults);
Bx=zeros(max(ny)+2,max(nx)+2,Nresults);
Bz=zeros(max(ny)+2,max(nx)+2,Nresults);
B=zeros(max(ny)+2,max(nx)+2,Nresults);

R0=zeros(max(ny)+2,max(nx)+2,Nresults);
Z0=zeros(max(ny)+2,max(nx)+2,Nresults);

x1=zeros(max(ny)+2,max(nx)+2,Nresults);
x2=zeros(max(ny)+2,max(nx)+2,Nresults);
xc=zeros(max(ny)+2,max(nx)+2,Nresults);
y1=zeros(max(ny)+2,max(nx)+2,Nresults);
y2=zeros(max(ny)+2,max(nx)+2,Nresults);
yc=zeros(max(ny)+2,max(nx)+2,Nresults);

left=zeros(max(ny)+2,max(nx)+2,Nresults);
right=zeros(max(ny)+2,max(nx)+2,Nresults);
top=zeros(max(ny)+2,max(nx)+2,Nresults);
bottom=zeros(max(ny)+2,max(nx)+2,Nresults);

R_apex=zeros(ceil(max(N_apex)/4)*4,Nresults);
Z_apex=zeros(ceil(max(N_apex)/4)*4,Nresults);

for m=1:Nresults
    hx(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'hx.dat'],nx(m),ny(m),max(nx),max(ny));
    hy(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'hy.dat'],nx(m),ny(m),max(nx),max(ny));
    hy1(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'hy1.dat'],nx(m),ny(m),max(nx),max(ny));
    hz(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'hz.dat'],nx(m),ny(m),max(nx),max(ny));
    
    vol(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'vol.dat'],nx(m),ny(m),max(nx),max(ny));
    
    Bx(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'bbx.dat'],nx(m),ny(m),max(nx),max(ny));    
    Bz(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'bbz.dat'],nx(m),ny(m),max(nx),max(ny));
    B(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'bb.dat'],nx(m),ny(m),max(nx),max(ny));

    R0(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'crx0.dat'],nx(m),ny(m),max(nx),max(ny));
    Z0(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'cry0.dat'],nx(m),ny(m),max(nx),max(ny));
    
    for j=1:nx(m)+2
        yc(1,j,m) = hy(1,j,m)/2;
        y1(1,j,m) = hy(1,j,m);
        for i=2:ny(m)+2
            yc(i,j,m)=yc(i-1,j,m)+(hy(i,j,m)+hy(i-1,j,m))/2;
            y1(i,j,m)=y1(i-1,j,m)+hy(i,j,m);
        end;
    end;
% y2 is a distance from the inner separatrix
%    negative values mean either core or PRF,
%    positive values mean SOL

    for j=1:nx(m)+2
       y1_zero=y1(nsep(m)+2,j,m);
       for i=1:ny(m)+2
          y1(i,j,m)=y1(i,j,m)-y1_zero; 
          y2(i,j,m)=yc(i,j,m)-yc(nsep(m)+2,j,m)-hy(nsep(m)+2,j,m)/2;
          if i>1
             y1_shift(i,j,m)=y1(i-1,j,m);
          else
             y1_shift(i,j,m)=y1(i,j,m)-hy(i,j,m);
          end;
       end;
    end;

% In the bottom PFR, outer SOL left and inner SOL the array xc contains the
%   distance from inner bottom target
% In the CORE the array xc contains distance from the bottom cut


    for i=1:ny(m)+2
       xc(i,1,m) = hx(i,1,m)/2;
       x1(i,1,m) = hx(i,1,m);
       for j=2:nc1(m)-1+2 % SOL and bottom PFR near the inner bottom target
          xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
          x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
       end;
       if i <= nsep(m)+2 % CORE region (left part)
          xc(i,nc1(m)+2,m) = hx(i,nc1(m)+2,m)/2;
          x1(i,nc1(m)+2,m) = hx(i,nc1(m)+2,m);
       else % inner SOL and outer SOL left
          j=nc1(m)+2;  
          xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
          x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
       end;
       for j=nc1(m)+1+2:nc2(m)+2
          xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
          x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
       end;
       if nc2(m)+1 == nc3(m) && ntt(m) == nc2(m) % single null case
          j=ntt+2+1;  
          xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
          x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m); 
       else % Double null case  
          xc(i,ntt(m)+2+1,m) = hx(i,ntt(m)+2+1,m)/2;
          x1(i,ntt(m)+2+1,m) = hx(i,ntt(m)+2+1,m);         
       end;
       for j=ntt(m)+2+2:nc3(m)-1+2 % top PFR and outer SOL right
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
       end;
       if i <= nsep2(m)+2 % CORE (right part) - continue to count distance 
                    % along poloidal coordinate surface
                    % from the bottom cut
           xc(i,nc2(m)+2+1,m)=xc(i,nc3(m)-1+2,m)+(hx(i,nc3(m)-1+2,m)+hx(i,nc2(m)+2+1,m))/2;
           x1(i,nc2(m)+2+1,m)=x1(i,nc3(m)-1+2,m)+hx(i,nc2(m)+2+1,m);
       else % inner SOL and outer SOL right - continue to count distance
           j=nc2(m)+1+2;  
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
        end;
        for j=nc2(m)+2+2:ntt(m)+2 % inner part of top PFR and outer SOL left
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
        end;
        if i<= nsep2(m)+2 % CORE and inner SOL (right part)
           xc(i,nc3(m)+2,m)=xc(i,nc2(m)+2,m)+(hx(i,nc3(m)+2,m)+hx(i,nc2(m)+2,m))/2;
           x1(i,nc3(m)+2,m)=x1(i,nc2(m)+2,m)+hx(i,nc2(m)+2,m)/2;
        else % outer SOL right
           j=nc3(m)+2;  
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
        end;
        for j=nc3(m)+1+2:nc4(m)+2 % CORE (right part), inner SOL (right part) and 
                        % outer SOL right
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
        end; 
        if i <= nsep(m)+2 % CORE (right part)
           xc(i,nc4(m)+2+1,m)=xc(i,nc1(m)-1+2,m)+(hx(i,nc1(m)-1+2,m)+hx(i,nc4(m)+2+1,m))/2;
           x1(i,nc4(m)+2+1,m)=x1(i,nc1(m)-1+2,m)+hx(i,nc4(m)+2+1,m);
        else % SOL
           j=nc4(m)+1+2;  
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
        end;
        for j=nc4(m)+2+2:nx(m)+2     
           xc(i,j,m)=xc(i,j-1,m)+(hx(i,j,m)+hx(i,j-1,m))/2;
           x1(i,j,m)=x1(i,j-1,m)+hx(i,j,m);
        end;       
   end;
   for i=1:ny(m)+2
       for j=1:nx(m)+2
         if i <= nsep(m)+2 && (j < nc1(m)+2 || j > nc4(m)+2) % Bottom PFR
            xzero = 0; % to measure distance from inner bottom targer
         elseif i<=nsep2(m)+2 && j > nc2(m)+2 && j < nc3(m)+2 % Top PFR
            xzero = 0; % to measure distance from outer top target
         elseif i>nsep2(m)+2 % outer SOL left
            if nc2(m)+1 == nc3(m) && ntt(m) == nc2(m) % Single null with lower X-point active
                xzero = 0; % to measure distance from inner target 
            else
                if j<=ntt(m)+2
                    xzero = 0;
                else
                    xzero = xc(i,nx(m)+2,m)+hy(i,nx(m)+2,m); % to measure distance to outer bottom target
                end;
            end;
        else % CORE, inner SOL and outer SOL left
            xzero = xc(i,nout(m)+2,m); % to measure distance from outer midplane
        end;
        x2(i,j,m)=xc(i,j,m)-xzero;
        x1(i,j,m)=x1(i,j,m)-xzero;
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
    
    if exist([PATH_PREFIX{m} 'fort.33'],'file') == 2
        Possible_Relative_Path='';
    elseif exist([PATH_PREFIX{m} '../fort.33'],'file') == 2
        Possible_Relative_Path='../';
    elseif exist([PATH_PREFIX{m} '../baserun/fort.33'],'file') == 2
        Possible_Relative_Path='../baserun/';
    elseif exist([PATH_PREFIX{m} '../../baserun/fort.33'],'file') == 2
        Possible_Relative_Path='../../baserun/';
    else
    end;
    
%    global N_apex
    
    % N_apex is a number of apexes
    N_apex(m) = dlmread([PATH_PREFIX{m} Possible_Relative_Path 'fort.33'],'',[0,0,0,0]);
    
    if (SOLPS_ITER) 
        % Major radii of apexes as they are stored in fort.33
        R_apex_shaped = dlmread([PATH_PREFIX{m} Possible_Relative_Path 'fort.33'],'',[1,0,ceil(N_apex(m)/4),3]);
    
        % Heigh of apexes as they are stored in fort.33
        Z_apex_shaped = dlmread([PATH_PREFIX{m} Possible_Relative_Path 'fort.33'],'',[ceil(N_apex(m)/4)+1,0,ceil(N_apex(m)/4)*2,3]);
    
        % Reshape these arrays to store coordinates as 1D arrays and convert
        % from centimeters to meters
 %       global R_apex
 %       global Z_apex
        R_apex(:,m) = 0.01*reshape(R_apex_shaped',1,ceil(N_apex(m)/4)*4);
        Z_apex(:,m) = 0.01*reshape(Z_apex_shaped',1,ceil(N_apex(m)/4)*4);
    else
         % Major radii of apexes as they are stored in fort.33
         R_apex_shaped = dlmread([PATH_PREFIX{m} Possible_Relative_Path 'fort.33'],'',[1,1,N_apex(m),1]);
    
         % Heigh of apexes as they are stored in fort.33
         Z_apex_shaped = dlmread([PATH_PREFIX{m} Possible_Relative_Path 'fort.33'],'',[1,2,N_apex(m),2]);
         % Reshape these arrays to store coordinates as 1D arrays and convert
         % from centimeters to meters
  %       global R_apex
  %       global Z_apex
         R_apex(m) = 0.01*R_apex_shaped;
         Z_apex(m) = 0.01*Z_apex_shaped;
   end;
        
    
    % Ntria is a number of triangles
%    global N_tria
    N_tria(m) = dlmread([PATH_PREFIX{m} Possible_Relative_Path 'fort.34'],'',[0,0,0,0]);
   end;
    
end;