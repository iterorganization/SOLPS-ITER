function [vxVol] = calc_vxVol(nVx,gmtry,vxVol_style)
% [vxVol] = calc_vxVol(nVx,gmtry,mode)
%
% Computes the volume of cells.
%

if (vxVol_style==0) 
    % weights for inverse volume interpolation
    for iVx = 1: nVx
        for inCv = 1: gmtry.vxCvP(iVx,2)
            iCv = gmtry.vxCv(gmtry.vxCvP(iVx,1) + inCv - 1);
            vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = ...
            (1./gmtry.cvVxP(iCv,2))*gmtry.cvVol(iCv);
        end
    end
elseif (vxVol_style==1)
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
elseif (vxVol_style==2)
    % new implementation based on new version of vxVol_style = 2 in SOLPS
    % Anthony Piras, Jan. 2026
    gmtry = compute_cvFpsi(gmtry);
    for iVx = 1: nVx
        count_down = 0;
        count_up   = 0;
        count_eq   = 0;
        for inCv = 1:gmtry.vxCvP(iVx,2)
            iCv = gmtry.vxCv(gmtry.vxCvP(iVx,1) + inCv - 1);
            if (gmtry.cvFpsi(iCv)>gmtry.vxFpsi(iVx))
                count_up = count_up + 1;
            elseif (gmtry.cvFpsi(iCv)<gmtry.vxFpsi(iVx))
                count_down = count_down + 1;
            else
                count_eq = count_eq + 1;
            end
        end
        for inCv = 1:gmtry.vxCvP(iVx,2)
            iCv = gmtry.vxCv(gmtry.vxCvP(iVx,1) + inCv - 1);
            if (iCv<gmtry.nCi)
                if ( gmtry.cvFpsi(iCv)>gmtry.vxFpsi(iVx))
                    vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = 2.0*count_up;
                elseif ( gmtry.cvFpsi(iCv)<gmtry.vxFpsi(iVx))
                    vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = 2.0*count_down;
                else
                    vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = count_eq;
                end
            else
                % Make sure guard cells dominate in the interpolation
                % to vertices => use small number
                vxVol(gmtry.vxCvP(iVx,1) + inCv - 1) = 0.25e-3;
            end
        end
    end
else 
    error('wrong value of vxVol_style')
end

end