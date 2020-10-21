      function out=orient(p, q, r)

      val = (q(2) - p(2)) * (r(1) - q(1)) - (q(1) - p(1)) * (r(2) - q(2));
 
      if (val > 0) 
        out = 1;
        return
      else
      	if (val < 0)
            out = 2;
            return
        else
            out = 0;
            return
        end
      end
      end