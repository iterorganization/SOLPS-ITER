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

% Determine the faces of the upstream and downstream boundary of indrad
facesup = []; % list of faces at the upstream boundary
facesdown = []; % list of faces at the downstream boundary
for iFc = 1:comuse.nFc
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if (indrad(iCv1) && ~indrad(iCv2)) || (~indrad(iCv1) && indrad(iCv2))
        if comuse.fcLbl(iFc) == 1
            facesup = [facesup,iFc];
        elseif comuse.fcLbl(iFc) == 2
            facesdown = [facesdown,iFc];
        end
    end
end

% Determine the faces of the upstream and downstream boundary of indpol
facesup_pol = [];
for i = 1:length(facesup)
    iFc = facesup(i);
    if indpol(comuse.fcCv(iFc,1)) || indpol(comuse.fcCv(iFc,2))
        facesup_pol = [facesup_pol,iFc];
    end
end
facesdown_pol = [];
for i = 1:length(facesdown)
    iFc = facesdown(i);
    if indpol(comuse.fcCv(iFc,1)) || indpol(comuse.fcCv(iFc,2))
        facesdown_pol = [facesdown_pol,iFc];
    end
end

reverse = false;

end