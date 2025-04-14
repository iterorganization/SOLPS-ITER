function state = read_b2fplasmf(file)
% state = read_b2fplasmf(file)
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


% Get version of the b2fstate file

line    = fgetl(fid);
version = line(8:17);

disp(['read_b2fplasmf -- file version ',version]);
line = fgetl(fid);

% Geometry is in structured format
flag = strfind(line,'nx');
if isempty(flag) == 0
    fclose(fid);
    state = read_b2fplasmf_st(file);
    return
end

% Geometry is in unstructured format
flag = strfind(line,'nCv');
if isempty(flag) == 0
    fclose(fid);
    state = read_b2fplasmf_us(file);
    return
end

% Geometry cannot be read
if isempty(flag) == 1
    error(['Error - file cannot be read']);
end

end