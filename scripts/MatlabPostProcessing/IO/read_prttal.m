function [tal] = read_prttal(file)
% [tal] = read_prttal(file)
%
% Read outputfile created by EIRENE_PRTTAL.
%
%
% 
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

line = fgetl(fid);
while line ~= -1
    
    % skip first two lines
    fgetl(fid);
    
    % read label, species, units
    tal.label   = fgetl(fid);
    tal.species = fgetl(fid);
    tal.units   = fgetl(fid);
    
    % skip next two lines
    fgetl(fid); fgetl(fid);

    % read NR1TAL,NP2TAL,NT3TAL,NBMLT,NSBOX_TAL
    % Note for triangle mesh:
    % * NR1TAL    = number of triangles + 1, last value = average
    % * NSBOX_TAL = NR1TAL + NADD
    tal.dim = fscanf(fid,'%d',5);
    
    % Read the actual data
    tal.val = fscanf(fid,'%f');
    
    % Read next line, to check of EOF
    line = fgetl(fid);
end

% close file
fclose(fid);