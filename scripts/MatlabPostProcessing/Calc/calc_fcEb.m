function [gmtry] = calc_fcEb(gmtry)
% [gmtry] = calc_fcEb(gmtry)
%
% Function to compute unit vectors of B components on faces
% and add them to the b2fgmtry structure. Toroidal field sign also added.
% Based on a script by Stefano Carli.
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% August 2025

gmtry.fcEb = zeros(gmtry.nFc,3);

for iFc = 1:gmtry.nFc
        % Construct unit vector normal to face
        dux =   gmtry.vxY(gmtry.fcVx(iFc,2))-gmtry.vxY(gmtry.fcVx(iFc,1));
        duy = -(gmtry.vxX(gmtry.fcVx(iFc,2))-gmtry.vxX(gmtry.fcVx(iFc,1)));

        % Normalize
        du  = sqrt(dux^2+duy^2);
        dux = dux/du;
        duy = duy/du;

        % Sign of toroidal field (1: out of page; -1: into page)
        sbf = 1.0*sign(gmtry.fcQalf(iFc,1)*gmtry.fcQbet(iFc,1) -...
                gmtry.fcQalf(iFc,2)*gmtry.fcQbet(iFc,2));

        % Rotate over angle -alpha; scale with poloidal pitch
        gmtry.fcEb(iFc,1) = gmtry.fcBb(iFc,1)/gmtry.fcBb(iFc,4)*...
                            (     gmtry.fcQalf(iFc,1)*dux + sbf*gmtry.fcQalf(iFc,2)*duy);
        gmtry.fcEb(iFc,2) = gmtry.fcBb(iFc,1)/gmtry.fcBb(iFc,4)*...
                            (-sbf*gmtry.fcQalf(iFc,2)*dux +     gmtry.fcQalf(iFc,1)*duy);
        gmtry.fcEb(iFc,3) = sbf*gmtry.fcBb(iFc,3)/gmtry.fcBb(iFc,4);

        % Normalize
        du = sqrt(gmtry.fcEb(iFc,1)^2 + gmtry.fcEb(iFc,2)^2 + gmtry.fcEb(iFc,3)^2);
        gmtry.fcEb(iFc,1) = gmtry.fcEb(iFc,1)/du;
        gmtry.fcEb(iFc,2) = gmtry.fcEb(iFc,2)/du;
end

gmtry.sbf = sbf;


end