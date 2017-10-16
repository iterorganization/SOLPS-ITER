%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getdata gets a data array from a b2fplasma file whose character conversion   %
% was previously read in by charfile                                           %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = getdata(filestr,filename,name)

% Make name lowercase and pad it at the end to make 32 characters:
name = [lower(name),blanks(32-length(name))];

% Find data for this variable and get its information:
k = strfind(filestr,name);
if (isempty(k))
    error('myApp:argChk','Name: ''%s'' not found in b2fplasma file',name);
end
% Get the number of data points for this variable:
[lb2,errmsg] = fopen(filename);
if (~isempty(errmsg))
    error('myApp:argChk','Error opening tran file: %s',errmsg);
end
fseek(lb2,k-5,'bof');
n = fread(lb2,1,'int32');
% Get the data:
fseek(lb2,k+39,'bof');
data = fread(lb2,n,'real*8');

% Close the tran file
fclose(lb2);

end

