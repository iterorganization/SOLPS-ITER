function [ds] = calc_dist_f(geo,flist,nf,iref)
    % Description
    %============
    % Subroutine to compute distance along a set of consecutive faces. no
    % check is made whether the cells are ordened in a 'logical' way.

    % Output variables
    % ds(1:nc)

    % Main program
    %=============
    % Compute the initial length as half the length along the first face
    ds(1) = 0.5*geo.fcHt(flist(1));

    % Loop over number of cells
    for iFc = 2:nf
      % Compute cumulative distance
      ds(iFc) = ds(iFc-1) + 0.5*(geo.fcHt(flist(iFc)) + geo.fcHt(flist(iFc-1)));
    end

    % Compute reference point
    if iref==1
        dsref = ds(1);
    elseif iref>nf
        error('iref out of bounds')
    else
        dsref = (ds(iref) + ds(iref-1))/2.0;
    end

    % Subtract reference length
    ds = ds - dsref;

    return
end
