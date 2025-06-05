function state = read_b2fstate(file)
% state = read_b2fstate(file)
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

disp(['read_b2fstate -- file version ',version]);

% Geometry is in unstructured format
if str2num(strrep(version,'.','')) >= str2num(strrep('03.002.000','.',''))
    fclose(fid);
    state = read_b2fstate_us(file);
    return
else
    fclose(fid);
    state = read_b2fstate_st(file);
    return
end

end