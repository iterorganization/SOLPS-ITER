function str = read_str(file)
% str = read_str(file)
%
% Read *.str-file created by DG.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read number of structures
nstr = fscanf(fid,'%d',1);

% For each structure, read number of segments, and corresponding
% coordinates
str = struct('r',{},'z',{});

for i = 1:nstr
    
    nel      = fscanf(fid,'%d',1);
    coords   = fscanf(fid,'%f , %f \n',2*nel);
    str(i).r = coords(1:2:end-1);
    str(i).z = coords(2:2:end);
    
end

end