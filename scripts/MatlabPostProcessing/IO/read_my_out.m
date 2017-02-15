function dat = read_my_out(file)
% dat = read_my_out(file)
%
% Read .dat-files created by my_out routine of B2.5.
%
% Assumed format of data tables in the files:
%
%         -1     0     1     ...       nx
%   ny   ...   ...   ...                  
%  ...   ...   ...                        
%   -1   ...                          ... 

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read header line with x-cell numbers
line = fgetl(fid);
xco  = strread(line,'%d');
nx   = xco(end);

% Read data lines
dat = [];
line = fgetl(fid);
while line ~= -1
    dat = [dat;strread(line(7:end),'%f',nx+2)'];
    line = fgetl(fid);
end

% Rearrange: element (1,1) in array should correspond to lower left cell
dat = fliplr(dat');

% Close file
fclose(fid);

