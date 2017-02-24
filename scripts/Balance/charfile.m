%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% charfile reads a binary file into a single character array                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filestr = charfile(filename)
% Open the file:
[lb2,errmsg] = fopen(filename);
if (~isempty(errmsg))
    error('myApp:argChk','Error opening tran file: %s',errmsg);
end

% Read tran file into a single character array. Use char() so that out-of-range
% characters are read as well:
filestr = char(fread(lb2,'int8'))';