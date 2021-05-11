function [centre] = intcell_us(nCv,gmtry,wght,face)

      centre=zeros(nCv,1);
      
      for iCv = 1: nCv
        wghtsum = 0.0;
        for iFc = 1:gmtry.cvFcP(iCv,2)
          wghtsum = wghtsum + wght(gmtry.cvFcP(iCv,1) + iFc - 1);
          centre(iCv) = centre(iCv) + ...
            face(gmtry.cvFc(gmtry.cvFcP(iCv,1) + iFc - 1))*...
             wght(gmtry.cvFcP(iCv,1) + iFc - 1);
        end
        centre(iCv) = centre(iCv)/wghtsum;
      end

      return
 end