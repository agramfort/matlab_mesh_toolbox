function [cpoints,cfaces,cnormals] = mesh_remove_points(points,faces,normals,bidx)

% MESH_REMOVE_POINTS   Remove all faces that contain given points
%
%   SYNTAX
%       [CPOINTS,CFACES] = MESH_REMOVE_POINTS(POINTS,FACES,IDX)
%
%
%   Created by Alexandre Gramfort on 2008-01-30.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_REMOVE_POINTS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

npoints = size(points,1);
gidx = setdiff(1:npoints,bidx);
[cpoints,cfaces,cnormals] = mesh_keep_points(points,faces,normals,gidx);

end %  function

