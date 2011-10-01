function [P,nb_points_per_patch] = mesh_leadfield_patches(G,tol,options)
%   MESH_LEADFIELD_PATCHES   Compute patches using RDMs with a leadfield
%       [P,NB_POINTS_PER_PATCH] = MESH_LEADFIELD_PATCHES(G,TOL,OPTIONS)
% 
%   Created by Alexandre Gramfort on 2008-10-31.
%   Copyright (c) 2007 Alexandre Gramfort. All rights reserved.


if nargin<3
    options.null = 0;
end

if ~isfield(options, 'block_size')
    options.block_size = 300;
end
block_size = options.block_size;

if ~isfield(options, 'use_rdm')
    options.use_rdm = true;
end
use_rdm = options.use_rdm;

if isfield(options, 'null')
    options = rmfield(options,'null');
end

if use_rdm
    G = normalize_columns(G);
end

npoints = size(G,2);

block_limits = [1:block_size:npoints,npoints+1];

ii = [];
jj = [];

% for k=1:1
for k=1:(length(block_limits)-1);
    progressbar(k,length(block_limits)-1);
    block_idx = block_limits(k):(block_limits(k+1)-1);

    [iik,jjk] = find(sqrt(2 - 2*G(:,block_idx)' * G(:,block_limits(k):end)) <= tol);

    iik = iik+block_limits(k)-1;
    jjk = jjk+block_limits(k)-1;
    ii = [ii;iik];
    jj = [jj;jjk];
end

P = sparse(ii,jj,ones(length(ii),1),npoints,npoints);
P = (P + P') > 0;

% normalize columns
nb_points_per_patch = sum(P,1);
P = P * spdiags(1./sqrt(nb_points_per_patch(:)),0,npoints,npoints);

end %  function