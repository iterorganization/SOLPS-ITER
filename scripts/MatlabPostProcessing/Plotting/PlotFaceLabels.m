function PlotFaceLabels(gm,labellist,colorlist,type)
% PlotFaceLabels(gm,labellist,colorlist,type)
%
% Routine to plot the faces of an unstructured B2.5 mehs with colors
% correspondng to labels. Faces can be plotted based on 'fcReg' or 'fcLbl'
% checks. Based on a script by Wim Van Uytven.
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% August 2025


hold on;
N = length(labellist); % number of different labels provided
legendHandles = gobjects(N,1);  % preallocation handles vector

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
%             plot([x1 x2],[y1 y2],'k','LineWidth',0.5) 
        else
            lbl = gm.fcReg(iFc);
            if ischar(lbl) || isstring(lbl)
                lblnum = str2double(lbl);
            else
                lblnum = double(lbl);
            end
            if isempty(lblnum) || isnan(lblnum) || lblnum == 0
                continue;
            end
            for i = 1:N
                if lblnum == labellist(i)
                    % estrai il colore correttamente (supporta cell array o matrice RGB)
                    if iscell(colorlist)
                        clr = colorlist{i};      % es. 'r' o '#FF0000'
                    elseif isnumeric(colorlist) && size(colorlist,2) == 3
                        clr = colorlist(i,:);    % RGB triplet
                    else
                        % fallback (es. char array di short codes)
                        clr = colorlist(i);
                    end
                    % plot usando 'Color' per essere coerenti con RGB o char
                    if ischar(clr) || isstring(clr)
                        h = plot([x1 x2],[y1 y2], 'Color', char(clr), 'LineWidth', 2);
                    else
                        % assume clr è un vettore RGB 1x3
                        h = plot([x1 x2],[y1 y2], 'Color', clr, 'LineWidth', 2);
                    end
                    nfaces = nfaces + 1;
                    if (iflag==0) 
                        iflag = 1;
                    end
                    % salva SOLO il primo handle valido per questa label
                    if ~isgraphics(legendHandles(i))
                        legendHandles(i) = h;
                    end
                end
            end
        end
    elseif type == 'fcLbl'
        if gm.fcLbl(iFc) == 0
            %plot([x1 x2],[y1 y2],'k','LineWidth',0.5) 
        else
            lbl = gm.fcLbl(iFc);
            if ischar(lbl) || isstring(lbl)
                lblnum = str2double(lbl);
            else
                lblnum = double(lbl);
            end
            if isempty(lblnum) || isnan(lblnum) || lblnum == 0
                continue;
            end
            for i = 1:N
                if lblnum == labellist(i)
                    % estrai il colore correttamente (supporta cell array o matrice RGB)
                    if iscell(colorlist)
                        clr = colorlist{i};      % es. 'r' o '#FF0000'
                    elseif isnumeric(colorlist) && size(colorlist,2) == 3
                        clr = colorlist(i,:);    % RGB triplet
                    else
                        % fallback (es. char array di short codes)
                        clr = colorlist(i);
                    end
                    % plot usando 'Color' per essere coerenti con RGB o char
                    if ischar(clr) || isstring(clr)
                        h = plot([x1 x2],[y1 y2], 'Color', char(clr), 'LineWidth', 2);
                    else
                        % assume clr è un vettore RGB 1x3
                        h = plot([x1 x2],[y1 y2], 'Color', clr, 'LineWidth', 2);
                    end
                    nfaces = nfaces + 1;
                    if (iflag==0) 
                        iflag = 1;
                    end
                    % salva SOLO il primo handle valido per questa label
                    if ~isgraphics(legendHandles(i))
                        legendHandles(i) = h;
                    end
                end
            end
        end
    else
        error('type not recognized')
    end
end

validIdx = isgraphics(legendHandles);
if any(validIdx)
    legendLabels = arrayfun(@(x) num2str(x), labellist(validIdx), 'UniformOutput', false);
    legend(legendHandles(validIdx), legendLabels, 'Location', 'best');
end

if iflag==0
    error('No faces plotted')
end

fprintf('Number of faces found: %d \n', nfaces);
hold off;
end