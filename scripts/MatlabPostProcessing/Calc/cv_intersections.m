function [listcv,listfc,nncv] = cv_intersections(segment,gmtry,meth)
% [listcv,listfc,nn] = cv_intersections(segment,gmtry,meth)
%
% Function to compute the cvs and faces intersected by a given segment.
% Ordering based on cvX or cvY sorting can be additionally performed.
% The number of cvs intersected is also returned.
%

% Set default values for some arguments, if not supplied
if ~exist('meth','var') || isempty(meth)
  meth = '';
end

nncv = 1;
nnfc = 0;
listcv = zeros(gmtry.nCv,1);
listfc = zeros(gmtry.nFc,1);

p1=[segment(1,1) segment(2,1)];
q1=[segment(1,2) segment(2,2)];
for ifc=1:gmtry.nFc
    vx1 = gmtry.fcVx(ifc,1);
    vx2 = gmtry.fcVx(ifc,2);
    p2 = [gmtry.vxX(vx1) gmtry.vxY(vx1)];
    q2 = [gmtry.vxX(vx2) gmtry.vxY(vx2)];
    if (intersects(p1,q1,p2,q2))
        nnfc = nnfc + 1;
        listfc(nnfc) = ifc;
        for ii=1:2
            cv=gmtry.fcCv(ifc,ii);
            found = 0;
            kk = 1;
            while (found~=1 && kk<=nncv)
                if (listcv(kk)==cv)
                    found = 1;
                end
                kk = kk+1;
            end
            if (found==0)
                listcv(nncv) = cv;
                % listfc(nncv) = ifc;
                nncv = nncv + 1;
            end
        end
    end
end
nncv = nncv-1;
% nnfc = nncv;
listcv=listcv(1:nncv);
listfc=listfc(1:nnfc);
% [vals, ~, idx] = unique(listfc(1:nnfc));
% counts = accumarray(idx, 1);
% 
% duplicates = vals(counts > 1)
% 
% isDup = false(size(listfc(1:nnfc)));
% [~, firstIdx] = unique(listfc(1:nnfc), 'first');
% isDup(setdiff(1:numel(listfc(1:nnfc)), firstIdx)) = true;
% 
% listfc=listfc(1:nnfc);


% Sort list
switch meth
    case 'X'
        [~,order] = sort(gmtry.cvX(listcv));
        listcv = listcv(order);
    case 'Y'
        [~,order] = sort(gmtry.cvY(listcv));
        listcv = listcv(order);
end



end
