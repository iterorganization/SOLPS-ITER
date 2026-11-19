%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balpot plots the balance of the potential equation (continuity of the        %
% electric current) for a given SOLPS simulation. The currents are the parts   %
% of the total current of B2.5, the sources the parts of its charge source,    %
% and the residual is respo, all as written to balance.nc. The currents and    %
% sources are those from which B2.5 computes respo.                            %
% balfile:     Full path to balance.nc file                                    %
% indrad:      Logical matrix of size nCv that is true for cells where radial  %
%              balance should be performed                                     %
% indpol:      Logical matrix of size nCv that is true for cells where         %
%              poloidal balance should be performed                            %
% facesup:     List of faces of the upstream boundary of indrad                %
% facesdown:   List of faces of the downstream boundary of indrad              %
% facesup_pol: List of faces of the upstream boundary of indpol                %
% facesdown_pol: List of faces of the downstream boundary of indpol            %
% comuse:      Structure containing commonly-used variables (from get_comuse)  %
% axbal:       Array of axes into which balance plots will be placed           %
% reverse:     True if the right-most end of the balance volume is upstream of %
%              the left-most end, otherwise false                              %
% makeplot:    Decides whether to make plots or just pass back the values in   %
%              the radial balance plots                                        %
% areaend:     Either 'left', 'right' or 'none'. Defines the poloidal end      %
%              of the balance region at which areas will be calculated. The    %
%              poloidal fluxes at both ends will then be divided by these      %
%              areas to give flux densities.                                   %
% area_divide: The area that poloidal fluxes and sources are divided by        %
% areatype:    The type of area that poloidal fluxes are divided by            %
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function btn = balpot(balfile,indrad,indpol,facesup,facesdown,facesup_pol,...
    facesdown_pol,comuse,axbal,reverse,makeplot,areaend,area_divide,...
    areatype,polbaldist)

% Shorthand for geometry variables:
nCv = comuse.nCv;
nFc = comuse.nFc;

info = ncinfo(balfile);
if ~any(strcmp({info.Variables.Name},'respo'))
    error(['%s has no terms of the potential equation (written by an ',...
        'older B2.5).'],balfile);
end

%% Obtain required arrays from the simulation...
% Currents (their sum is the total current of B2.5):
fname = {'fch_p','fch_in','fch_dia','fch_vispar','fch_visper',...
    'fch_visq','fch_inert','fch_anml','fch_viskt'};
fluxname = {'parallel (fch\_p)','ion-neutral (fch\_in)',...
    'diamagnetic (fch\_dia)','par. viscosity (fch\_vispar)',...
    'perp. viscosity (fch\_visper)','heat flux viscosity (fch\_visq)',...
    'inertia (fch\_inert)','anomalous (fch\_anml)',...
    'Reynolds stress (fch\_viskt)'};
nf = numel(fname);
fchx = zeros(nFc,nf);
fchy = zeros(nFc,nf);
for k = 1:nf
    tmp = ncread(balfile,fname{k});
    fchx(:,k) = tmp(:,1);
    fchy(:,k) = tmp(:,2);
end
% Charge sources (their sum is the charge source of B2.5):
sname = {'b2stbc_sch_bal','b2stbm_sch_bal','ext_sch_bal',...
    'b2srdt_sch_bal','b2srst_sch_bal'};
srcname = {'b2stbc','b2stbm','external source','b2srdt','b2srst'};
sch = zeros(nCv,numel(sname));
for k = 1:numel(sname)
    sch(:,k) = ncread(balfile,sname{k});
end
% Residual:
respo = ncread(balfile,'respo');
%%

%% Create the units string
switch areatype
    case {'parallel','contact'}
        units = 'Am^{-2}';
    case 'none'
        units = 'A';
    otherwise
        error('Area type ''%s'' not supported.',areatype);
end
%%

%% Calculate the total current depending on areatype
switch areatype
    case 'parallel' % Retain only the poloidal component
        fch = fchx;
    otherwise % Poloidal + radial component
        fch = fchx + fchy;
end

%% Calculate the radial divergences...
divrad = zeros(nCv,nf);
divpol = zeros(nCv,nf);
for k = 1:nf
    % Radial balance
    divrad(:,k) = raddiv(fchx(:,k),fchy(:,k),comuse,facesup,facesdown,...
        areatype);
    % Poloidal balance
    divpol(:,k) = raddiv(fchx(:,k),fchy(:,k),comuse,[],[],areatype);
end
divname = strcat({'rad. diverg. '},fluxname);

%% Make plots...
btn = radial_balance(fch,[divrad,sch],respo,...
 {'total upstream current',...
  'total downstream current',...
  'total poloidally-integrated source',...
  'poloidally-integrated residual'},...
 fluxname,[divname,srcname],...
 comuse,indrad,facesup,facesdown,area_divide,reverse,false,axbal(1:4),...
 units,makeplot,areaend);

if ~makeplot
    return
end

poloidal_balance(fch,[divpol,sch],respo,...
 {'total radially-integrated current',...
  'total radially-integrated source',...
  'radially-integrated residual'},...
 fluxname,[divname,srcname],...
 comuse,indpol,facesup_pol,facesdown_pol,area_divide,reverse,false,...
 axbal(5:7),units,areaend,polbaldist);
%%
end
