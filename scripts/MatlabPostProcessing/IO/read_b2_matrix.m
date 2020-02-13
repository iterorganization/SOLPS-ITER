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

imat = 0;

line = fgetl(fid);
while line ~= -1
    
    imat = imat + 1;
    
    % Read n (number of cells)
    n = fscanf(fid,'%d',1);fgetl(fid);
    
    % Initialize rhs
    matrix(imat).rhs = zeros(n,1);
    
    % Scan file line by line
    for i = 1:n
        matrix(imat).rhs(i)  = fscanf(fid,'%e',1);
    end
    
    % Read number on non-zero elements
    nz = fscanf(fid,'%d',1);
    fgetl(fid);
    
    for i = 1:nz
        line = fscanf(fid,'%d %d %e',3);
        matrix(imat).irnh(i) = line(1); % row number of element i
        matrix(imat).icnh(i) = line(2); % column number of element i
        matrix(imat).a1h(i)  = line(3); % element i
    end
    
    fgetl(fid);
    line = fgetl(fid);
    
end




% Close file
fclose(fid);