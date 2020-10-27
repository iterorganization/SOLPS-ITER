function links = read_ft35_us(file)
%
% Read unstructured version of fort.35-files (triangle data). 
%
% E-mail: wim.vanuytven@kuleuven.be

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
links.plasma_cell  = zeros(ntria,1);

for i = 1:ntria
    data = fscanf(fid,'%d',14);
    links.nghbr(i,:) = data(2:3:8);
    links.side(i,:)  = data(3:3:9);
    links.cont(i,:)  = data(4:3:10);
    links.plasma_cell(i,:) = data(11);
end

% close file
fclose(fid);
