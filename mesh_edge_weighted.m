function [edge_weighted] = mesh_edge_weighted(points,faces)

% MESH_EDGE_WEIGHTED   Compute edge weights for cut length
%
%   SYNTAX
%       [edge_weighted] = MESH_EDGE_WEIGHTS(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-03-30.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


npoints = size(points,1);
nfaces = size(faces,1);

faces = double(faces);
edges = sparse(faces(:,1),faces(:,2),1:nfaces,npoints,npoints);
edges = edges + sparse(faces(:,2),faces(:,3),1:nfaces,npoints,npoints);
edges = edges + sparse(faces(:,3),faces(:,1),1:nfaces,npoints,npoints);

edges(mesh_edges(faces)==1) = 0;

[ii,jj,ff] = find(edges);
edges_upper_idx = find(ii > jj);
edges_upper = sparse(ii(edges_upper_idx),jj(edges_upper_idx),ff(edges_upper_idx),npoints,npoints);

edges_lower_idx = find(ii < jj);
edges_lower = sparse(ii(edges_lower_idx),jj(edges_lower_idx),ff(edges_lower_idx),npoints,npoints);

edges_lower = edges_lower';

[ii1,jj1,ff1] = find(edges_upper);
[ii2,jj2,ff2] = find(edges_lower);

assert(all(ii1==ii2))
assert(all(jj1==jj2))

face_centers = mesh_faces_centers(points,faces);
edges_dual = face_centers(ff1,:) - face_centers(ff2,:);
weights = sqrt(sum(edges_dual.*edges_dual,2));

edge_weighted = [ii1,jj1,weights];
