function D = mesh_distance(points,faces,pidx,dist_max)
%   MESH_DISTANCE   Compute distance maps using Djikstra algorithm
%       [D] = MESH_DISTANCE(POINTS,FACES,PIDX,DIST_MAX)
% 
%   Created by Alexandre Gramfort on 2008-10-17.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


if isempty(dist_max)
    dist_max = -1;
end

A = mesh_dist_matrix(points,faces);
disp('Running Djikstra algorithm');
D = djikstra_mex(double(A),int32(pidx(:)),double(dist_max));
D(D > 10^30) = Inf;

end %  function