function [new_points,A] = mesh_smooth(points,faces,options)
% MESH_SMOOTH - Smooth mesh
% 
%   SYNTAX
%       [NEW_POINTS,A] = mesh_smooth(POINTS,FACES,OPTIONS)
%
% Remarks: mesh_smooth implements the following expression
% new_points(i,:)=points(i,:)+a/N*sum(points(neighbor_i,:)-points(i,:))
% where points(i,:) is the ith point, N is the number of neighbors of this point, a is a smoothing
% constant, points(neighbor_j,:) is jth neighbor of ith point. Sum goes over all neighbors of ith
% point.


me = 'MESH_SMOOTH';

if nargin == 0 % avoid errors when no arguments
    options.neighbors = {};
end

if nargin < 3
    options.null = 1;
end

if ~isfield(options, 'niter')
    options.niter = 10;
end
niter = options.niter;

if ~isfield(options, 'smoothing')
    options.smoothing = 0.75;
end
smoothing = options.smoothing;

if ~isfield(options, 'neighbors')
    options.neighbors = mesh_connectivity(points,faces);
end
neighbors = options.neighbors;

if ~isfield(options,'fix_border')
    options.fix_border = false;
end
fix_border = options.fix_border;

if ~isfield(options, 'verbose')
    options.verbose = true;
end
verbose = options.verbose;

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

npoints = size(points,1);
fix_points = zeros(1,npoints);
if fix_border
    fix_points(mesh_border(faces)) = 1;
end

if verbose
    disp('Smoothing Mesh')
end

% compute smoothing matrix (simple laplacian)
options.fix_points = fix_points;
A = mesh_smoothing_matrix(points,faces,options);

new_points = points;
for i=1:niter
    new_points = A*new_points;
end

end %  function
