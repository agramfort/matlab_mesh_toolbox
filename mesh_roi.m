function [points,faces,gidx] = mesh_roi(points,faces,pidx,radius)
%   MESH_ROI   Select ROI on a mesh by region growing
%       [POINTS,FACES,GIDX] = MESH_ROI(POINTS,FACES,PIDX,RADIUS)
% 
%   Created by Alexandre Gramfort on 2009-01-03.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


% select part of the mesh
D = mesh_distance(points,faces,pidx,radius);
gidx = find(D~=Inf);
[points,faces] = mesh_remove_points(points,faces,[],find(D==Inf));

end %  function