%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balscript controls the balance routines. The variables SIMID, BAL_QUANT,     %
% SPECIES_INDEX, DEFAULT_REGION and STRATA_PLOT should be set by the user. If  %
% a non-default region is required then this must also be set in               %
% user_set_region.                                                             %
% BALFILE:        Full path to the balance.nc file created by SOLPS-ITER with  %
%                 balance_netcdf set non-zero in b2mn.dat.                     %
% BAL_QUANT:      Either 'particles','momentum','totpress','elheat','ionheat', %  
%                 'totheat'.                                                   %
% SPECIES_INDEX:  An array specifying the species indeces to be summed over.   %
%                 Has length 1 for a single species. Only applicable to        %
%                 'particles' and 'momentum' balances.                         %
% DEFAULT_REGION: Either 'lis' (lower inner SOL), 'uis' (upper inner SOL),     %
%                 'uos', (upper outer SOL), 'los' (lower outer SOL). If 's' is %
%                 replaced by 'd' then the PFR region is also plotted. Any     %
%                 other string will mean that the region is set by the user in %
%                 user_set_region.                                             %
% STRATA_PLOT:    If true then divide the EIRENE source into components from   %
%                 each stratum (in a new figure).                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BALFILE = '/home/david/remote/toks/ptmp1/scratch/dmoulton/solps-iter/runs/mastu_eq5/ref_balancetest/b2mn.exe.dir/balance.nc';
BALFILE = '/tmp/balance.nc';
BAL_QUANT = 'totheat';
SPECIES_INDEX = 2;
DEFAULT_REGION = 'lod';
STRATA_PLOT = true;

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
end

% Plot the grid showing where balance will be performed:
balgrid(comuse,indrad,indpol,axgrid,reverse);

% Plot balance of the required quantity
switch BAL_QUANT
    case 'particles'
        balpart(BALFILE,indrad,indpol,SPECIES_INDEX,comuse,axbal,reverse,STRATA_PLOT,axstrat);
    case 'momentum'
        balmom(BALFILE,indrad,indpol,SPECIES_INDEX,comuse,axbal,reverse,STRATA_PLOT,axstrat);
    case 'totpress'
        baltotpress(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat);
    case 'elheat'
        baleht(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat);
    case 'ionheat'
        baliht(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat);
    case 'totheat'
        baltotht(BALFILE,indrad,indpol,comuse,axbal,reverse,STRATA_PLOT,axstrat);
    otherwise
        error('Balance quantity ''%s'' not supported.',BAL_QUANT);
end
