function [D] = mesh_dist_matrix(points,faces,distfct)

% MESH_EUCLIDIAN_DIST_MATRIX   Compute matrix of distances between connected points
%
%   SYNTAX
%       [D] = MESH_DIST_MATRIX(POINTS,FACES,DISTFCT)
%
%   Created by Alexandre Gramfort on 2008-02-14.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_DIST_MATRIX';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

if nargin < 3
    distfct = @(x,y) sqrt(sum((x-y).*(x-y),2)); % Norm 2
end

A = mesh_adjacency(faces);

[ii,jj] = find(sparse(A));

npoints = size(points,1);

vv = distfct(points(ii,:),points(jj,:));
D = sparse(ii,jj,vv,npoints,npoints);

end %  function
