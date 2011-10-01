function D = mesh_all_distances(points,faces)
%   MESH_ALL_DISTANCES   Compute all pairwise distances on the mesh
%       [D] = MESH_ALL_DISTANCES(POINTS,FACES)
% 
%   Compute all pairwise distances on the mesh based on edges lengths
%   using Floyd-Warshall algorithm
%
%   Created by Alexandre Gramfort on 2008-10-17.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


A = mesh_dist_matrix(points,faces);
disp('Running Floyd-Warshall algorithm');
D = floyd_warshall_mex(full(double(A)));

end %  function