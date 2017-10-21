function fieldI = intcor(gmtry,field,meth)
% fieldI = intcor(gmtry,field,meth)
%
% Interpolate a cell centered field to cell corners. Only volume weighted
% interpolation is implemented for now.
% 
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
        
            
            lix = gmtry.leftix+2;
            liy = gmtry.leftiy+2;
            
            bix = gmtry.bottomix+2;
            biy = gmtry.bottomiy+2;
            
            for iy = 2:ny+2
                for ix = 2:nx+2
                    fieldI(ix,iy) = ...
                        (vol(ix,iy)*field(bix(lix(ix,iy),liy(ix,iy)),biy(lix(ix,iy),liy(ix,iy))) + ...
                         vol(bix(lix(ix,iy),liy(ix,iy)),biy(lix(ix,iy),liy(ix,iy)))*field(ix,iy) + ...
                         vol(lix(ix,iy),liy(ix,iy))*field(bix(ix,iy),biy(ix,iy)) + ...
                         vol(bix(ix,iy),biy(ix,iy))*field(lix(ix,iy),liy(ix,iy)))/...
                        (vol(ix,iy) + vol(lix(ix,iy),liy(ix,iy)) + vol(bix(ix,iy),biy(ix,iy)) + ...
                         vol(bix(lix(ix,iy),liy(ix,iy)),biy(lix(ix,iy),liy(ix,iy))));
                end
            end

            % todo: treatment of x-points
            
    otherwise
        
        error('intface -- unknown value of meth.');
        
end


