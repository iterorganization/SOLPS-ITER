function [out] = ft46_to_triangle_data(field,nCi,ft35)
% [out] = ft46_to_triangle_data(field,nCi,ft35)
%
% Inputs
% field:    input field from an unstructured fort.46 output file.
% nCi:      number of internal plasma cells
% ft35:     fort.35 data from the triangle grid
%
% Description:
% field will be a file which will contain nCi internal B2.5 plasma cells,
% followed by the triangles in the void region (if any). In this function we
% translate this back to the data on the triangle grid.

list = ft35.plasma_cell;
% for each triangle we have either a positive integer indicating the B2.5
% plasma cell. Otherwise we have -1, which indicates it is a triangle in a
% void region. 

ntri = length(list); % number of triangles
out = zeros(ntri,size(field,2));

if list(1) == -1
     %% fort.35 has first the void triangles, then those inside plasma regions
    doing_cells = 0;
    for i=1:ntri
        if list(i) == -1
            out(i,:) = field(i+nCi,:);
            if doing_cells == 1
                error(['this function expects an ordered list where the triangles in the void regions', ...
                       'all come before those that are in B2.5 cells'])
            end
        else
            out(i,:) = field(list(i),:);
            doing_cells = 1;
        end
    end
else
    %% fort.35 has first the cells inside plasma regions, then void triangles
    doing_cells = 1;
    for i=1:ntri
        if list(i) > 0
            out(i,:) = field(list(i),:);
            if doing_cells == 0
                error(['this function expects an ordered list where the triangles in the void regions', ...
                       'all come after those that are in B2.5 cells'])
            end
        else
            doing_cells = 0;
            out(i,:) = field(i-nCi,:);
        end
    end
end


end
