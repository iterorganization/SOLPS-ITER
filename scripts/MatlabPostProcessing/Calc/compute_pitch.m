function pitch = compute_pitch(gmtry)
% pitch = compute_pitch(nCv,gmtry)
%
% Computes the pitch of the magnetic field on faces.
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% January 2026

pitch = gmtry.fcBb(:,1)./gmtry.fcBb(:,4);

end