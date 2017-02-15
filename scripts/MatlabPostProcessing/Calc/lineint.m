function int = lineint(gmtry,field,chords,nint)
% int = lineint(gmtry,field,chords,npoints)
%
% Computes the line integral of field along the specified chords.
% Chords is a structure array typically read from a *.chr file, containing
% data on nchord chords.
%
% int is an vector of lenght nchords containing the line integral of field
% along each chord.
% 
% gmtry is either a gmtry-struct (read from a b2fgmtry-file), or a
% triangles-struct (read from fort.33, fort.34, fort.35 files). 
%
% field is assumed to be defined in cell centers (in case of a plasma 
% grid), or in triangle centers (in case of a triangle grid).
%
% nint (optional) specifies the number of intervals used per 
% chord to evaluate the line integral. Default: 1000.
%
% Routine uses quadv for the actual integration.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Set default values for some arguments, if not supplied
if ~exist('nint','var') || isempty(nint)
  nint = 1000;
end

% Initialize output
int = zeros(size(chords.r,1),1);

% Perform integration
t = 0:1/nint:1;

for i = 1:size(chords.r,1)
    
    % 1D function along chord
    rchord = chords.r(i,1)*(1-t) + chords.r(i,2)*t;
    ychord = chords.y(i,1)*(1-t) + chords.y(i,2)*t;
    zchord = chords.z(i,1)*(1-t) + chords.z(i,2)*t;
    
    % Rotate back to the poloidal plane (assuming toroidal symmetry)
    rchordp = (rchord.^2 + ychord.^2).^0.5;
    
    % Evaluate field along the chord
    f = interpolate(gmtry,field,rchordp,zchord);
    
    % Integrate along chord segment, simple Simpson rule
    dx = sqrt((chords.r(i,1) - chords.r(i,2))^2 + ...
              (chords.y(i,1) - chords.y(i,2))^2 + ...
              (chords.z(i,1) - chords.z(i,2))^2)/nint;
    int(i) = 0.5*sum(f(1:end-1) + f(2:end))*dx; 
end

