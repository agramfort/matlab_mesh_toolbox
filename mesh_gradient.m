function grad = mesh_gradient(points,faces,options)
%   MESH_GRADIENT   Compute mesh gradient with conformal weights
%       [GRAD] = MESH_GRADIENT(POINTS,FACES,OPTIONS)
% 
%   Created by Alexandre Gramfort on 2008-11-04.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


if nargin<3
    options.null = 0;
end

if ~isfield(options, 'normalize')
    options.normalize = true;
end
normalize = options.normalize;

if isfield(options, 'null')
    options = rmfield(options,'null');
end

nfaces = size(faces,1);
npoints = size(points,1);

faces = double(faces);

% Compute conformal weights
W = sparse(npoints,npoints);
for ii=1:3
    i1 = mod(ii-1,3)+1;
    i2 = mod(ii  ,3)+1;
    i3 = mod(ii+1,3)+1;

    pp = points(faces(:,i2),:) - points(faces(:,i1),:);
    qq = points(faces(:,i3),:) - points(faces(:,i1),:);
    pp = normalize_rows(pp);
    qq = normalize_rows(qq);
    ang = acos(sum(pp.*qq,2));
    W = W + sparse(faces(:,i2),faces(:,i3),cot(ang),npoints,npoints);
    W = W + sparse(faces(:,i3),faces(:,i2),cot(ang),npoints,npoints);
end

%% compute list of edges
[ii,jj,s] = find(W);
I = find(ii<jj);
ii = ii(I);
jj = jj(I);
s = sqrt(s(I));

nedges = length(ii);

%% build sparse matrix
s = [s; -s];
is = [(1:nedges)'; (1:nedges)'];
js = [ii(:); jj(:)];
grad = sparse(is,js,s,nedges,npoints);

if normalize
    grad = grad*diag(sum(W,2).^(-1/2));
end

end %  function