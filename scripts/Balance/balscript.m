%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balscript controls the balance routines. The variables SIMID, BAL_QUANT,     %
% SPECIES_INDEX, DEFAULT_REGION, STRATA_PLOT and RESACCURACY should be set by  %
% the user. If a non-default region is required then this must also be set in  %
% user_set_region.                                                             %
% SIMID:          Specifier for the simulation of interest. If reading from    %
%                 the MDSPlus server then SHOTID should be an integer          %
%                 specifying the number of the simulation on the MDSPlus       %
%                 server. Otherwise SHOTID should be a string specifying the   %
%                 full path name to the simulation directory.                  %
% BAL_QUANT:      Either 'particles','momentum','totpress','elenergy',         %  
%                 'ionenergy','totenergy'.                                     % 
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
% RESACCURACY:    The maximum acceptable percentage difference between the     %
%                 code-calculated and post-calculated residual that will not   %
%                 throw a warning.                                             %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SIMID = '/home/david/remote/toks/ptmp1/scratch/dmoulton/solps-iter/runs/mastu_eq1/testrun_bceva_balance/';
B2FLOC = [SIMID,'b2fplasma'];
BAL_QUANT = 'totpress';
SPECIES_INDEX = 2;
DEFAULT_REGION = 'uod';
STRATA_PLOT = true;
RESACCURACY = 1E-8;

% If we're reading from a b2fplasma file then read the file into a string once 
% at the start to save time:
if ~isnumeric(SIMID)
    b2fpstr = charfile(B2FLOC);
else
    b2fpstr = '';
end

% Get geometry information for this simulation:
geomb2 = b2getgeom(SIMID,B2FLOC,b2fpstr);
    
% Specify the volumes where radial and poloidal balance is to be performed by
% creating a matrix of size nx*ny which is true inside the volumes:
if ismember(DEFAULT_REGION(1:2),{'li','ui','uo','lo'})
    [indrad,indpol,reverse] = set_region(DEFAULT_REGION,geomb2);
else
    display('Default region not used. Balance region set in user_set_region');
    [indrad,indpol,reverse] = user_set_region(geomb2);
end

% Lay out the window into which plots will go:
[axgrid,axbal] = balfig(BAL_QUANT,SPECIES_INDEX,geomb2);
if STRATA_PLOT
    axstrat = stratfig();
end

% Plot the grid showing where balance will be performed:
balgrid(geomb2,indrad,indpol,axgrid,reverse);

% Plot balance of the required quantity
switch BAL_QUANT
    case 'particles'
        balpart(SIMID,b2fpstr,indrad,indpol,SPECIES_INDEX,geomb2,axbal,reverse,STRATA_PLOT,axstrat,RESACCURACY);
    case 'momentum'
        balmom(SIMID,b2fpstr,indrad,indpol,SPECIES_INDEX,geomb2,axbal,reverse,STRATA_PLOT,axstrat,RESACCURACY);
    case 'totpress'
        baltotpress(SIMID,b2fpstr,indrad,indpol,geomb2,axbal,reverse,STRATA_PLOT,axstrat,RESACCURACY);
    case 'elenergy'
        baleen(SIMID,b2fpstr,indrad,indpol,geomb2,axbal,reverse,STRATA_PLOT,axstrat,RESACCURACY);
    case 'ionenergy'
        balien(SIMID,b2fpstr,indrad,indpol,geomb2,axbal,reverse,STRATA_PLOT,axstrat,RESACCURACY);
    case 'totenergy'
        baltoten(SIMID,b2fpstr,indrad,indpol,geomb2,axbal,reverse,STRATA_PLOT,axstrat,RESACCURACY);
    otherwise
        error('Balance quantity ''%s'' not supported.',BAL_QUANT);
end
