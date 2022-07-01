function triangles = read_triangle_mesh(fort33,fort34,fort35,ntrfrm)
% triangles = read_triangle_mesh(fort33,fort34,fort35,ntrfrm)
%
% Wrapper routine to read all triangle data at once.
%
% Returns nodes, cells, nghbr, side and cont as fiels of triangles-struct.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

if ~exist('ntrfrm','var') || isempty(ntrfrm)
    disp('read_triangle_mesh: assuming ntrfrm = 0.');
    ntrfrm = 0;
end

triangles.nodes = read_ft33(fort33,ntrfrm);
triangles.cells = read_ft34(fort34);
links           = read_ft35(fort35);

triangles.nghbr = links.nghbr;
triangles.side  = links.side;
triangles.cont  = links.cont;
triangles.ixiy  = links.ixiy;

end