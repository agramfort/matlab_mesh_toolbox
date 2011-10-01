function [vects,vals] = mesh_eigenvectors(points,faces,k)

% MESH_EIGENVECTORS   Compute eigenfunctions of the mesh laplacian
%
%   SYNTAX
%       [VECTS] = MESH_EIGENVECTORS(POINTS,FACES,K)
%
%   K : number of eigenvectors to compute
%
%   Created by Alexandre Gramfort on 2008-02-03.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_EIGENVECTORS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

% L = mesh_conformal_laplacian(points,faces); % not implemented
L = mesh_combinatorial_laplacian(faces); % faster
[vects,vals] = eigs(L,k,'sm');
% [vects,vals,tmp] = svd(full(L));

vects = vects(:,end:-1:1);
vals = vals(:,end:-1:1);

end %  function
