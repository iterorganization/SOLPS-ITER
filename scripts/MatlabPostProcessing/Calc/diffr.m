function dfieldr = diffr(gmtry,field)
% dfieldr = diffr(gmtry,field)
%
% Compute the radial difference of a cell centered field, at both x and y 
% surfaces. Takes into account grid distortion (9-point stencil)
% 
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016


% Some local variables
nx  = size(field,1) - 2;
ny  = size(field,2) - 2;

% Initialize output
dfieldr = zeros(nx+2,ny+2,2);

% Interpolate field to cell corners
fieldc = intcor(gmtry,field,'vol');

% Translate neighbor indices to Matlab numbering
tix = gmtry.topix+2;
tiy = gmtry.topiy+2;
lix = gmtry.leftix+2;
liy = gmtry.leftiy+2;
rix = gmtry.rightix+2;
riy = gmtry.rightiy+2;
bix = gmtry.bottomix+2;
biy = gmtry.bottomiy+2;

% Interpolate qz(:,:,1) to x-faces
qzf = intface(gmtry,gmtry.qz(:,:,1),1,'vol');

% Compute radial difference at x-faces
for iy = 1:ny+2
    for ix = 1:nx+2
        if (gmtry.leftix(ix,iy)   ~= -2 && ...
            gmtry.bottomiy(ix,iy) ~= -2 && ...
            gmtry.topiy(ix,iy)    ~= ny+1)
        
            dfieldr(ix,iy,1) = ...
                fieldc(tix(ix,iy),tiy(ix,iy)) - fieldc(ix,iy) - ...         % contribution from y-direction
                (field(ix,iy) - field(lix(ix,iy),liy(ix,iy)))* ...          % contribution from x-direction (non-orthogonal grids)
                (gmtry.hy(ix,iy) + gmtry.hy(lix(ix,iy),liy(ix,iy)))/ ...
                (gmtry.hx(ix,iy) + gmtry.hx(lix(ix,iy),liy(ix,iy)))*...
                qzf(ix,iy);
        end
    end
end

% Interpolate qz(:,:,1) to y-faces
qzf = intface(gmtry,gmtry.qz(:,:,1),2,'vol');

% Compute radial differences at y-faces
for iy = 1:ny+2
    for ix = 1:nx+2
        if (gmtry.leftix(ix,iy)   ~= -2 && ...
            gmtry.rightix(ix,iy)  ~= nx+1 && ...
            gmtry.bottomiy(ix,iy) ~= -2)
            
            dfieldr(ix,iy,2) = ...
                field(ix,iy) - field(bix(ix,iy),biy(ix,iy)) -  ...         % contribution from y-direction
                (fieldc(rix(ix,iy),riy(ix,iy)) - fieldc(ix,iy))*  ...       % contribution from x-direction (non-orthogonal grids)
                (gmtry.hy(ix,iy) + gmtry.hy(bix(ix,iy),biy(ix,iy)))/...
                (gmtry.hx(ix,iy) + gmtry.hx(bix(ix,iy),biy(ix,iy)))*...
                qzf(ix,iy);
        end
    end
end



