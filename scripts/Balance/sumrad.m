% Given a logical array specifying the balance volume, find radially-summed
% values along each row of that volume
function yout = sumrad(yin,indpol,geomb2)
    rightix = geomb2.rightix+1;
    rightiy = geomb2.rightiy+1;
    topix = geomb2.topix+1;
    topiy = geomb2.topiy+1;
    % Go to the bottom left of indpol:
    [ix,iy]=ind2sub(size(indpol),find(indpol,1));
    % For poloidally consecutive points in indpol, sum radially:
    yout = [];
    ixout = 1;
    while true
        yout(ixout) = yin(ix,iy);
        iyscan = iy;
        ixscan = ix;
        while indpol(topix(ixscan,iyscan),topiy(ixscan,iyscan)) && ...
              topiy(ixscan,iyscan)~=iyscan
            ixscan = topix(ixscan,iyscan);
            iyscan = topiy(ixscan,iyscan);
            yout(ixout) = yout(ixout)+yin(ixscan,iyscan);
        end
        ixout = ixout+1;
        if indpol(rightix(ix,iy),rightiy(ix,iy))
            ix = rightix(ix,iy);
            iy = rightiy(ix,iy);
        else
            break;
        end
    end
end