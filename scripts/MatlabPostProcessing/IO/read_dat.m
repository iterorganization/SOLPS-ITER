function dat = read_dat(file)
% dat = read_dat(file)
%
% Read .dat-files created by ANK.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end


%% Scan till start of data

line0 = fgetl(fid);
line1 = fgetl(fid);
while line1(1) == '#'
    line0 = line1;
    line1 = fgetl(fid);
    if line1 == -1
        error('EOF reached.');
    end
end
dat.labels = strread(line0(2:end),'%s');
dat.val    = strread(line1,'%f',length(dat.labels))';
line1 = fgetl(fid);
while line1 ~= -1
    dat.val = [dat.val;strread(line1,'%f',length(dat.labels))'];
    line1 = fgetl(fid);
end


fclose(fid);