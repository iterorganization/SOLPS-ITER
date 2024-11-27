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
% values in each flux tube of that volume
function yout = sumpol(yin,indrad,geomb2,index)

    yout = zeros(geomb2.nFt,1);
    nonzero = false(geomb2.nFt,1);
    for iFt = 1:geomb2.nFt % integration in flux tube
        iCv1 = geomb2.ftCvP(iFt,1);
        iCv2 = iCv1 + geomb2.ftCvP(iFt,2) - 1;
        for i = iCv1:iCv2
            iCv = geomb2.ftCv(i);
            if indrad(iCv)
                yout(iFt) = yout(iFt) + yin(iCv);
                nonzero(iFt) = true;
            end
        end
    end

    % Eliminate the flux tubes that are absent in indrad:
    yout = yout(nonzero);

    % Sort the data according to index:
    yout = yout(index);

end