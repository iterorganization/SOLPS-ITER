function p_out = convert_to_flux_density(p_in,gmtry)
% p_out = convert_to_flux_density(p_in,gmtry)
%
% Routine to convert the fluxes in a plasma state to fluxes per unit area.
%
% Input arguments:
%
% - p_in     : plasma state from b2fplasmf
% - gmtry    : geometry from b2fgmtry
%
% Output arguments:
%
% - p_out    : plasma state with fluxes per unit area
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% January 2026

% Collecting plasma state field
fields = fieldnames(p_in);

nCv = gmtry.nCv;
nFc = gmtry.nFc;

for i = 1:numel(fields)

    fname = fields{i};
    val   = p_in.(fname);
    
    if size(val,1) == nCv
        p_out.(fname) = val;
    elseif size(val,1) == nFc && size(val,2) ~= 1
        p_out.(fname) = val./gmtry.fcS;
    end

end

end