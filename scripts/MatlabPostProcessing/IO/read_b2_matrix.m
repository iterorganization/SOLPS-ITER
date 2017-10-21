function matrix = read_b2_matrix(file)
% matrix = read_b2_matrix(file)
%
% Read b2_matrix file, created by using option 'ma28_nwrite' in B2.5.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read n (number of cells)
n = fscanf(fid,'%d',1);

% Neglect line of strings
fgetl(fid);fgetl(fid);

% Initialize output arrarys
matrix.aa  = zeros(n,5);
matrix.rhs = zeros(n,1);

% Scan file line by line
for i = 1:n
    line = fscanf(fid,'%*d %e %e %e %e %e %e',6);
    matrix.aa(i,:) = line(1:5);
    matrix.rhs(i)  = line(6);
end

% Read number on non-zero elements
nz = fscanf(fid,'%d',1);
fgetl(fid);

for i = 1:nz
    line = fscanf(fid,'%d %d %e',3);
    matrix.irnh(i) = line(1); % row number of element i
    matrix.icnh(i) = line(2); % column number of element i
    matrix.a1h(i)  = line(3); % element i
end

% Close file
fclose(fid);