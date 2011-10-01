function [edges] = mesh_edge_faces(points,faces)
%   MESH_EDGE_FACES   Compute edges between faces
%       [EDGES] = MESH_EDGE_FACES(POINTS,FACES)
%
%   edges(k,:) = (i,j,v) means that faces i and j are adjacent and that the length
%   of the edge between face i and face j is v
%
%   Created by Alexandre Gramfort on 2008-11-16.
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

edges_weights = points(ii1,:) - points(jj1,:);
edges_weights = edges_weights.*edges_weights;
edges_weights = sqrt(sum(edges_weights,2));

edges = [ff1,ff2,edges_weights];
edges = [edges; ff2,ff1,edges_weights];

end %  function