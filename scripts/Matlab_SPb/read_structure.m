function structure = read_structure(file)
% structure = read_structure(file)
% 
% Read structure.dat file containing coordinates of structures.
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

% Scan for header indicating start of structure list
line = fgetl(fid);
while isempty(strfind(line,'$structures'))
    line = fgetl(fid);
    if line == -1
        error('EOF reached without finding $structures.');
    end
end


% For each structure, read number of segments, and corresponding
% coordinates
structure = struct('nel',{},'r',{},'z',{});

for i = 1:nstr
    
    % Consistency check
    line = fgetl(fid);
    [label,istr] = strread(line,'%s %d');
    if (~strcmp(label,'Structure') ||  i ~= istr)
        error('read_structure: inconsistent input.');
    end
    
    % Read coordinates
    nel    = fscanf(fid,'%d',1);
    coords = fscanf(fid,'%f %f \n',2*abs(nel));
    structure(i).nel = nel;
    structure(i).r   = coords(1:2:end-1);
    structure(i).z   = coords(2:2:end);
    
end
    
end