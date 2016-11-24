function geo = read_geo(file)
% geo = read_geo(file)
%
% Read .geo file.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read nx, ny
dims = fscanf(fid,'%d',2);
nx   = dims(1);
ny   = dims(2);

% Initialize output arrarys
crxs = zeros(nx+2,ny+2,5);
crys = zeros(nx+2,ny+2,5);
bp   = zeros(nx+2,ny+2);
bt   = zeros(nx+2,ny+2);

% Scan file line by line
for j = 1:ny+2
    for i = 1:nx+2
        line = fscanf(fid,'%d %d %f %f %f %f %f %f %f %f %f %f %f %f',14);
        crxs(i,j,1) = line(3);  crys(i,j,1) = line(4);
        crxs(i,j,2) = line(5);  crys(i,j,2) = line(6);
        crxs(i,j,3) = line(7);  crys(i,j,3) = line(8);
        crxs(i,j,4) = line(9);  crys(i,j,4) = line(10);
        crxs(i,j,5) = line(11); crys(i,j,5) = line(12);
        bp(i,j)     = line(13); bt(i,j)     = line(14);
    end
end

% Store in struct
geo.crxs = crxs;
geo.crys = crys;
geo.bp   = bp;
geo.bt   = bt;


% Close file
fclose(fid);