function links = read_ft35(file)
% necke = read_ft35(file)
%
% Read fort.35-files (triangle data). 
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end



%% Read data

% number of triangels
ntria = fscanf(fid,'%d',1);

links.nghbr = zeros(ntria,3);
links.side  = zeros(ntria,3);
links.cont  = zeros(ntria,3);
links.ixiy  = zeros(ntria,2);

for i = 1:ntria
    data = fscanf(fid,'%d',12);
    links.nghbr(i,:) = data(2:3:8);
    links.side(i,:)  = data(3:3:9);
    links.cont(i,:)  = data(4:3:10);
    links.ixiy(i,:)  = data(11:12);
end

% close file
fclose(fid);