function write_sfield(fid,fieldname,field)
% write_sfield(fid,fieldname,field)
%
% Auxiliary routine to write string fields for B2.5 b2f* files
% 
% Note:
% - always uses string length 120 (as expected by B2.5)
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Print a label
fprintf(fid,'%s','*cf:    char');
fprintf(fid,'%16d',120);
fprintf(fid,'%s\n',['    ',fieldname]);

% Print the string
fprintf(fid,'%s\n',[' ',field]);

end