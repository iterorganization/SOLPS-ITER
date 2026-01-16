function [gfunr] = gradc_r_us(nCv, nFc, nVx, mode, gmtry, fun, funv)
% [gfunr] = gradc_r_us(nCv, nFc, nVx, mode, gmtry, fun, funv)
%
% Computes the radial gradient of a cell-centered quantity on cell-centers.
%

gfunr=zeros(nCv,1);

if (mode<0 | mode>1)
    error('mode must be 0 or 1')
end

%   ..interpolate fun to cell vertices, using volume weighted averaging
      if (mode==0)
        [funv]= intvertex_us(nVx,mpg,gmtry.vxVol,fun,funv);
      end

%   ..compute gradients on faces
      [gfunrf] = grad_r_us(nFc, nVx, 1, gmtry, fun, funv);

%   ..interpolate to centers
      [gfunr] = intcell_us(nCv, gmtry, gmtry.intcellR, gfunrf);



end