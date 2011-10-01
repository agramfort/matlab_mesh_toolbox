function mesh_display_faces(points,faces,fidx)
%   MESH_DISPLAY_FACES   Show some faces and their neighboring faces
%       [] = MESH_DISPLAY_FACES(POINTS,FACES,FIDX)
% 
%   Created by Alexandre Gramfort on 2008-12-01.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


nfaces = size(faces,1);
faces = double(faces);
[vertex_numbering,I] = sort(faces(:)); % sorted Vertex numbers
faces_numbering = rem(I-1,nfaces)+1; % triangle number for each Vertex
centers = mesh_faces_centers(points,faces)';
face_normals = mesh_face_normals(points,faces);

for ii = 1:length(fidx)

    % get the points for the bad face
    pidx = faces(fidx(ii),:);
    pidx = pidx(:)'; % ensure row vector

    [ffidx, ignore] = find(vertex_numbering(:,ones(1,length(pidx))) == (ones(size(vertex_numbering,1),1)*pidx));
    ffidx = faces_numbering(ffidx); % the faces attached to these points
    ffidx = unique(ffidx); % ensure unique
    niffidx = ffidx;
    niffidx(find(niffidx == fidx(ii))) = []; % remove the ith face

    smart_figure(['Face ',num2str(fidx(ii))]);
    clf
    % not the ith face
    h = patch('vertices',points,'faces',faces(niffidx,:),'facecolor','r','edgecolor','k');
    % the ith face
    hi = patch('vertices',points,'faces',faces(fidx(ii),:),'facecolor','g');

    axis square;
    axis off;
    axis tight;
    axis equal;

    hold on
    plot3(centers(1,ffidx),centers(2,ffidx),centers(3,ffidx),'*')
    quiver3(centers(1,ffidx),centers(2,ffidx),centers(3,ffidx),...
      face_normals(1,ffidx),face_normals(2,ffidx),face_normals(3,ffidx),0.25);
    set(h,'FaceAlpha',.8)
    hold off
    cameratoolbar('Show'); % activate the camera toolbar
    ret = cameratoolbar; % for strange reason, this activates the default orbit mode.
    drawnow

end

end %  function