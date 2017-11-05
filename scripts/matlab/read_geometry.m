%%%%%%%% READ GEOMETRY DATA

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

hx=readdatavalue([PATH_PREFIX 'hx.dat'],nx,ny);
hy=readdatavalue([PATH_PREFIX 'hy.dat'],nx,ny);
hy1=readdatavalue([PATH_PREFIX 'hy1.dat'],nx,ny);
hz=readdatavalue([PATH_PREFIX 'hz.dat'],nx,ny);
pbsx=readdatavalue([PATH_PREFIX 'pbsx.dat'],nx,ny);

OnedBsqc=readdatavalue([PATH_PREFIX 'OnedBsqc.dat'],nx+1,ny+1);

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
    if nc2+1 == nc2 && ntt == nc2 % Double null case with active bottom X-point
 % In the top PFR and outer SOL right the array xc contains the
%   distance from outer top target   
        xc(i,ntt+2+1) = hx(i,ntt+2+1)/2;
        x1(i,ntt+2+1) = hx(i,ntt+2+1); 
    else % single null case
        j=ntt+2+1;  
        xc(i,j)=xc(i,j-1)+(hx(i,j)+hx(i,j-1))/2;
        x1(i,j)=x1(i,j-1)+hx(i,j);
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
