function field = read_ft44_rfield(fid,ver,fieldname,dims)
% field = read_ft44_rfield(fid,ver,fieldname,dims)
%
% Auxiliary routine to read real fields from fort.44 file
% 

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Verion 20160829: field label and size are specified in fort.44
% Do consistency check on the data
if ver == 20160829
    % Search the file until identifier 'fieldname' is found
    line = fgetl(fid);
    while isempty(strfind(line,fieldname))
        line = fgetl(fid);
        if line == -1
            error(['EOF reached without finding ',fieldname,'.']);
        end
    end
    
    % Consistency check: number of elements specified in the file should equal
    % prod(dims)
    numin = strread(line,'%*s %*s %*s %*s %*s %*s %d');
    if numin ~= prod(dims)
        error('read_ft44_rfield: inconsistent number of input elements.');
    end
end

% Read the data
field = fscanf(fid,'%e',prod(dims));
if (length(dims) > 1)
    field = reshape(field,dims);
end