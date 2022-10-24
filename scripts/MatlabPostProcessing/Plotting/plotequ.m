function plotequ(equ,ncont)
% plotequ(equ,ncont)
%
% Routine to plot equilibrium.
% 
% Input arguments:
%
% - equ   : struct read from readrzpsi
% - ncont : number of contours
%
% Output arguments:
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be

% Set default values for some arguments, if not supplied
if ~exist('ncont','var') || isempty(ncont)
    ncont = 100;
end

% Check current status of hold
hs = ishold;

% Make contourfplot
contourf(equ.R,equ.Z,equ.Psi',ncont);

% Reset status of hold
if ~hs, hold off; end

