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


if isfield(gmtry,'nCv')
    
    % Some local variables
    ns  = size(flow,3);
    nFc = size(flow,1);
    
    % Initialize output
    div = zeros(gmtry.nCv,ns);
    
    % Compute divergence
    for is = 1:ns
        for iFc = 1:nFc
            iCv1 = gmtry.fcCv(iFc,1);
            iCv2 = gmtry.fcCv(iFc,2);
            
            div(iCv1,is) = div(iCv1,is) + flow(iFc,1,is) + flow(iFc,2,is);
            div(iCv2,is) = div(iCv2,is) - flow(iFc,1,is) - flow(iFc,2,is);
        end
    end

    div(gmtry.nCi+1:end,:) = 0;
else
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
end
