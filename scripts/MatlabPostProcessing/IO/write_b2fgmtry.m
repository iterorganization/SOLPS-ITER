function write_b2fgmtry(file,label,gmtry)
% write_b2fgmtry(file,label,gmtry)
%
% Write b2fgmtry file for use by B2.5.
%
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% September 2025

fprintf('\n')

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

% Get version of the b2fgmtry file
flag = isunstructuredgrid(gmtry);

if flag == 0 % gmtry is structured
    fclose(fid);
    write_b2fgmtry_st(file,label,gmtry);
    return
else % gmtry is unstructured
    fclose(fid);
    write_b2fgmtry_us(file,label,gmtry);
    return
end

end