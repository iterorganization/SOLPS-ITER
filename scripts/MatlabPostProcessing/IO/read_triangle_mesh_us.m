function triangles = read_triangle_mesh_us(fort33,fort34,fort35)
% triangles = read_triangle_mesh_us(fort33,fort34,fort35)
%
% Wrapper routine to read all triangle data at once, for unstructured solver.
%
% Returns nodes, cells, nghbr, side and cont as fiels of triangles-struct.
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% July 2022


triangles.nodes = read_ft33(fort33,1);
triangles.cells = read_ft34(fort34);
links           = read_ft35_us(fort35);

triangles.nghbr = links.nghbr;
triangles.side  = links.side;
triangles.cont  = links.cont;
triangles.plasma_cell = links.plasma_cell;

end