function [vertex] = intvertex_us(nVx,gmtry,vxvol,centre)
% [vertex] = intvertex_us(nVx,gmtry,vxvol,centre)
%
% Interpolates a cell-centered quantity on cell vertices.
%
vertex = zeros(nVx,1);
for iVx = 1: nVx
    volsum = 0.0;
    for iCv = 1:gmtry.vxCvP(iVx,2)
        volsum = volsum + 1/vxvol(gmtry.vxCvP(iVx,1) + iCv - 1);
        vertex(iVx) = vertex(iVx) + centre(gmtry.vxCv(gmtry.vxCvP(iVx,1) + iCv - 1))/vxvol(gmtry.vxCvP(iVx,1) + iCv - 1);
    end
    vertex(iVx) = vertex(iVx)/volsum;
end
      
end