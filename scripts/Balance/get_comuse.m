%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_comuse gets commonly used variables for a simulation and puts them in a  %
% single structure. By calling functions with this structure this function     %
% works similarly to a module in fortran.                                      %
% The variable ftSep has been added to comuse and contains the flux tube       %
% number(s) of the flux tubes in the SOL adjacent to the separatrix.           %
% The variable ftSeppf contains the flux tube number(s) of the flux tubes in   %
% the PF adjacent to the separatrix.                                           %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function comuse = get_comuse(filename)

% Obtain dimensions from netcdf file:
finfo = ncinfo(filename);
dimNames = {finfo.Dimensions.Name};
dimMatch = strcmp(dimNames,'nCv');
comuse.nCv = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nCi');
comuse.nCi = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nFc');
comuse.nFc = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nVx');
comuse.nVx = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nFt');
comuse.nFt = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nCmxFc');
comuse.nCmxFc = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nCmxVx');
comuse.nCmxVx = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'ns');
comuse.ns = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nstra');
comuse.nstra = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nXpt');
comuse.nXpt = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nimp');
comuse.nimp = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nomp');
comuse.nomp = finfo.Dimensions(dimMatch).Length;
% Get grid information:
comuse.cvX = ncread(filename,'cvX');
comuse.cvY = ncread(filename,'cvY');
comuse.cvHx = ncread(filename,'cvHx');
comuse.cvHz = ncread(filename,'cvHz');
comuse.vxX = ncread(filename,'vxX');
comuse.vxY = ncread(filename,'vxY');
comuse.cvFc = ncread(filename,'cvFc');
comuse.cvFcP = ncread(filename,'cvFcP');
comuse.cvVx = ncread(filename,'cvVx');
comuse.cvVxP = ncread(filename,'cvVxP');
comuse.fcCv = ncread(filename,'fcCv');
comuse.fcVx = ncread(filename,'fcVx');
% Face areas and angles
comuse.fcS = ncread(filename,'fcS');
comuse.fcHz = ncread(filename,'fcHz');
comuse.fcQalf = ncread(filename,'fcQalf');
% Face labels
comuse.fcLbl = ncread(filename,'fcLbl');
% Magnetic field
comuse.cvBb = ncread(filename,'cvBb');
comuse.cvEb = ncread(filename,'cvEb');
comuse.fcBb = ncread(filename,'fcBb');
% Magnetic psi
comuse.vxFpsi = ncread(filename,'vxFpsi');
% Regions, flux tubes, imp and omp:
comuse.cvReg = ncread(filename,'cvReg');
comuse.cvFt = ncread(filename,'cvFt');
comuse.ftCv = ncread(filename,'ftCv');
comuse.ftCvP = ncread(filename,'ftCvP');
comuse.imp = ncread(filename,'imp');
comuse.omp = ncread(filename,'omp');
% Cell volumes
comuse.cvVol = ncread(filename,'cvVol');
% Species string:
tmp = ncread(filename,'species');
comuse.species = {};
for i=1:comuse.ns
    comuse.species{i} = strtrim(tmp(:,i)');
end
% b2mndr_eirene:
comuse.b2mndr_eirene = ncread(filename,'b2mndr_eirene');
% b2mndr_hz:
comuse.b2mndr_hz = ncread(filename,'b2mndr_hz');
% za:
comuse.za = ncread(filename,'za');
% am, mp, ev:
comuse.am = ncread(filename,'am');
comuse.mp = ncread(filename,'mp');
comuse.ev = ncread(filename,'ev');
% Set plotting colormap:
comuse.cmap = ([0.0000    0.4470    0.7410;...
                0.8500    0.3250    0.0980;...
                0.9290    0.6940    0.1250;...
                0.4940    0.1840    0.5560;...
                0.4660    0.6740    0.1880;...
                0.3010    0.7450    0.9330;...
                0.6350    0.0780    0.1840]);

% Find flux tubes in SOL near separatrix
if comuse.nXpt == 1 
    for i = 1:comuse.nomp
        if ((comuse.cvReg(comuse.omp(i)) == 2) || ...
                (comuse.cvReg(comuse.omp(i)) == 6))
            comuse.ftSep = comuse.cvFt(comuse.omp(i));
            break;
        end
    end
elseif comuse.nXpt == 2
    warning('Only connected double null is supported')
    comuse.ftSep = zeros(2,1);
    for i = 1:comuse.nimp
        if (comuse.cvReg(comuse.imp(i)) == 2)
            comuse.ftSep(1) = comuse.cvFt(comuse.imp(i));
            break;
        end
    end
    for i = 1:comuse.nomp
        if (comuse.cvReg(comuse.omp(i)) == 6)
            comuse.ftSep(2) = comuse.cvFt(comuse.omp(i));
            break;
        end
    end
elseif comuse.nXpt == 0
    for i = 1:comuse.nomp
        if (comuse.cvReg(comuse.omp(i) == 2))
            comuse.ftSep = comuse.cvFt(comuse.omp(i));
            break;
        end
    end
end

% Find flux tubes in PF near separatrix
if comuse.nXpt == 1 
    found = false;
    for iFt = 1:comuse.nFt
        iCv1 = comuse.ftCvP(iFt,1);
        iCv2 = iCv1 + comuse.ftCvP(iFt,2) - 1;
        if any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 1) || ...
            any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 2) || ...
            any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 5) || ...
            any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 6) 
            % Flux tube not in PF ==> do nothing
        else
            for i = iCv1:iCv2
                iCv = comuse.ftCv(i);
                iFc1 = comuse.cvFcP(iCv,1);
                iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
                for j = iFc1:iFc2
                    iFc = comuse.cvFc(j);
                    if (comuse.cvFt(comuse.fcCv(iFc,1)) == comuse.ftSep) || ...
                        (comuse.cvFt(comuse.fcCv(iFc,2)) == comuse.ftSep)
                        found = true;
                        break;
                    end
                end
                if found
                    break;
                end
            end
        end
        if found
            break;
        end
    end
    comuse.ftSeppf = iFt;
elseif comuse.nXpt == 2
    found = false;
    comuse.ftSeppf = zeros(2,1);
    for iFt = 1:comuse.nFt
        iCv1 = comuse.ftCvP(iFt,1);
        iCv2 = iCv1 + comuse.ftCvP(iFt,2) - 1;
        if any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 1) || ...
            any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 2) || ...
            any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 5) || ...
            any(comuse.cvReg(comuse.ftCv(iCv1:iCv2)) == 6) 
            % Flux tube not in PF ==> do nothing
        else
            for i = iCv1:iCv2
                iCv = comuse.ftCv(i);
                iFc1 = comuse.cvFcP(iCv,1);
                iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
                for j = iFc1:iFc2
                    iFc = comuse.cvFc(j);
                    if (comuse.cvFt(comuse.fcCv(iFc,1)) == comuse.ftSep(1)) || ...
                       (comuse.cvFt(comuse.fcCv(iFc,1)) == comuse.ftSep(2)) || ...
                        (comuse.cvFt(comuse.fcCv(iFc,2)) == comuse.ftSep(1)) || ...
                        (comuse.cvFt(comuse.fcCv(iFc,2)) == comuse.ftSep(2))
                        found = true;
                        break;
                    end
                end
                if found
                    break;
                end
            end
        end
        if found
            if (comuse.cvReg(iCv) == 3) || (comuse.cvReg(iCv) == 8)
                comuse.ftSeppf(1) = iFt;
            else
                comuse.ftSeppf(2) = iFt;
            end
            found = false;
        end
    end
elseif comuse.nXpt == 0
    for i = 1:comuse.nomp
        if (comuse.cvFt(comuse.omp(i)) == comuse.ftSep)
            break;
        end
    end
    comuse.ftSeppf = comuse.cvFt(comuse.omp(i-1));
end






