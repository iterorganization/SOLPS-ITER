      function out=onSegment(p, q, r)

      out = 0;
      if ( (q(1) <= max(p(1), r(1))) && (q(1) >= min(p(1), r(1))) && (q(2) <= max(p(2), r(2))) &&  (q(2) >= min(p(2), r(2))) )
        out = 1;
      end
      return
      end