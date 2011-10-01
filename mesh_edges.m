function [edges] = mesh_edges(faces)

% MESH_EDGES   Returns sparse matrix with edges number
%
%   SYNTAX
%       [EDGES] = MESH_EDGES(FACES)
%
%   Created by Alexandre Gramfort on 2008-03-10.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_EDGES';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

faces = double(faces);
npoints = max(faces(:));
nfaces = size(faces,1);
edges = sparse(faces(:,1),faces(:,2),ones(1,nfaces),npoints,npoints);
edges = edges + sparse(faces(:,2),faces(:,3),ones(1,nfaces),npoints,npoints);
edges = edges + sparse(faces(:,3),faces(:,1),ones(1,nfaces),npoints,npoints);

edges = edges + edges';

end %  function
