%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ncread_opt reads a field of balance.nc that older versions of B2.5 do not    %
% write. If the file does not contain it, the older field old is read          %
% instead when given (it holds this field together with other parts),          %
% otherwise a warning is given and zeros of size sz are returned: the          %
% balance is then incomplete in the cases that the field covers. found is      %
% true only when the field itself was read.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [v,found] = ncread_opt(balfile,name,sz,old)

info = ncinfo(balfile);
vars = {info.Variables.Name};
found = any(strcmp(vars,name));
if found
    v = ncread(balfile,name);
elseif nargin > 3 && any(strcmp(vars,old))
    warning(['%s not found in %s (written by an older B2.5): %s, which ',...
        'holds it together with other parts, read instead.'],name,balfile,old);
    v = ncread(balfile,old);
else
    warning(['%s not found in %s (written by an older B2.5): taken as ',...
        'zero.'],name,balfile);
    v = zeros(sz);
end

end
