function cont = read_ft78(file)
% cont = read_ft78(file)
% 
% Read contours from fort.78 files
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read (and ignore) triangle size
dum = fscanf(fid,'%f',1);

% Read dummy line
fgetl(fid);
fgetl(fid);

% Start scanning for polygons
i = 0;
line = fgetl(fid);
while line ~= -1
    i = i+1;
    
    % Read number of point in polygon
    nel = strread(line,'%d',1);
    
    % Read coordinates
    coords = fscanf(fid,'%f',[2,nel]);
    cont(i).r = 1e-2*coords(1,:)';
    cont(i).z = 1e-2*coords(2,:)';

    % Story dummy
    cont(i).tsize = dum;
    
    % Check for next polygon
    fgetl(fid);
    line = fgetl(fid);
    
end



    