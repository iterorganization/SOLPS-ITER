function [listcv,listfc,nn] = cv_intersections(segm,gmtry,meth)

% Set default values for some arguments, if not supplied
if ~exist('meth','var') || isempty(meth)
  meth = '';
end

nn = 1;
listcv = zeros(10000,1);
listfc = zeros(10000,1);

p1=[segm(1,1) segm(2,1)];
q1=[segm(1,2) segm(2,2)];
for ifc=1:gmtry.nFc
    vx1 = gmtry.fcVx(ifc,1);
    vx2 = gmtry.fcVx(ifc,2);
    p2 = [gmtry.vxX(vx1) gmtry.vxY(vx1)];
    q2 = [gmtry.vxX(vx2) gmtry.vxY(vx2)];
    if (intersects(p1,q1,p2,q2))
        for ii=1:2
            cv=gmtry.fcCv(ifc,ii);
            trovato = 0;
            kk =1;
            while (trovato~=1 && kk<=nn)
                if (listcv(kk)==cv)
                    trovato = 1;
                end
                kk=kk+1;
            end
            if (trovato==0)

                listcv(nn) = cv;
                listfc(nn) = ifc;
                nn = nn +1;
            end
        end

    end
end
nn = nn-1;
listcv=listcv(1:nn);
listfc=listfc(1:nn);


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
