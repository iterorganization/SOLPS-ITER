function dat = read_my_out_us(file)
% dat = read_my_out_us(file)
%
% Read .dat-files created by my_out_us routine of B2.5.
%
% Assumed format of data tables in the files:
%
%    1   ...
%    2   ...
%  ...   ... 
%    n   ...

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% December 2019

disp(['Attempting read_my_out_us.'])


[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read data lines
dat = [];
line = fgetl(fid);
while line ~= -1
    dat = [dat;strread(line(11:end),'%f',1)'];
    line = fgetl(fid);
end

% Close file
fclose(fid);

disp(['Done read_my_out_us with no errors.'])

end