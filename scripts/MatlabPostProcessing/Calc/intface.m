function fieldI = intface(gmtry,field,dir,meth)
% fieldI = intface(gmtry,field,dir,meth)
%
% Interpolate a cell centered field to cell faces. Only volume weighted
% interpolation is implemented for now.
% 
% dir = 1: interpolate to "west"  faces
% dir = 2: interpolate to "south" faces
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Initialize output
fieldI = zeros(size(field));


% Some local variables
nx  = size(field,1) - 2;
ny  = size(field,2) - 2;


% Interpolate
switch meth
    
    case 'vol'
        
        vol = gmtry.vol;
        
        if dir == 1
            
            lix = gmtry.leftix+2;
            liy = gmtry.leftiy+2;
            
            for iy = 1:ny+2
                for ix = 2:nx+2
                    if lix(ix,iy) >= 1
                    fieldI(ix,iy) = ...
                        (vol(ix,iy)*field(lix(ix,iy),liy(ix,iy)) + ...
                        vol(lix(ix,iy),liy(ix,iy))*field(ix,iy))/...
                        (vol(ix,iy) + vol(lix(ix,iy),liy(ix,iy)));
                    end
                end
            end
            
        elseif dir == 2
            
            bix = gmtry.bottomix+2;
            biy = gmtry.bottomiy+2;
            
            for iy = 2:ny+2
                for ix = 1:nx+2
                    if biy(ix,iy) >= 1
                    fieldI(ix,iy) = ...
                        (vol(ix,iy)*field(bix(ix,iy),biy(ix,iy)) + ...
                        vol(bix(ix,iy),biy(ix,iy))*field(ix,iy))/...
                        (vol(ix,iy) + vol(bix(ix,iy),biy(ix,iy)));
                    end
                end
            end
        end
        
    otherwise
        
        error('intface -- unknown value of meth.');
        
end


