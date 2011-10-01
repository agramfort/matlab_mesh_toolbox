function face_normals = mesh_face_normals(points,faces)
%   MESH_FACE_NORMALS   Compute face normals
%       [FACE_NORMALS] = MESH_FACE_NORMALS(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-12-01.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


points_from_faces = points(faces',:);
diff_points_from_faces = diff(points_from_faces);
diff_points_from_faces(3:3:end,:) = []; % remove the transition between triangles
weighted_normals = cross(diff_points_from_faces(1:2:end,:)',diff_points_from_faces(2:2:end,:)')/2;
face_areas = sqrt(sum(weighted_normals .* weighted_normals)); % the area
face_normals = weighted_normals ./ (face_areas([1 1 1],:)); % normalize them

end %  function