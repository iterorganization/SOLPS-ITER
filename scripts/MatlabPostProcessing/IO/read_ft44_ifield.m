function field = read_ft44_ifield(fid,dims)
% field = read_ft44_ifield(fid,dims)
%
% Auxiliary routine to read integer fields from fort.44 file
% 
% Todo: adapt for cases with field labels in the fort.44 file
%       (starting fort.44 version 20160829)

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

field = fscanf(fid,'%d',prod(dims));
if (length(dims) > 1)
    field = reshape(field,dims);
end