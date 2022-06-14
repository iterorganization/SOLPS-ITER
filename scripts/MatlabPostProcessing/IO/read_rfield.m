function field = read_rfield(fid,fieldname,dims)
% field = read_rfield(fid,fieldname,dims)
%
% Auxiliary routine to read real fields from B2.5 b2f* files
% 

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Store current position in file
pos  = ftell(fid);

% Search the file until identifier 'fieldname' is found
line = fgetl(fid);
while ~contains(line,fieldname)
    line = fgetl(fid);
    if line == -1
        % Reset position in file
        fseek(fid,pos,'bof');
        break
    end
end


if line == -1
    
    % Entry not found. Fill with zeros.
    disp(['EOF reached without finding ',fieldname,'. Returning zeros.']);
    field = zeros(prod(dims),1);
    
else
    
    % Consistency check: number of elements specified in the file should equal
    % prod(dims)
    numin = strread(line,'%*s %*s %d');
    if numin ~= prod(dims)
        error('read_rfield: inconsistent number of input elements.');
    end
    
    % Read the data
    field = fscanf(fid,'%e',prod(dims));
    
end

% Reshape into desired size
if (length(dims) > 1)
    field = reshape(field,dims);
end
