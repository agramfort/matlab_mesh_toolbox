function [P] = mesh_geodesic_patch(points,faces,sigmas,pidx)
%   MESH_GEODESIC_PATCH   Compute geodesic patches using Djikstra algorithm
%       [P,D] = MESH_GEODESIC_PATCH(POINTS,FACES,DISTS,PIDX)
%
%   Created by Alexandre Gramfort on 2008-10-17.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


npoints = size(points,1);

if nargin < 4
    pidx = 1:npoints;
end

block_size = fix(5000^2 / npoints);

A = mesh_dist_matrix(points,faces);
disp(['Computing ',num2str(length(pidx)*length(sigmas)),' patches']);

P = sparse(npoints,length(pidx)*length(sigmas));

pidx_blocks = [0:block_size:length(pidx)-1, length(pidx)];
pidx_blocks = pidx_blocks(:);

current_idx = 1;

sigmas = sort(sigmas);

dist_max = 2*sigmas(end); % Get 95% of the density

for k=1:length(pidx_blocks)-1
    progressbar(k,length(pidx_blocks)-1);
    pidx_block = pidx(pidx_blocks(k)+1:pidx_blocks(k+1));
    Dblock = djikstra_mex(double(A),int32(pidx_block(:)),double(dist_max));
    Dblock(Dblock > dist_max) = Inf;
    for sidx=1:length(sigmas)
        P(:,(current_idx:current_idx+length(pidx_block)-1)+length(pidx)*(sidx-1)) = sparse(exp(- Dblock / sigmas(sidx)));
    end
    current_idx = current_idx + length(pidx_block);
end

end %  function