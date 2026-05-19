function p_interp = convert_b2fplasmf_to_nCv(p,gmtry)
% p_interp = convert_b2fplasms_to_nCv(p)
%
% Routine to generate a plasma state interpolating the quantities defined
% on nFc to nCv.
%
% Input arguments:
%
% - p        : plasma state from b2fplasmf
% - gmtry    : geometry from b2fgmtry
%
% Output arguments:
%
% - p_interp : plasma state with quantities defined on nCv
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% December 2025

fprintf('\n')
disp(['Attempting interpolating plasma state to nCv.'])

% Collecting plasma state field
fields = fieldnames(p);

nCv = gmtry.nCv;
nFc = gmtry.nFc;
wghtP = gmtry.intcellP;
wghtR = gmtry.intcellR;


for i = 1:numel(fields)

    fname = fields{i};
    val   = p.(fname);
    
    if size(val,1) == nCv
        p_interp.(fname) = val;
    elseif size(val,1) == nFc && size(val,2) ~= 1
        p_interp.(fname) = zeros(nCv, 2, size(val,3));
        for is = 1:size(p.(fname),3)
            p_interp.(fname)(:,1,is) = intcell_us(nCv,gmtry,wghtP,val(:,1,is));
            p_interp.(fname)(:,2,is) = intcell_us(nCv,gmtry,wghtR,val(:,2,is));
        end
    end
end

disp(['Done interpolating plasma state to nCv with no errors.'])
fprintf('\n')

end