function virtualtarget = read_virtualtarget(file)
% virtualtarget = read_virtualtarget(file)
% 
% Read virtualtarget file containing coordinates of virtual targets created
% by Carre2. Convert units to m.
%
% Output in same format as a structure.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be


% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Init
virtualtarget = struct('nel',{},'r',{},'z',{});
it = 0;

% Read until blank is found
line = fgetl(fid);
eof = 0;
if line == -1
        eof = 1;
end
while ~eof
    it  = it + 1;
    nel = 0;
    r = [];
    z = [];
    while ~isequal(line,' ')
        nel = nel + 1;
        [rnew,znew] = strread(line,'%f %f');
        r = [r;rnew];
        z = [z;znew];
        line = fgetl(fid);
    end
    virtualtarget(it).nel = nel;
    virtualtarget(it).r = r;
    virtualtarget(it).z = z;
    
    % Check next line
    line = fgetl(fid);
    if line == -1
        eof = 1;
    end
end

% Convert to m
for i = 1:it
    virtualtarget(i).r = virtualtarget(i).r/1000;
    virtualtarget(i).z = virtualtarget(i).z/1000;
end
    
end