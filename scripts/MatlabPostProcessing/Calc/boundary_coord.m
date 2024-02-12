function bCoord = boundary_coord(gmtry,fcList,iVx_ref)
% bCoord = boundary_coord(gmtry,fcList,iVx_ref)
%
% Compute coordinate along boundary face list (length).
%
% Coordinate is set to zero at reference vertex iVx_ref if provided.
% Otherwise, set to zero at first vertex of polyline (default).
%

% Set default values for some arguments, if not supplied
if ~exist('iVx_ref','var') || isempty(iVx_ref)
    % If no reference point provided, put zero at start of polyline
    if (gmtry.fcVx(fcList(1),1) == gmtry.fcVx(fcList(2),1) || ...
        gmtry.fcVx(fcList(1),1) == gmtry.fcVx(fcList(2),2))
        iVx_ref = gmtry.fcVx(fcList,2);
    elseif (gmtry.fcVx(fcList(1),2) == gmtry.fcVx(fcList(2),1) || ...
            gmtry.fcVx(fcList(1),2) == gmtry.fcVx(fcList(2),2))
        iVx_ref = gmtry.fcVx(fcList,1);
    else
        error('Problem with fcList');
    end
end

% Compute the coordinates with zero at start of polyline
bCoord = zeros(size(fcList));
offset = 0;
s_ref  = 0;
for i = 1:length(fcList)
    iFc     = fcList(i);
    delta_s = sqrt(...
        (gmtry.vxX(gmtry.fcVx(iFc,2))-gmtry.vxX(gmtry.fcVx(iFc,1)))^2 +...
        (gmtry.vxY(gmtry.fcVx(iFc,2))-gmtry.vxY(gmtry.fcVx(iFc,1)))^2);
    bCoord(i) = offset + delta_s/2;
    offset    = offset + delta_s;

    % Check whether one of the face vertices is the reference point
    if gmtry.fcVx(iFc,1) == iVx_ref
        if i < length(fcList)
            % Common with next face?
            if (gmtry.fcVx(iFc,1) == gmtry.fcVx(fcList(i+1),1) || ...
                gmtry.fcVx(iFc,1) == gmtry.fcVx(fcList(i+1),2))
                s_ref = offset;
            end
        elseif i  == length(fcList)
            % Not common with previous face?
            if (gmtry.fcVx(iFc,1) ~= gmtry.fcVx(fcList(i-1),1) && ...
                gmtry.fcVx(iFc,1) ~= gmtry.fcVx(fcList(i-1),2))
                s_ref = offset;
            end
        end

    elseif gmtry.fcVx(iFc,2) == iVx_ref

        if i < length(fcList)
            % Common with next face?
            if (gmtry.fcVx(iFc,2) == gmtry.fcVx(fcList(i+1),1) || ...
                gmtry.fcVx(iFc,2) == gmtry.fcVx(fcList(i+1),2))
                s_ref = offset;
            end
        elseif i  == length(fcList)
            % Not common with previous face?
            if (gmtry.fcVx(iFc,2) ~= gmtry.fcVx(fcList(i-1),1) && ...
                gmtry.fcVx(iFc,2) ~= gmtry.fcVx(fcList(i-1),2))
                s_ref = offset;
            end
        end
    end
end

% Shift to have zero at reference point
bCoord = bCoord - s_ref;
