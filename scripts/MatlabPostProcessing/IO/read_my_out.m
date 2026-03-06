function dat = read_my_out(file)
% dat = read_my_out(file)
%
% Read .dat-files created by my_out routine of B2.5. 

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% April 2025

fprintf('\n')

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read header line with x-cell numbers
line = strtrim(fgetl(fid));
tokens = strsplit(line);
if numel(tokens) >= 2
    if contains(tokens{2},'.') || contains(tokens{2},'E') || contains(tokens{2},'e')
        fclose(fid);
        dat = read_my_out_us(file);
    else
        fclose(fid);
        dat = read_my_out_st(file);
    end
else
    error('Invalid output file format');
end

end