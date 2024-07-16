%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balscript controls the balance routines. The variables SIMID, BAL_QUANT,     %
% SPECIES_INDEX, DEFAULT_REGION and STRATA_PLOT should be set by the user. If  %
% a non-default region is required then this must also be set in               %
% user_set_region.                                                             %
% BALFILE:        Full path to the balance.nc file created by SOLPS-ITER with  %
%                 balance_netcdf set non-zero in b2mn.dat.                     %
% BAL_QUANT:      Either 'particles','momentum','totpress','elheat','ionheat', %
%                 'totheat'.                                                   %
% SPECIES_INDEX:  An array specifying the species indices to be summed over.   %
%                 Has length 1 for a single species. Only applicable to        %
%                 'particles' and 'momentum' balances.                         %
% DEFAULT_REGION: Either 'lis' (lower inner SOL), 'uis' (upper inner SOL),     %
%                 'uos', (upper outer SOL), 'los' (lower outer SOL). If 's' is %
%                 replaced by 'd' then the PFR region is also plotted. Any     %
%                 other string will mean that the region is set by the user in %
%                 user_set_region.                                             %
% AREAEND:        Either 'left', 'right' or 'none'. Defines the poloidal end   %
%                 of the balance region at which areas will be calculated. The %
%                 poloidal fluxes at both ends will then be divided by these   %
%                 areas to give flux densities.                                %
% AREATYPE:       Either 'parallel' or 'contact'. Defines the type of area     %
%                 that poloidal fluxes are divided by: 'parallel' for the area %
%                 normal to the B field, 'contact' for the area normal to the  %
%                 poloidal end of the cell surface (e.g. the target if the     %
%                 balance region ends at the target)                           %
% POLBALDIST:     Either 'parallel' or 'poloidal'. Defines the distance used   %
%                 on the x-axis of the poloidal balance plots. Distances are   %
%                 mapped to the first SOL ring.                                %
% STRATA_PLOT:    If true then divide the EIRENE source into components from   %
%                 each stratum (in a new figure).                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BALFILE = '../../runs/workshop_yokohama/standard/run/balance.nc';
BAL_QUANT = 'momentum';
SPECIES_INDEX = 7:16;
DEFAULT_REGION = 'user';
AREAEND = 'right';
AREATYPE = 'none';
POLBALDIST = 'parallel';
STRATA_PLOT = false;

% Get commonly used variables for this simulation:
comuse = get_comuse(BALFILE);
    
% Specify the volumes where radial and poloidal balance is to be performed by
% creating a matrix of size nx*ny which is true inside the volumes:
if ismember(DEFAULT_REGION(1:2),{'li','ui','uo','lo'})
    [indrad,indpol,reverse] = set_region(DEFAULT_REGION,comuse);
else
    display('Default region not used. Balance region set in user_set_region');
    [indrad,indpol,reverse] = user_set_region(comuse);
end

% Lay out the window into which plots will go:
[axgrid,axbal] = balfig(BAL_QUANT,SPECIES_INDEX,comuse);
if STRATA_PLOT
    axstrat = stratfig();
else
    axstrat = 0;
end

% Plot the grid showing where balance will be performed:
balgrid(comuse,indrad,indpol,axgrid,reverse);

% Calculate the area which fluxes and sources will be divided by:
area_divide = calc_area(comuse,AREATYPE);

% Plot balance of the required quantity
switch BAL_QUANT
    case 'particles'
        balpart(BALFILE,indrad,indpol,SPECIES_INDEX,comuse,axbal,reverse,STRATA_PLOT,axstrat,true,AREAEND,area_divide,AREATYPE,POLBALDIST);
    case 'momentum'
        balmom(BALFILE,indrad,indpol,SPECIES_INDEX,comuse,axbal,reverse,STRATA_PLOT,axstrat,true,AREAEND,area_divide,AREATYPE,POLBALDIST);
    case 'totpress'
        warning('Use total pressure balance with caution. Balance not currently perfect.');
        baltotpress(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat,true,POLBALDIST);
    case 'elheat'
        baleht(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat,AREAEND,area_divide,AREATYPE,POLBALDIST);
    case 'ionheat'
        baliht(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat,AREAEND,area_divide,AREATYPE,POLBALDIST);
    case 'totheat'
        baltotht(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat,true,AREAEND,area_divide,AREATYPE,POLBALDIST);
    case 'toten'
        warning('Use total energy balance with caution. Balance not currently perfect.');
        baltoten(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat,true,AREAEND,area_divide,AREATYPE,POLBALDIST);
    otherwise
        error('Balance quantity ''%s'' not supported.',BAL_QUANT);
end
