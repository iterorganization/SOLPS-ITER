%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% user_set_region allows the user to set their own logical grids for indrad    %
% and indpol in order to plot balance in any region.                           %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indrad,indpol,reverse,facesup,facesdown,facesup_pol,facesdown_pol] = user_set_region(comuse)

indrad = false(comuse.nCv,1);
indpol = false(comuse.nCv,1);

for iCv = 1:comuse.nCi
    if (comuse.cvReg(iCv) == 2) || (comuse.cvReg(iCv) == 6)
        indrad(iCv) = true;
    elseif (comuse.cvReg(iCv) == 3) || (comuse.cvReg(iCv) == 4) || ...
            (comuse.cvReg(iCv) == 7) || (comuse.cvReg(iCv) == 8) 
        iFt = comuse.cvFt(iCv);
        iFt1 = comuse.ftCvP(iFt,1);
        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2) || ...
            any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
            indrad(iCv) = true;
        end
    end
end

% Find the flux tube in the PF region adjacent to the separatrix
found = false;
for iCv = 1:comuse.nCi
    if (comuse.cvReg(iCv) == 3) || (comuse.cvReg(iCv) == 4) || ...
            (comuse.cvReg(iCv) == 7) || (comuse.cvReg(iCv) == 8)
        iFt = comuse.cvFt(iCv);
        iFt1 = comuse.ftCvP(iFt,1);
        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2) || ...
            any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
            % Do nothing ==> part of SOL
        else
            for i = 1:comuse.cvFcP(iCv,2)
                iFc = comuse.cvFc(comuse.cvFcP(iCv,1)+i-1);
                if comuse.fcCv(iFc,1) ~= iCv
                    iCv2 = comuse.fcCv(iFc,1);
                else
                    iCv2 = comuse.fcCv(iFc,2);
                end
                iFt2 = comuse.cvFt(iCv2);
                if iFt2 == comuse.ftSep(1)
                    found = true;
                    break;
                end
            end
        end
    end
    if found
        break;
    end
end
iFt_old = iFt;

% Find the flux tube in the PF region adjacent to iFt_old
found = false;
for iCv = 1:comuse.nCi
    if (comuse.cvReg(iCv) == 3) || (comuse.cvReg(iCv) == 4) || ...
            (comuse.cvReg(iCv) == 7) || (comuse.cvReg(iCv) == 8)
        iFt = comuse.cvFt(iCv);
        iFt1 = comuse.ftCvP(iFt,1);
        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2) || ...
            any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
            % Do nothing ==> part of SOL
        else
            for i = 1:comuse.cvFcP(iCv,2)
                iFc = comuse.cvFc(comuse.cvFcP(iCv,1)+i-1);
                if comuse.fcCv(iFc,1) ~= iCv
                    iCv2 = comuse.fcCv(iFc,1);
                else
                    iCv2 = comuse.fcCv(iFc,2);
                end
                iFt2 = comuse.cvFt(iCv2);
                if iFt2 == iFt_old
                    found = true;
                    break;
                end
            end
        end
    end
    if found
        break;
    end
end

% Set indpol
iFt1 = comuse.ftCvP(iFt,1);
iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
indpol(comuse.ftCv(iFt1:iFt2)) = true;

% Set guard cells to zero
indpol(comuse.nCi+1:end) = false;

% Determine the faces of the upstream and downstream boundary of indrad and
% indpol: the two ends of the flux tubes, i.e. faces between a cell of the
% region and a guard cell of the same flux tube that the flux tube passes
% through (cosine of alpha non-zero, as B2.5 itself tells them from radial
% faces). The upstream end is the one where the positive poloidal direction
% of B2.5 (the sign of the cosine of alpha, with the face orientation from
% fcCv) enters the region, the downstream end the one where it leaves. On
% classical grids these are the inner and the outer target. This does not
% depend on the face labels, which differ between grids.
[facesup,facesdown] = tube_ends(indrad,comuse);
[facesup_pol,facesdown_pol] = tube_ends(indpol,comuse);

reverse = false;

end

% Faces at the upstream and downstream ends of the flux tubes in ind
function [facesup,facesdown] = tube_ends(ind,comuse)
facesup = [];
facesdown = [];
for iFc = 1:comuse.nFc
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if xor(ind(iCv1),ind(iCv2))
        if ind(iCv1)
            iCvin = iCv1;
            iCvout = iCv2;
        else
            iCvin = iCv2;
            iCvout = iCv1;
        end
        if (iCvout > comuse.nCi) && (comuse.fcQalf(iFc,1) ~= 0)
            if (iCvin == comuse.fcCv(iFc,2)) == (comuse.fcQalf(iFc,1) > 0)
                facesup = [facesup,iFc];
            else
                facesdown = [facesdown,iFc];
            end
        end
    end
end
end
