function [bcList,fcList] = bc_cell_list(gmtry,fcLbl,sort)
% [bcList,fcList] = bc_cell_list(gmtry,fcLbl,sort)
%
% Function to return an ordered list of guard cell indices corresponding to
% a (set of) given face label(s).
% It is assumed that the faces form a single (open or closed)
% polyline.
%
% Also the corresponding face list can be returned.
%

% Set default values for some arguments, if not supplied
if ~exist('sort','var') || isempty(sort)
  sort = '';
end

% Find all faces with the corresponding label(s)
fcList = face_list(gmtry,fcLbl,sort);

% Get the corresponding list of guard cells
bcList = zeros(size(fcList));
for i = 1:length(fcList)
    bcList(i) = max(gmtry.fcCv(fcList(i),:));
end


