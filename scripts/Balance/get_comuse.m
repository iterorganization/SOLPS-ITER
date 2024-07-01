%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_comuse gets commonly used variables for a simulation and puts them in a  %
% single structure. By calling functions with this structure this function     %
% works similarly to a module in fortran.                                      %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) June 2024   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function comuse = get_comuse(filename)

% Obtain dimensions from netcdf file
finfo = ncinfo(filename);
dimNames = {finfo.Dimensions.Name};
dimMatch = strcmp(dimNames,'nCv');
comuse.nCv = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nCi');
comuse.nCi = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nFc');
comuse.nFc = finfo.Dimensions(dimMatch).Length;
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
% Regions, flux tubes, imp and omp
comuse.cvReg = ncread(filename,'cvReg');
comuse.cvFt = ncread(filename,'cvFt');
comuse.ftCv = ncread(filename,'ftCv');
comuse.imp = ncread(filename,'imp');
comuse.omp = ncread(filename,'omp');
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






