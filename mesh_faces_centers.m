function [centers] = mesh_faces_centers(points,faces)

% MESH_FACES_CENTERS   Compute centers of faces
%
%   SYNTAX
%       [CENTERS] = MESH_FACES_CENTERS(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-03-30.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_FACE_CENTERS';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

points_faces = points(faces',:);
centers = cumsum(points_faces);
centers = centers(3:3:end,:); % every third summation for every triangle
centers = diff([0 0 0;centers])'/3; % average of each summation
centers = centers';

end %  function
