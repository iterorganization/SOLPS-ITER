%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balgrid plots the whole grid for a particular simulation, as well as the     %
% particular volume where integrated balance is to be performed and the        %
% poloidal cells along which poloidal balance will be performed                % 
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function balgrid(comuse,indrad,indpol,axgrid,reverse)

axis(axgrid,'image');
xlabel(axgrid,'R (m)');
ylabel(axgrid,'Z (m)');

% Plot the grid (excluding ghost cells):
S = struct([]);
for iCv = 1:comuse.nCv
    iVx1 = comuse.cvVx(comuse.cvVxP(iCv,1));
    S(iCv).XData = comuse.vxX(iVx1);
    S(iCv).YData = comuse.vxY(iVx1);
    iVx = iVx1;
    nfaces = comuse.cvFcP(iCv,2);
    face_treated = zeros(nfaces,1);
    while sum(face_treated) < nfaces
        for i = 1:nfaces
            if (face_treated(i) == 0)
                iFc = comuse.cvFc(comuse.cvFcP(iCv,1)+i-1);
                if (comuse.fcVx(iFc,1)==iVx)
                    S(iCv).XData = [S(iCv).XData;comuse.vxX(comuse.fcVx(iFc,2))];
                    S(iCv).YData = [S(iCv).YData;comuse.vxY(comuse.fcVx(iFc,2))];
                    face_treated(i)=1;
                    iVx=comuse.fcVx(iFc,2);
                elseif (comuse.fcVx(iFc,2)==iVx)
                    S(iCv).XData = [S(iCv).XData;comuse.vxX(comuse.fcVx(iFc,1))];
                    S(iCv).YData = [S(iCv).YData;comuse.vxY(comuse.fcVx(iFc,1))];
                    face_treated(i)=1;
                    iVx=comuse.fcVx(iFc,1);
                end
            end
        end
    end
end

for i = 1:length(S)
    patch(S(i).XData,S(i).YData,'w','parent',axgrid,...
        'handlevisibility','off');
end

% Plot the radial balance volume:
S2 = struct([]);
for iCv = 1:comuse.nCv
    if indrad(iCv)
        S2(iCv).XData = S(iCv).XData;
        S2(iCv).YData = S(iCv).YData;
    end
end
first = true;
for i = 1:length(S2)
    if ~isempty(S2(i).XData)
        if first
            patch(S2(i).XData,S2(i).YData,'y','parent',axgrid);
            first = false;
        else
            patch(S2(i).XData,S2(i).YData,'y','parent',axgrid,...
                'handlevisibility','off');
        end
    end
end

% Plot the poloidal balance volume:
S2 = struct([]);
for iCv = 1:comuse.nCv
    if indpol(iCv)
        S2(iCv).XData = S(iCv).XData;
        S2(iCv).YData = S(iCv).YData;
    end
end
for i = 1:length(S2)
    patch(S2(i).XData,S2(i).YData,'m','parent',axgrid);
end
    
hl = legend(axgrid, 'radial balance volume',...
                   'poloidal balance volume');

end
