function c_s = compute_sound_speed(plasma,am,za)
% compute_sound_speed(gm,labellist,colorlist,type)
%
% Routine to the sound speed in the same way as it is done in B2.5.
% This routine reproduces the behaviours of b2xppz and b2xprz auxiliary
% routines for internal state only (no st_ext considered).
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% October 2025

pz = plasma.ne.*plasma.te;
ns = size(plasma.na,2);
mp = 1.67262192e-27; % kilograms

for is = 1:ns
    if (za(is)>0) 
      pz = pz + plasma.na(:,is).*plasma.ti;
    end
end

rz = 0.0;
for is = 1:ns
    if (za(is)>0) 
        rz = rz + mp*am(is)*plasma.na(:,is);
    end
end

c_s = sqrt(pz./rz);


end
