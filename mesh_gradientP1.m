function grad = mesh_gradientP1(points,faces)
%   MESH_GRADIENT   Compute mesh gradient with P1 discretization
%       [GRAD] = MESH_GRADIENTP1(points,faces)
% 
%   Created by Alexandre Gramfort on 2008-11-04.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


nfaces = size(faces,1);
npoints = size(points,1);

faces = double(faces'-1);
points = double(points');

grad = mesh_gradient_mex(points,faces);
grad = grad';
grad = sparse(grad(:,1)+1,grad(:,2)+1,grad(:,3),3*nfaces,npoints);

end %  function