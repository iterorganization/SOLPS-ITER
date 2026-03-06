function val = isunstructuredgrid(gmtry)
% val = isunstructuredgrid(gmtry)
%
% Function that checks whether the structure gmtry contains the necessary
% fields to be an 'unstructured plasma grid' from B2.5.
%
% For now, the routine simply checks whether the structure contains the
% fields typically needed for the plotting routines. No consistency
% checking on the data is done.
%
% Returns 1 if gmtry is an unstructured plasma grid, 0 otherwise.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

val = 0;
if isfield(gmtry,'cvX') && isfield(gmtry,'cvY')
    val = 1;
end