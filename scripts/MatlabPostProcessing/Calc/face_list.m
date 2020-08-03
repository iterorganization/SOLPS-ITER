function fcList = face_list(gmtry,fcLbl)
%
% function to return an ordered list of faces corresponding to a given face
% label
%

% Find all faces with the corresponding label
fcList_unsorted = [];
for i = 1:length(fcLbl)
    fcList_unsorted = [fcList_unsorted;find(gmtry.fcLbl == fcLbl(i))];
end

% Sort through vertices
used   = zeros(size(fcList_unsorted));
% fcList = zeros(size(fcList_unsorted));

% Arbitrary starting point: first face
ifc     = 1;
fcList  = fcList_unsorted(1);
used(1) = 1;
ivx     = 1;
dir     = 1;

% Find chain of neighbors
while dir && ~all(used)
    found   = 0;
    i       = 0;
    while ~found && dir
        i = i+1;
        if i > length(fcList_unsorted)
            % no connecting face found; move into other direction
            dir = 0;
            ifc = 1;
            ivx = 2;
        elseif ~used(i) && gmtry.fcVx(fcList_unsorted(i),1) == gmtry.fcVx(fcList(ifc),ivx)
            found   = 1;
            used(i) = 1;
            fcList  = [fcList;fcList_unsorted(i)];
            ifc     = length(fcList);
            ivx     = 2;
        elseif ~used(i) && gmtry.fcVx(fcList_unsorted(i),2) == gmtry.fcVx(fcList(ifc),ivx)
            found   = 1;
            used(i) = 1;
            fcList  = [fcList;fcList_unsorted(i)];
            ifc     = length(fcList);
            ivx     = 1;
        end
    end
end
    
while ~dir  && ~all(used)
    found   = 0;
    i       = 0;
    while ~found && ~dir
        i = i+1;
        if i > length(fcList_unsorted)
            % no connecting face found; move into other direction
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



