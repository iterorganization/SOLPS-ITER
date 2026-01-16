function [gfunp] = gradc_p_us(nCv, nFc, nVx, mode, gmtry, fun, funv)
% [gfunp] = gradc_p_us(nCv, nFc, nVx, mode, gmtry, fun, funv)
%
% Computes the poloidal gradient of a cell-centered quantity on
% cell-centers.
%
gfunp=zeros(nCv,1);

if (mode<0 | mode>1)
    error('mode must be 0 or 1')
end

%   ..interpolate fun to cell vertices, using volume weighted averaging
      if (mode==0)
        [funv]= intvertex_us(nVx,mpg,gmtry.vxVol,fun,funv);
      end

%   ..compute gradients on faces
      [gfunpf] = grad_p_us(nFc, nVx, 1, gmtry, fun, funv);

%   ..interpolate to centers
      [gfunp] = intcell_us(nCv, gmtry, gmtry.intcellP, gfunpf);



end