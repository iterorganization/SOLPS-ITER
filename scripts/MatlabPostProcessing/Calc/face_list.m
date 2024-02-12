function fcList = face_list(gmtry,fcLbl,meth)
% fcList = face_list(gmtry,fcLbl,meth)
%
% Function to return an ordered list of faces corresponding to a (set of)
% given face label(s).
% It is assumed that the faces will form a single (open or closed)
% polyline.
%
% Meth determines the criterion to sort the faces.
% In case of an open polyline:
% 'X'  : from 'low' to 'high' X-coordinate (based on the end points only)
% 'Y'  : from 'low' to 'high' Y-coordinate (based on the end points only)
% 'Psi': from 'low' to 'high' Psi-coordinate (based on the end points only)


% Set default values for some arguments, if not supplied
if ~exist('meth','var') || isempty(meth)
  meth = '';
end

% Find all faces with the corresponding label(s)
fcList_unsorted = [];
for i = 1:length(fcLbl)
    fcList_unsorted = [fcList_unsorted;find(gmtry.fcLbl == fcLbl(i))];
end
if length(fcList_unsorted) < 1
    error('No faces in list')
end

% Form continuous line by connecting vertices
used   = zeros(size(fcList_unsorted));

% Arbitrary starting point: first face
ifc     = 1;
fcList  = fcList_unsorted(1);
used(1) = 1;
ivx     = 1;
dir     = 1;

% Tentatively store initial vertex as starting point of polyline
start_point = gmtry.fcVx(fcList(ifc),ivx);

if length(fcList_unsorted) == 1
    end_point = gmtry.fcVx(fcList(ifc),2);
end

% Find chain of neighbors
while dir && ~all(used)
    found   = 0;
    i       = 0;
    while ~found && dir
        i = i+1;
        if i > length(fcList_unsorted)
            % No connecting face found in this direction
            % Store current vertex as end point of polyline
            end_point = gmtry.fcVx(fcList(ifc),ivx);
            % Move into other direction
            dir = 0;
            ifc = 1;
            ivx = 2;
        elseif ~used(i) && gmtry.fcVx(fcList_unsorted(i),1) == gmtry.fcVx(fcList(ifc),ivx)
            found   = 1;
            used(i) = 1;
            fcList  = [fcList;fcList_unsorted(i)];
            ifc     = length(fcList);
            ivx     = 2;
            % Store current vertex as end point of polyline
            end_point = gmtry.fcVx(fcList(ifc),ivx);
        elseif ~used(i) && gmtry.fcVx(fcList_unsorted(i),2) == gmtry.fcVx(fcList(ifc),ivx)
            found   = 1;
            used(i) = 1;
            fcList  = [fcList;fcList_unsorted(i)];
            ifc     = length(fcList);
            ivx     = 1;
            % Store current vertex as end point of polyline
            end_point = gmtry.fcVx(fcList(ifc),ivx);
        end
    end
end

while ~dir  && ~all(used)
    found   = 0;
    i       = 0;
    while ~found && ~dir
        i = i+1;
        if i > length(fcList_unsorted)
            % No connecting face found in this direction
            % Store current vertex as starting point of polyline
            start_point = gmtry.fcVx(fcList(ifc),ivx);
            % move into other direction to terminate search
            dir = 1;
        elseif ~used(i) && gmtry.fcVx(fcList_unsorted(i),1) == gmtry.fcVx(fcList(ifc),ivx)
            found   = 1;
            used(i) = 1;
            fcList  = [fcList_unsorted(i);fcList];
            ivx     = 2;
        elseif ~used(i) && gmtry.fcVx(fcList_unsorted(i),2) == gmtry.fcVx(fcList(ifc),ivx)
            found   = 1;
            used(i) = 1;
            fcList  = [fcList_unsorted(i);fcList];
            ivx     = 1;
        end
    end
end

if length(fcList)~=length(fcList_unsorted)
    error('Not all faces found');
end

% Sort the resulting polyline
if (start_point ~= end_point)
    switch meth
        case 'X'

            % Sort based on X-co of start and end point
            if gmtry.vxX(start_point) > gmtry.vxX(end_point)
                fcList = fcList(end:-1:1);
            end

        case 'Y'

            % Sort based on Y-co of start and end point
            if gmtry.vxY(start_point) > gmtry.vxY(end_point)
                fcList = fcList(end:-1:1);
            end


        case 'Psi'

            % Sort based on Psi-value of start and end point
            if gmtry.vxFpsi(start_point) > gmtry.vxFpsi(end_point)
                fcList = fcList(end:-1:1);
            end

        otherwise

            % do nothing

    end
end

