function PlotFaceLabels(gm,labellist,colorlist,type)
% plot the faces of an unstructured B2.5 mehs with colors correspondng to labels
hold on;
N = length(labellist); % number of different labels provided
iflag = 0;
nfaces = 0;
for iFc = 1:gm.nFc
    vx1 = gm.fcVx(iFc,1); % first vertex of face
    vx2 = gm.fcVx(iFc,2); % second vertex of face
    x1 = gm.vxX(vx1); % x-coord of first vertex
    y1 = gm.vxY(vx1); % y-coord of first vertex
    x2 = gm.vxX(vx2); % x-coord of second vertex
    y2 = gm.vxY(vx2); % y-coord of second vertex
    if type == 'fcReg' 
        if gm.fcReg(iFc) == 0
            plot([x1 x2],[y1 y2],'k','LineWidth',0.5) 
        else
            for i = 1:N
                if gm.fcReg(iFc) == labellist(i)
                    plot([x1 x2],[y1 y2],colorlist(i),'LineWidth',2)
                    iflag = 1;
                end
            end
        end
    elseif type == 'fcLbl'
        if gm.fcLbl(iFc) == 0
            %plot([x1 x2],[y1 y2],'k','LineWidth',0.5) 
        else
            for i = 1:N
                if gm.fcLbl(iFc) == labellist(i)
                    plot([x1 x2],[y1 y2],colorlist(i),'LineWidth',2)
                    iflag = 1;
                    nfaces = nfaces + 1;

                end
            end
        end
    else
        error('type not recognized')
    end

end

if iflag==0
    error('No faces plotted')
end

fprintf('Number of faces found: %d \n', nfaces);
hold off;
end