function [ds] = calc_dist(geo,clist,nc,iref)
    % Description
    %============
    % Subroutine to compute relative distance between a set of cell
    % centers (Euclidean). The distance is computed between each
    % set of consecutive cells (i.e. x(iCv+1) - x(iCv) in 1D), but no
    % check is made whether the cells are ordened in a 'logical' way.

    % Output variables
    % ds(1:nc)

    % Main program
    %=============
    % Compute the initial length as the distance of the first cell to
    % the first boundary face
    ds(1) = 0;

    % Loop over number of cells
    for iCv = 2:nc
      % Compute cumulative distance
      ds(iCv) = ds(iCv-1) + sqrt( (geo.cvX(clist(iCv)) - geo.cvX(clist(iCv-1)) )^2  + (geo.cvY(clist(iCv)) - geo.cvY(clist(iCv-1)) )^2  );
    end

    % Compute reference point
    if iref==1
        dsref = ds(1);
    elseif iref>nc
        error('iref out of bounds')
    else
        dsref = (ds(iref) + ds(iref-1))/2.0;
    end

    % Subtract reference length
    ds = ds - dsref;

    return
end
