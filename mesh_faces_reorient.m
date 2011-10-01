function faces = mesh_faces_reorient(points,faces)
%   MESH_FACES_REORIENT   Reorient the faces with respect to the center of the mesh
%       [FACES] = MESH_FACES_REORIENT(POINTS,FACES)
% 
%   Created by Alexandre Gramfort on 2008-10-17.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


G = mean(points);

if size(points,1)<size(points,2)
    points = points';
end
if size(faces,1)<size(faces,2)
    faces = faces';
end
npoints = size(points,1);
nfaces = size(faces,1);

% center of faces
Cf = (points(faces(:,1),:) + points(faces(:,2),:) + points(faces(:,3),:))/3;
Cf = Cf - repmat(G,[nfaces,1]);
% normal to the faces
V1 = points(faces(:,2),:)-points(faces(:,1),:);
V2 = points(faces(:,3),:)-points(faces(:,1),:);
N = [V1(:,2).*V2(:,3) - V1(:,3).*V2(:,2) , ...
    -V1(:,1).*V2(:,3) + V1(:,3).*V2(:,1) , ...
     V1(:,1).*V2(:,2) - V1(:,2).*V2(:,1) ];
% dot product
s = sign(sum(N.*Cf));
% reverse faces
I = find(s>0);
faces(I,:) = faces(I,3:-1:1); 

nflip = sum(s>0);
disp(['Flipping ',num2str(nflip),' faces']);

end %  function