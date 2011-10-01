function [curvature_thresh,curvature_sigmoid,curvature] = mesh_curvature(points,faces,options)
%   MESH_CURVATURE   Compute curvature of a triangulation
%       [CURVATURE_THRESH,CURVATURE_SIGMOID,CURVATURE] = MESH_CURVATURE(POINTS,FACES,OPTIONS)
% 
%   curvature returned is the surface curvature
%   curvature_sigmoid returned is the curvature weighted by a sigmoid
%   curvature_thresh returned is the curvature thresholded (used for visualization)
%
%   Remarks: mesh_curvature uses an approximation of mean curvature. It calculates the mean angle between
%   the surface normal of a vertex and the edges formed by the vertex and the neighbouring ones.
%
%   Created by Alexandre Gramfort on 2008-06-26.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_CURVATURE';

if nargin<3
    options.null = 0;
end

if nargin == 0 % avoid errors when no arguments
    options.normals = [];
    options.neighbors = {};
end

if ~isfield(options, 'sigmoid_const')
    options.sigmoid_const = 10;
end
sigmoid_const = options.sigmoid_const;

if ~isfield(options, 'show_sigmoid')
    options.show_sigmoid = 0;
end
show_sigmoid = options.show_sigmoid;

if ~isfield(options, 'normals')
    options.normals = mesh_normals(points,faces);
end
normals = options.normals;

if nargin == 0
    eval(['help ',lower(me)])
    options = rmfield(options,'null')
    return
end

npoints = size(points,1);

% Make the normals unit norm (assume normals are already normalized)
% normalsnrm = sqrt(sum(normals.*normals,2));

% Compute curvature
% disp('Computing Curvature')

edges = (mesh_edges(faces)>0);
[ii,jj] = find(edges);
nneighbors  = sum(edges,2); % number of neighbors
nneighbors_inv = 1./nneighbors;
nneighbors_inv(isnan(nneighbors_inv)) = 0;

edgevectors = points(jj,:)-points(ii,:);
normals = normals(ii,:);
edgevectors = normalize_rows(edgevectors);
curvature = sparse(ii,jj,acos(sum(normals.*edgevectors,2)),npoints,npoints);
curvature = (sum(curvature,2).*nneighbors_inv)-pi/2;

% Old code
% 
% curvature = zeros(npoints,1);
% curvature_sigmoid = zeros(npoints,1);
% for i=1:npoints %for all vertices
%     progressbar(i,npoints);
%     if nneighbors > 0
%         edgevector   = points(neighbors{i},:)-repmat(points(i,:),nneighbors(i),1); %vectors joining vertex with neighbors
%         edgevector   = colnorm(edgevector');
%         curvature(i) = mean(acos(normals(i,:)*edgevector))-pi/2;
%     end
% end

% apply thresh
if ~isfield(options, 'thresh')
    options.thresh = 0.05;
end
thresh = options.thresh;

if ~isfield(options, 'thresh_val')
    options.thresh_val = 0.8;
end
thresh_val = options.thresh_val;

curvature_thresh = curvature;
curvature_thresh( curvature_thresh >= 0 ) = 0.6;
curvature_thresh( curvature_thresh < 0 )  = 0.2;

% curvature_thresh( curvature_thresh >= 0 ) = thresh_val;
% curvature_thresh( curvature_thresh < 0 )  = -thresh_val;

curvature_sigmoid = 1./(1+exp(-curvature .* sigmoid_const))-0.5;
curvature_sigmoid = 2*curvature_sigmoid; % set curvature_sigmoid between -1 and 1

if(show_sigmoid)
    x=-pi/2:0.01:pi/2;
    y=1./(1+exp(-x*sigmoid_const))-0.5;
    figure;
    plot(x,y)
    grid on;
    title('Transition between negative and positive curvature');
end

% smooth curvature with laplacian
if ~isfield(options, 'niter_smooth')
    options.niter_smooth = 0;
end
niter_smooth = options.niter_smooth;

if ~isfield(options, 'smoothing')
    options.smoothing = 0.1;
end

if niter_smooth>0
    L = mesh_smoothing_matrix(points,faces,options);
    for n=1:niter_smooth
        curvature_thresh = L * curvature_thresh;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Anrm,norms] = colnorm(A)

m = size(A,1);
norms = sqrt(sum(A.*conj(A)));
ndx = find(norms>0);
Anrm = zeros(size(A));
Anrm(:,ndx) = A(:,ndx) ./ norms(ones(m,1),ndx); % normalize any non-zero columns
