function div = div(gmtry,flow)
% div = div(gmtry,flow)
%
% Computes the divergence of a B2.5 flow field flow. 
% It is assumed that flow is defined on cell faces.
% The output is a cell centered quantity.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016


disp('div -- warning: assuming version 03.001.001')

% Some local variables
nx  = size(flow,1) - 2;
ny  = size(flow,2) - 2;
ns  = size(flow,5);

% Initialize output
div = zeros(nx+2,ny+2,ns);

% Compute divergence
for is = 1:ns
    % Contributions from left and bottom neighbors
    div(:,:,is) = -flow(:,:,1,1,is) - flow(:,:,1,2,is) - ...
                   flow(:,:,2,1,is) - flow(:,:,2,2,is);
    
    for iy = 1:ny+2
        for ix = 1:nx+2
            % Contributions from right neighbors
            if gmtry.rightix(ix,iy) ~= nx+1
                div(ix,iy,is) = div(ix,iy,is) + ...
                    flow(gmtry.rightix(ix,iy)+2,gmtry.rightiy(ix,iy)+2,1,1,is) + ...
                    flow(gmtry.rightix(ix,iy)+2,gmtry.rightiy(ix,iy)+2,1,2,is);
            end
            % Contributions from top neighbors
            if gmtry.topiy(ix,iy) ~= ny+1
                div(ix,iy,is) = div(ix,iy,is) + ...
                    flow(gmtry.topix(ix,iy)+2,gmtry.topiy(ix,iy)+2,2,1,is) + ...
                    flow(gmtry.topix(ix,iy)+2,gmtry.topiy(ix,iy)+2,2,2,is);
            end
        end
    end
end
