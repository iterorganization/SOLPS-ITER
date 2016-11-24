function write_geo(file,geo)
% write_geo(file,geo)
%
% Write .geo file.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end

% Determine dimensions
nx = size(geo.crxs,1) - 2;
ny = size(geo.crxs,2) - 2;

% Write dimensions nx, ny
fprintf(fid,'%12d %14d\n',[nx,ny]);

crxs = geo.crxs;
crys = geo.crys;
bp   = geo.bp;
bt   = geo.bt;

% Write data into file line by line
for j = 1:ny+2
    for i = 1:nx+2
        line = [i-1,j-1,crxs(i,j,1),crys(i,j,1),crxs(i,j,2),crys(i,j,2),crxs(i,j,3),crys(i,j,3),...
            crxs(i,j,4),crys(i,j,4),crxs(i,j,5),crys(i,j,5),bp(i,j),bt(i,j)];
        fprintf(fid,'%4d %4d %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n',line);
    end
end

% Close file
fclose(fid);

end