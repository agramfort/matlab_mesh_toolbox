function [labels] = mesh_metis(points,faces,nclusters,options)

% MESH_METIS   split mesh using metis
%
%   SYNTAX
%       [LABELS] = MESH_METIS(A,NBCLUSTER)
%
%   You need to install the command "metismex" from package meshpart :
%   available here : http://www.cerfacs.fr/algor/Softs/MESHPART/
%
%   Created by Alexandre Gramfort on 2008-01-31.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.



nfaces = size(faces,1);

if nargin<4
    options.null = 0;
end

if ~isfield(options, 'G')
    options.G = [];
end
G = options.G;

if ~isfield(options, 'use_kway')
    options.use_kway = false;
end
use_kway = options.use_kway;

if ~isfield(options, 'use_mean')
    options.use_mean = false;
end
use_mean = options.use_mean;

if isfield(options, 'null')
    options = rmfield(options,'null');
end

A = mesh_adjacency(faces);

if ~isempty(G) % Use columns of G to compute similarity
    [ii,jj] = find(A);
    good_edge_idx = find(ii<jj);
    ii = ii(good_edge_idx);
    jj = jj(good_edge_idx);

    nedges = length(ii);
    npoints = size(G,2);

    block_idx = [1:500:(nedges-1),nedges];

    for b=1:length(block_idx)-1
        progressbar(b,length(block_idx)-1);
        bidx = block_idx(b):block_idx(b+1);
        if use_mean
            dists = (G(:,ii(bidx))+G(:,jj(bidx)))/2;
        else
            dists = (G(:,ii(bidx))-G(:,jj(bidx)));
        end
        dists = sum(dists.*dists);
        A(sub2ind(size(A),ii(bidx),jj(bidx))) = dists(:);
        A(sub2ind(size(A),jj(bidx),ii(bidx))) = dists(:);
    end

    [ii,jj,vv] = find(A);
    vv = max(max(vv)) - vv; % cut should go through the minimum weights
    vv = vv ./ max(vv) * double(int32(Inf)); % since weights are converted to integers in metis
    vv = log(1+vv(:));
    A = sparse(ii,jj,vv,size(A,1),size(A,2));
end

[components] = mesh_components(faces);

npoints = size(points,1);
labels = zeros(npoints,1);

ncomponents = max(components);

for c=1:ncomponents
    cidx = find(components==c);
    if use_kway
        map = metismex('PartGraphKway',A(cidx,cidx),nclusters);
    else
        map = metismex('PartGraphRecursive',A(cidx,cidx),nclusters);
    end
    labels(cidx) = max(labels(:))+1+double(map(:));
end
