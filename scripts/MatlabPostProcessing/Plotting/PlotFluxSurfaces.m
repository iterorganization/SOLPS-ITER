function PlotFluxSurfaces(gmtry,surf_indx,rzomp,rzimp)
% PlotFluxSurfaces(gmtry,surf_indx,options)
%
% Routine to plot flux surfaces with indexes surf_indx. Additionally, the
% OMP and IMP can be plotted as well, if rzomp and rzimp are passed.
% 
% Input arguments:
%
% - gmtry     : struct read from b2fgmtry-file
% - surf_indx : array containing the indexes of the flux surfaces to be
%               plotted
% - rzomp/imp : optional arguments, OMP and IMP coordinates defined as
%               segment; rz*mp(1,:) are the R coordinates of the two points
%               defining the segment, rz*mp(2,:) are the Z coordinates

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% August 2025

if max(surf_indx) > gmtry.nFs
    error('surf_indx cannot be greater than nFs!')
end

bool_check = 'false';

figure()
hold on
for iFc = 1:gmtry.nFc
    if gmtry.fcCv(iFc,2) > gmtry.nCi % faces on boundary cells
        vx1 = gmtry.fcVx(iFc,1); % first vertex of face
        vx2 = gmtry.fcVx(iFc,2); % second vertex of face
        x1 = gmtry.vxX(vx1); % x-coord of first vertex
        y1 = gmtry.vxY(vx1); % y-coord of first vertex
        x2 = gmtry.vxX(vx2); % x-coord of second vertex
        y2 = gmtry.vxY(vx2); % y-coord of second vertex
        plot([x1 x2],[y1 y2],'k','LineWidth',2) % plot vessel contour
    end
end

vertX = [];
vertY = [];
for jj = 1:length(surf_indx)
    is1 = gmtry.fsFcP(surf_indx(jj),1);
    is2 = gmtry.fsFcP(surf_indx(jj),1) + gmtry.fsFcP(surf_indx(jj),2) -1;
    faces = gmtry.fsFc(is1:is2);
    for ii = 1 : length(faces)
        bool_check = 'true';
        vertX = [gmtry.vxX(gmtry.fcVx(faces(ii),1)),...
                 gmtry.vxX(gmtry.fcVx(faces(ii),2))];
        vertY = [gmtry.vxY(gmtry.fcVx(faces(ii),1)),...
                 gmtry.vxY(gmtry.fcVx(faces(ii),2))];
        plot(vertX, vertY,'r-','LineWidth',2.5)

    end
    if (strcmp(bool_check,'false'))
        close
        fprintf('\n surf_indx is: %d\n', surf_indx(jj))
        error('Apparently no flux surface has been plotted for the given surface index...')
    end
end
xlabel('R [m]')
ylabel('Z [m]')
title('Flux surfaces')
axis equal

if exist('rzomp','var') && ~isempty(rzomp)
    plot(rzomp(1,:),rzomp(2,:),'k--','LineWidth',2)
end

if exist('rzimp','var') && ~isempty(rzimp)
    plot(rzimp(1,:),rzimp(2,:),'k--','LineWidth',2)
end

hold off

end