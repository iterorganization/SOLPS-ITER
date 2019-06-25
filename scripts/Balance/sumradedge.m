% Given a logical array specifying the balance volume, find radially-summed
% values of edge-centred quantities along the poloidal length of that volume
function yout = sumradedge(yin,indpol,comuse)

    indpoledge = indpol;
    rightix = comuse.rightix+1;
    rightiy = comuse.rightiy+1;
    topix = comuse.topix+1;
    topiy = comuse.topiy+1;
    
    % Add an extra true cell to the rightmost edge of indpol to get indpoledge:
    for iy = 1:comuse.ny
        ixlast = find(indpol(:,iy),1,'last');
        if ~isempty(ixlast)
            indpoledge(rightix(ixlast,iy),rightiy(ixlast,iy)) = true;
        end
    end
    
    % Go to the bottom left of indpol:
    [ix,iy]=ind2sub(size(indpol),find(indpol,1));
    % For poloidally consecutive points in indpol, sum radially:
    yout = [];
    ixout = 1;
    while true
        yout(ixout) = yin(ix,iy);
        iyscan = iy;
        ixscan = ix;
        while indpoledge(topix(ixscan,iyscan),topiy(ixscan,iyscan)) && ...
              topiy(ixscan,iyscan)~=iyscan
            ixscan = topix(ixscan,iyscan);
            iyscan = topiy(ixscan,iyscan);
            yout(ixout) = yout(ixout)+yin(ixscan,iyscan);
        end
        ixout = ixout+1;
        if indpol(ix,iy)
            ix = rightix(ix,iy);
            iy = rightiy(ix,iy);
        else
            break;
        end
    end
end