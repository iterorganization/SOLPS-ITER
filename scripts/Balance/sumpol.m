% Given a logical array specifying the balance volume, find poloidally-summed
% values along each ring of that volume
% function yout = sumpol(yin,indrad)
%     yout = [];
%     for iy=1:size(yin,2)
%         inds = find(indrad(:,iy));
%         if ~isempty(inds)
%             yout = [yout,sum(yin(inds,iy))];
%         end
%     end
% end

% Given a logical array specifying the balance volume, find radially-summed
% values along each row of that volume
function yout = sumpol(yin,indrad,geomb2)
    rightix = geomb2.rightix+1;
    rightiy = geomb2.rightiy+1;
    topix = geomb2.topix+1;
    topiy = geomb2.topiy+1;
    yout = [];
    % Go to the bottom left of indpol:
    [ix,iy]=ind2sub(size(indrad),find(indrad,1));
    % For radially consecutive points in indrad, sum poloidally:
    yout = [];
    iyout = 1;
    while true
        yout(iyout) = yin(ix,iy);
        iyscan = iy;
        ixscan = ix;
        while indrad(rightix(ixscan,iyscan),rightiy(ixscan,iyscan))
            ixscan = rightix(ixscan,iyscan);
            iyscan = rightiy(ixscan,iyscan);
            yout(iyout) = yout(iyout)+yin(ixscan,iyscan);
        end
        iyout = iyout+1;
        if indrad(topix(ix,iy),topiy(ix,iy)) && ...
           topiy(ixscan,iyscan)~=iyscan
            ix = topix(ix,iy);
            iy = topiy(ix,iy);
        else
            break;
        end
    end
end