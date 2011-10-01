function [cpoints,cfaces,cnormals] = mesh_keep_points(points,faces,normals,gidx)

% MESH_KEEP_POINTS   Keep all faces that contain given points
%
%   SYNTAX
%       [CPOINTS,CFACES] = MESH_KEEP_POINTS(POINTS,FACES,IDX)
%
%   Created by Alexandre Gramfort on 2008-01-30.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_KEEP_POINTS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

npoints = size(points,1);
% Prune faces
gidx_inv = invperm(gidx);
if length(gidx_inv) < npoints;
    gidx_inv(npoints) = 0;
end
faces_zero_filled = reshape(gidx_inv(faces(:)),[],3);
[ii,jj] = find(faces_zero_filled == 0); ii = unique(ii);
cfaces = faces_zero_filled(setdiff(1:size(faces,1),ii),:);
cpoints = points(gidx,:);
if ~isempty(normals)
    cnormals = normals(gidx,:);
else
    cnormals = [];
end

end %  function

