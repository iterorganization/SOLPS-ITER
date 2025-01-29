% Given an input yin, sum everything over the poloidal balance cells 
% specified by pbCv and pbCvP
function [yout] = sumrad2(yin,pbCv,pbCvP)

    yout = zeros(size(pbCvP,1),1);

    for i = 1:size(yout,1)
        iCv1 = pbCvP(i,1);
        iCv2 = iCv1 + pbCvP(i,2) - 1;
        for j = iCv1:iCv2
            iCv = pbCv(j);
            yout(i) = yout(i) + yin(iCv);
        end
    end

end
