function structure = write_structure(file,structure)
% write_structure(file,str)
% 
% Write structure.dat file containing coordinates of structures.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% July 2020

% Open file
[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

% Write number of structures
nstr = length(structure);
fprintf(fid,'%12d\n',nstr);

% Write structures
% For each structure, read number of segments, and corresponding
% coordinates
fprintf(fid,'%s\n','$structures');
for i = 1:nstr
    
    fprintf(fid,'Structure %4d\n',i);
    fprintf(fid,'%13d\n',structure(i).nel);
    
    for j = 1:abs(structure(i).nel)
        fprintf(fid,'%11.7f %14.7f\n',[structure(i).r(j),structure(i).z(j)]);
    end

end

fclose(fid);

end