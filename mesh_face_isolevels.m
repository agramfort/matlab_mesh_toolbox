function [isolevels] = mesh_face_isolevels(faces,isovalues)

% MESH_FACE_ISOLEVELS   Compute mesh isolevels
%
%   SYNTAX
%       [ISOLEVELS] = MESH_FACE_ISOLEVELS(FACES,ISOVALUES)
%
%   Created by Alexandre Gramfort on 2008-03-10.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_FACE_ISOLEVELS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

isolevels = {};

nfaces = size(faces,1);
npoints = double(max(faces(:)));

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

isovalues = sparse(isovalues);

for l=1:size(isovalues,2)
    spmat = sparse(ff1,ff2,xor(isovalues(ff1,l),isovalues(ff2,l)),nfaces,nfaces);
    [tmp1,tmp2,ii] = find(spmat.*sparse(ff1,ff2,ii1,nfaces,nfaces));
    [tmp1,tmp2,jj] = find(spmat.*sparse(ff1,ff2,jj1,nfaces,nfaces));
    isolevels{l} = [ii,jj];
end