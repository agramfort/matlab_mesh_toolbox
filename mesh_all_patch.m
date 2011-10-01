function P = mesh_all_patch(points,faces,dists,pidx)
%   MESH_ALL_PATCH   Compute all patches using Djikstra algorithm
%       [P] = MESH_ALL_PATCH(POINTS,FACES,DISTS,PIDX)
%
%   Created by Alexandre Gramfort on 2008-10-17.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


npoints = size(points,1);

if nargin < 4
    pidx = 1:npoints;
end

block_size = fix(5000^2 / npoints);

A = mesh_dist_matrix(points,faces);
disp(['Computing ',num2str(length(pidx)*length(dists)),' patches']);

P = sparse(npoints,length(pidx)*length(dists));

pidx_blocks = [0:block_size:length(pidx)-1, length(pidx)];
pidx_blocks = pidx_blocks(:);

current_idx = 1;

dists = sort(dists);

for k=1:length(pidx_blocks)-1
    progressbar(k,length(pidx_blocks)-1);
    pidx_block = pidx(pidx_blocks(k)+1:pidx_blocks(k+1));
    D = djikstra_mex(double(A),int32(pidx_block(:)),double(dists(end)));
    for didx=1:length(dists)
        P(:,(current_idx:current_idx+length(pidx_block)-1)+length(pidx)*(didx-1)) = sparse(D<=dists(didx));
    end
    current_idx = current_idx + length(pidx_block);
end

end %  function