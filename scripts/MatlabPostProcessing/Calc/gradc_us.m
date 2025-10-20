function [gfun] = gradc_us(gmtry,mode,fun,volstyle)
% [gfun] = gradc_us(gmtry,mode,fun,volstyle)
%
% Computes the gradient of cell-centered quantity on cell-centers; the
% poloidal component gfun(:,1) and the radial component gfun(:,2) are
% returned.
%

nCv = gmtry.nCv;
nFc = gmtry.nFc;
nVx = gmtry.nVx;

% initialize output
gfun = zeros(nCv,2);
if (mode<0 || mode>1)
    error('mode must be 0 or 1')
end

%   ..interpolate fun to cell vertices, using volume weighted averaging
if (mode==0)
    vxVol = calc_vxVol(nVx,gmtry,volstyle);
    [funv] = intvertex_us(nVx,gmtry,vxVol,fun);
end

%   ..compute poloidal and radial gradients
[gfun(:,1)]=gradc_p_us(nCv, nFc, nVx, 1, gmtry, fun, funv);
[gfun(:,2)]=gradc_r_us(nCv, nFc, nVx, 1, gmtry, fun, funv);
end