function chr = read_chr(file)
% chr = read_chr(file)
%
% Read *.chr-file containing data on diagnostic chords.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Open file
[fid,msg] = fopen(file);
if (fid == -1)
   error(msg);
end

% Read a label
label     = fgetl(fid);
chr.label = label;

% Init empty chords
chr.r   = [];
chr.z   = [];
chr.y   = [];
chr.num = [];

% Read line per line until end of file
line = fgetl(fid);
while line ~= -1
    chorddata = strread(line,'%f',7);
    chr.r   = [chr.r;chorddata(1), chorddata(4)];
    chr.y   = [chr.y;chorddata(2), chorddata(5)];
    chr.z   = [chr.z;chorddata(3), chorddata(6)];
    chr.num = [chr.num;chorddata(7)];
    
    line = fgetl(fid);
end

fclose(fid);