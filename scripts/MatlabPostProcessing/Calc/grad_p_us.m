function [gfunp] = grad_p_us(nFc, nVx, mode, gmtry, fun, funv)
% [gfunp] = grad_p_us(nFc, nVx, mode, gmtry, fun, funv)
%
% Computes the poloidal gradient of a quantity on cell faces.
%

gfunp = zeros(nFc,1);

if (mode<0 | mode>1)
    error('mode must be 0 or 1')
end

if (mode==0)
    [funv] = intvertex_us(nVx,gmtry,gmtry.vxVol,fun,funv);
end

%   ..compute poloidal gradients at faces
      for iFc = 1:nFc
       gfunp(iFc) = ...
       (fun(gmtry.fcCv(iFc,2))  - fun(gmtry.fcCv(iFc,1)))*gmtry.fcQalf(iFc,1)/(gmtry.fcQgam(iFc,1)*(gmtry.fcHc(iFc,1) + gmtry.fcHc(iFc,2))) + ...
       (funv(gmtry.fcVx(iFc,2)) - funv(gmtry.fcVx(iFc,1)))*gmtry.fcQbet(iFc,2)/(gmtry.fcQgam(iFc,1)*gmtry.fcHt(iFc));
      end
end
