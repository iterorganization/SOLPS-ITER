function gmtry = read_b2fgmtry(file)
% gmtry = read_b2fgmtry(file)
%
% Read b2fgmtry file created by B2.5.
%
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% March 2025

fprintf('\n')

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


% Get version of the b2fgmtry file

line    = fgetl(fid);
version = line(8:17);

disp(['read_b2fgmtry -- file version ',version]);
line = fgetl(fid);

% Geometry is in structured format
flag = strfind(line,'nx');
if isempty(flag) == 0
    fclose(fid);
    gmtry = read_b2fgmtry_st(file);
    return
end

% Geometry is in unstructured format
flag = strfind(line,'nCi');
if isempty(flag) == 0
    fclose(fid);
    gmtry = read_b2fgmtry_us(file);
    return
end

% Geometry cannot be read
if isempty(flag) == 1
    error(['Error - file cannot be read']);
end

end
