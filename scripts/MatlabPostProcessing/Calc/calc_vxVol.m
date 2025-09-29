function [vxVol] = calc_vxVol(nVx,gmtry,mode)
% [vxVol] = calc_vxVol(nVx,gmtry,mode)
%
% Computes the volume of cells.
%

if (mode==0) 
       % weights for inverse volume interpolation
       for iVx = 1: nVx
        for inCv = 1: gmtry.vxCvP(iVx,2)
         iCv = gmtry.vxCv(gmtry.vxCvP(iVx,1) + inCv - 1);
         vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = ...
           (1./gmtry.cvVxP(iCv,2))*gmtry.cvVol(iCv);
        end
       end
       elseif (mode==1)
       % weights based on relative volume fraction
       for iVx = 1: nVx
        for inCv = 1: gmtry.vxCvP(iVx,2)
         iCv = gmtry.vxCv(gmtry.vxCvP(iVx,1) + inCv - 1);
         if (iCv<=gmtry.nCi)
          vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = 1./gmtry.cvVxP(iCv,2);
         else
          % Make sure guard cells forminate in the interpolation
          % to vertices => use volume
          vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = ...
            (1./gmtry.cvVxP(iCv,2))*gmtry.cvVol(iCv);
         end
        end
       end
      elseif (mode==2)
      % assign 1/4, except guard cells
       for iVx = 1: nVx
        for inCv = 1: gmtry.vxCvP(iVx,2)
         iCv = gmtry.vxCv(gmtry.vxCvP(iVx,1) + inCv - 1);
         if (iCv<=gmtry.nCi)
          vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = 0.25; % !ap should this be changed if cell is e.g. triangle?
         else
          % Make sure guard cells forminate in the interpolation
          % to vertices => use volume
          vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = 0.25e-3;
         end
        end 
       end 
else 
        error('wrong value of b2mndr_vxVol_style')
end 