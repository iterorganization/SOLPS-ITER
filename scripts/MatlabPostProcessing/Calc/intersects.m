function out = intersects(p1,q1,p2,q2)
% out = intersects(p1,q1,p2,q2)
%
% Checks whether two segments defined by points [p1, p2] and [q1, q2]
% intersect or not.
%

      o1 = orient(p1, q1, p2);
      o2 = orient(p1, q1, q2);
      o3 = orient(p2, q2, p1);
      o4 = orient(p2, q2, q1);
      
      out = 1 ;

      if (o1 ~= o2 && o3 ~= o4) 
          return
      end
  
      if (o1 == 0 && onSegment(p1, p2, q1)) 
          return
      end
  
      if (o2 == 0 && onSegment(p1, q2, q1)) 
          return
      end
  
      if (o3 == 0 && onSegment(p2, p1, q2)) 
          return 
      end
  
      if (o4 == 0 && onSegment(p2, q1, q2)) 
          return 
      end
      out = 0;
          
end
