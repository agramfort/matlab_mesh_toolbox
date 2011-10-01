function [A] = mesh_adjacency(faces)
%   MESH_ADJACENCY   Compute mesh adjacency matrix
%       [A] = MESH_ADJACENCY(FACES)
% 
%   A(i,j) = 1 iff (i,j) is an edge of the mesh.
%
%   Created by Alexandre Gramfort on 2008-06-25.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_ADJACENCY';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

edges = mesh_edges(faces);
A = double(edges>0);

end %  function
