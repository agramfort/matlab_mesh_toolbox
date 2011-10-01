function [face_normals, face_areas, centers, normals, point_areas, suspect_faces, nfaces_per_point, duplicated_faces, not_twice_faces] = mesh_stats(points,faces,verbose)
%   MESH_STATS - Calculate statistics of the mesh and hunt for suspicious faces and points
%       [FACE_NORMALS, FACE_AREAS, CENTERS, NORMALS, POINT_AREAS, SUSPECT_FACES, ...
%       NFACES_PER_POINT, DUPLICATED_FACES, NOT_TWICE_FACES] = ...
%       TESSELLATION_STATS(POINTS,FACES,VERBOSE)
%
% If nargout == 0 then force verbose output
%
% OUTPUTs are:
%
% face_normals is nfaces x 3, the normal of each face
% face_areas is nfaces x 1, the area of each face
% centers is nfaces x 3, the location of the center of each face
%
% Additional calculation of the point statistics:
%
% normals is npoints x 3, the average normal assigned to each point,
%   see description below.
% point_areas is npoints x 1, the average area assigned to each point, see
%   description below.
%
% Additional calculation of properly ordered and arranged triangles
%
% suspect_faces is nfaces x 1, each element giving the number of times the triangle
%   was identified as suspicious, see calculation below.
%
% nfaces_per_point is npoints x 1, each element giving the number of faces
%   attached to a point. Points with 0 faces are unassigned, 1 and 2 faces
%   are most likely at edges.
%
% duplicated_faces, not_twice_faces
%   Each is a cell array, each element contains the one or more faces that are
%   adjacent a bad edge. duplicated_faces are adjacent an edge that was
%   specified more than once in the same direction. not_twice_faces are adjacent
%   an edge that was not specified exactly once in each direction, but are not
%   in the set of duplicated edges.
%
% SURFACE TEST
%
% This routine also performs a basic test of the ordering of the
%   points. Each face should be entered in the same CCW or CW direction. If a
%   triangle is ordered differently from it's neighbors in a smooth region, then
%   its normal vector will point in the opposite direction. A list of possible
%   problem faces will be displayed, where the figure number is the face number
%   in question. In very irregular surfaces (such as the cortex), the problem
%   face may be simply tucked in too tightly to the local surface for the
%   algorithm to catch.
%
% suspect_faces is 1 x nfaces, gives the number of tests that detected a possibly
%   bad face ordered in a direction opposite of the adjacent faces. A "patch" is
%   formed at a point by finding all faces that are attached to a given point.
%   The unweighted average of the face normals is computed, then dotted with
%   each of the face normals. A face is marked as suspect if it's normal points
%   in the opposite direction of the unweighted average normal. The process is
%   repeated for all points, so that each triangular face is included in three
%   tests. The suspect_faces is the cumulative detection score, such that
%   suspect_faces(i) == 3 indicates that all three points marked the ith face as
%   suspect. Detections of 1 and 2 indicate that only one or two of the points
%   marked the face as suspect.
%
% If verbose is true, then this routine will offer to display all triangular
%   faces that had suspect_faces == 3, i.e. all three points triggered the
%   detection.
%
% nfaces_per_point, since we are generally expecting closed surfaces in brain
%   analysis, representing cortical surfaces or boundary elements, then points
%   with 0, 1, or 2 faces only are worthy of further attention.
%
% For constant approximations across the triangle, then use face_normals and centers.
% For linear approximations, then use normalss and points.
% point_areas is the effective area spanned by a point, analogous to the face_areas
%   spanned by triangle.
%
% CALCULATION of VERTEX NORMALS and AREAS
%
% Points in a mesh are technically point discontinuities in the surface
% description, edges are line discontinuities. In a closed surface, then there
% are precisely 2(N-2) faces for N points, so there are nearly half as many
% point parameters as triangle centers representing the same surface. Hence
% point representations of linear variation across the triangles are a popular
% alternative to triangle center representation of a constant variation.
%
% The average area assigned to each point is found by dividing the area of a
%  face by three and assigning this equally to all three points. Each point
%  therefore has as its area the sum of 1/3 of the areas of the attached to the
%  point.
% The average normal is found by weighting the unit length normals of each face
%  attached to a point by the area of that face, then averaging. The length of
%  the average normal reflects this averaging.

% Function inspired by tesselation_stats.m in BrainStorm http://neuroimage.usc.edu


if ~exist('verbose','var')
   verbose = 1; % default talkative case
end

faces = double(faces);

nfaces = size(faces,1); % number of faces
npoints = size(points,1); % number of points

if nargout == 0 % Force verbose in not output
    VERBOSE = 1;
end

% --------------------------- Triangle Statistics ------------------------------
% calculate the area and normals for each triangle

if verbose
   disp(sprintf('Generating statistics for %.0f faces. . .',nfaces));
end

points_from_faces = points(faces',:);
% each set of three rows of points_from_faces is one triangle

% now difference them to get the vectors on two sides
diff_points_from_faces = diff(points_from_faces);
diff_points_from_faces(3:3:end,:) = []; % remove the transition between triangles

% now each pair of rows in diff_points_from_faces represents each triangle
% row 1 is vector from 1 to 2
% row 2 is vector from 2 to 3

% v1 = diff_points_from_faces(1:2:end,:)'; % each column is side one of a triangle
% v2 = diff_points_from_faces(2:2:end,:)'; % side two

% right-hand rule, counter-clockwise ordering of the triangle yields a positive
% upward area and normal.
% Call a fast subfunction of this function:
weighted_normals = cross(diff_points_from_faces(1:2:end,:)',diff_points_from_faces(2:2:end,:)')/2;
% each column is the normal for each triangle
% the length the vector gives the area

face_areas = sqrt(sum(weighted_normals .* weighted_normals)); % the area
face_normals = weighted_normals ./ (face_areas([1 1 1],:)); % normalize them

% now calculate the centers of each triangle
centers = cumsum(points_from_faces);
centers = centers(3:3:end,:); % every third summation for every triangle
centers = diff([0 0 0;centers])'/3; % average of each summation
% each column is the mean of the points of the triangles
% so now we know the center, area, and the normal vector of each triangle

% --------------------------- Faces Connectivity -------------------------------
% first calculate what faces go with which point

[vertex_numbering,I] = sort(faces(:)); % sorted Vertex numbers

faces_numbering = rem(I-1,nfaces)+1; % triangle number for each Vertex

% For the ith point, then faces_numbering(vertex_numbering == i) returns the indices of the
%  polygons attached to the ith point.
%
% For the set of points in the row vector sv (e.g sv = [3 5 115 121]), then use
%  [i,ignore] = find(vertex_numbering(:,ones(1,length(sv))) == (ones(size(vertex_numbering,1),1)*sv));
%  (compares the Vertex numbers to the indices, extracts the row indices into i)
%  then faces_numbering(i) returns the indices. Apply unique to clean up.

% So now we know what faces are connected to each point


% --------------------------- Points Statistics ------------------------------
% For each point, there is a neighborhood of triangles
% Find the mean of the centers of these triangles, and see if all normals are in
% the same direction away from this center.

% fast analysis, no do-loops

if verbose
   disp(sprintf('Generating statistics for %.0f points. . .',npoints));
end

% First, sort and replicate weighted norms for each point using faces_numbering
all_weighted_normals = cumsum(weighted_normals(:,faces_numbering),2);
all_averages = cumsum(face_areas(faces_numbering));

% now extract each sum
point_nidx = find(diff([vertex_numbering;Inf])); % each column where a new point starts
% pull out the sum for each point, then difference from previous point to get
% the sum for just that point
sorted_weighted_normals = diff([[0;0;0] all_weighted_normals(:,point_nidx)],1,2);
sorted_averages = diff([0 all_averages(:,point_nidx)]);

% divide by the number of faces used in the sum to get a mean
num_faces_per_patch = diff([0;point_nidx]); % the number of faces for each point
num_faces_per_patch = num_faces_per_patch(:)'; % ensure row vector
% the average weighted norm
sorted_weighted_normals = sorted_weighted_normals ./ num_faces_per_patch([1 1 1],:);
sorted_averages = sorted_averages/3; % 1/3 assignment
% the average area assigned to each point. 1/3 of the area of each triangle is
% assigned equally to it's points

% now make sure it' assigned to the right point numbers
normals = zeros(3,npoints); % each column is the average surface normal for each point
normals(:,vertex_numbering(point_nidx)) = sorted_weighted_normals;
point_areas = zeros(1,npoints);
point_areas(vertex_numbering(point_nidx)) = sorted_averages;

% ------------------------------ Surface Check ---------------------------------
% fast analysis, no do-loops

if verbose
   disp(sprintf('Examining the patch around %.0f points. . .',npoints));
end

% Want to detect if a few of the normals in a point patch are pointed in the
% opposite direction. Rather than use the weighted point normal, we will form
% the unweighted normal
% First, sort and replicate unweighted norms for each point using faces_numbering
all_norms = cumsum(face_normals(:,faces_numbering),2);
sorted_norms = diff([[0;0;0] all_norms(:,point_nidx)],1,2);
% the average unweighted norm
sorted_norms = sorted_norms ./ num_faces_per_patch([1 1 1],:);
% now make sure it' assigned to the right point numbers
point_unweighted_normal = zeros(3,npoints); % each column is the average surface normal for each point
point_unweighted_normal(:,vertex_numbering(point_nidx)) = sorted_norms;

% form the dot product of each normal with it's average normal

in_out = sign(sum(face_normals(:,faces_numbering) .* point_unweighted_normal(:,vertex_numbering)));
rev_dir = find(in_out < 0); % normals in the reverse direction.

% faces_numbering(rev_dir) gives me the Triangle numbers for ones that reversed
bad_faces = sort(faces_numbering(rev_dir));
bad_face_idx = find(diff([bad_faces;Inf])); % changes in the bad_faces numbers
nbad = diff([0;bad_face_idx]); % how many times was the triangle marked as bad

suspect_faces = zeros(1,nfaces); % number of times a face is detected as bad.
suspect_faces(bad_faces(bad_face_idx)) = nbad;

% ---------------------------- Vertex Statistics --------------------------------
% How many faces are attached to each point, including unassigned ones
nfaces_per_point = zeros(1,npoints); %
nfaces_per_point(vertex_numbering(point_nidx)) = num_faces_per_patch(:)';

% ----------------------------- Edge Statistics --------------------------------

% schematic representation of edges [odd edge point, even edge point];
% edges = faces(:,[1 2 2 3 3 1]); % each pair of columns is an edge
% The row number is the face number
% Order all of the odd columns adjacent the even columns
% First column is the odd edge number, then second column is the even edge number
edges = reshape(faces(:,[1 2 3 2 3 1]),[],2); % columns reordered for reshaping

if verbose
   disp(sprintf('Sorting %.0f edge descriptions . . .',size(edges,1)));
end

[edges,edge_direction] = sort(edges,2); % sort each row, retaining direction
% edge_direction(i,:) gives the ordering [1 2] or [2 1] for each Edge(i,:)
[edges_and_directions, edge_face_number] = sort_key([edges edge_direction]);
edge_face_number = rem(edge_face_number-1,size(faces,1))+1; % adjust the block lex ordering
% edge_face_number(i) gives us the corresponding face number for the Edge(i,:)

% so the vector [edges_and_directions(i,:) EdgeFaceNnumber(i)]
%  gives use information about the ith edge

% In a triangle manifold, each edge should have been used twice, once in each
% direction. By the keyed sorting, the directions are also sorted for each edge

% Diff the edge numberings with their directions
diff_edges_and_directions = diff([0 0 0 0; edges_and_directions]);

% Each time an edge changes, then diff catches it
nedges = sum(any(diff_edges_and_directions(:,1:2),2));

if verbose
   disp(sprintf('Examining %.0f distinct edges . . .',nedges));
end

% if an edge in the same direction was specified more than once, then we can
% detect as
ndx_duplicated_edge = find(~any(diff_edges_and_directions,2));

% if an edge is repeated properly then the difference is zero in the edge
% numbering but is different in the edge direction
ndx_repeated_edge = find(~any(diff_edges_and_directions(:,1:2),2));

% all edges should have been specified twice, find those that were not
diff_ndx = diff([0;ndx_repeated_edge]);

ndx_NotTwice = find(diff_ndx ~= 2); % something wrong with this edge
ndx_NotTwice = ndx_repeated_edge(ndx_NotTwice); % in the original edges_and_directions

% so edges_and_directions([ndx_NotTwice;ndx_duplicated_edge]) are problem edges,
% maybe duplicated between the sets. An edge specified only once would be caught
% in NotTwice only.
duplicated_edges = unique(edges_and_directions(ndx_duplicated_edge,1:2),'rows');
not_twice_edges = unique(edges_and_directions(ndx_NotTwice,1:2),'rows');

% remove the duplicated edges from the not Twice
not_twice_edges = setdiff(not_twice_edges,duplicated_edges,'rows');

% now get all faces for these edges, for visualization purposes and tracking
% there should not be that many, so don't worry about do loop
duplicated_faces = cell(1,size(duplicated_edges,1));
for i = 1:size(duplicated_edges,1)
   duplicated_faces{i} = edge_face_number(find(edges_and_directions(:,1) == duplicated_edges(i,1) & ...
      edges_and_directions(:,2) == duplicated_edges(i,2)))';
end

not_twice_faces = cell(1,size(not_twice_edges,1));
for i = 1:size(not_twice_edges,1)
   not_twice_faces{i} = edge_face_number(find(edges_and_directions(:,1) == not_twice_edges(i,1) & ...
      edges_and_directions(:,2) == not_twice_edges(i,2)))';
end


% ----------------------------- verbose Display --------------------------------

if verbose

   % ------------------------ Closed Surface Check -----------------------------

   % there may be more points in the description than actually used
   if length(point_nidx) ~= npoints
      disp(sprintf('\nThere are %.0f points that are unused in the faces description.',...
         npoints - length(point_nidx)));
   end

   euler_characteristic = nfaces + length(point_nidx) - nedges;
   disp(' ')
   disp('Poincare Formula Check for Triangles:')
   disp('In a truly closed surface of triangles, then the number of triangles is')
   disp(sprintf('   number of triangles  ==   2 * (the number of points - 2).'));
   disp(sprintf('With %.0f triangles comprising %.0f points,',...
      nfaces, length(point_nidx)))
   disp(sprintf('the numbers %.0f == %.0f here suggest:',nfaces,2*(length(point_nidx) - 2)))
   disp(' ')
   if nfaces == 2*(length(point_nidx) - 2)
      disp('CLOSED SURFACE')
   else
      disp('OPEN SURFACE')
   end

   disp(' ')
      disp('General Poincare Formula Check:')
   disp(sprintf(...
      'There are %.0f faces, %.0f points, %.0f edges,',nfaces,length(point_nidx),nedges));
   disp(sprintf('such that the Poincare Formula is %.0f + %.0f - %.0f = %.0f',...
      nfaces,length(point_nidx),nedges,euler_characteristic))

   if euler_characteristic > 0 & ~rem(euler_characteristic,2)
      % positive even number
      disp(sprintf('\nThe Euler Characteristic of %.0f suggests a surface of genus %.0f',...
         euler_characteristic,round((euler_characteristic - 2)/2)));
   end
   disp(' ')
   if euler_characteristic == 2
      disp('CLOSED SURFACE')
   else
      disp('Not surface of genus 0 (not a closed surface)');
   end

   % edges at the boundary or adjacent faces that are reverse wound

   disp(' ');
   if ~isempty(duplicated_faces)
      disp(sprintf('BAD, there are %.0f edges that were duplicated in the face descriptions.',...
         length(duplicated_faces)));
      disp(sprintf('The faces adjacent these edges are in duplicated_faces'));
   else
      disp('Good, no edges were duplicated in the face descriptions.');
   end

   disp(' ');
   if ~isempty(not_twice_faces)
      disp(sprintf('BAD, there are %.0f edges that were not specified twice, once in each direction.',...
         length(not_twice_faces)));
      disp(sprintf('The faces adjacent these edges are in not_twice_faces'));
   else
      disp('Good, all edges were properly used twice, once in each direction.');
   end


   % ------------------------- Suspicious points -----------------------------

   maxFace = max(nfaces_per_point);

   disp(' ');

   for i = 0:maxFace
      disp(sprintf('There are %6.0f points with %3.0f faces attached.',...
         sum(nfaces_per_point == i),i));
   end

   % one and two faces are not in the interior regions
   ndx = find(nfaces_per_point == 1 | nfaces_per_point == 2);


   if length(ndx) > 0
      PLOTLEN = input(sprintf('Plot how many of these %.0f isolated (1 or 2) points: ',length(ndx)));
   else
      % none found
      PLOTLEN = 0; % don't bother asking
   end

   for i = 1:PLOTLEN

      % get the points for the bad face
      pidx = ndx(i);

      % get the faces attached to this point
      % For the ith point, then faces_numbering(vertex_numbering == i) returns the indices of the
      %  polygons attached to the ith point.

      fndx = faces_numbering(vertex_numbering == pidx); % the faces attached to these points

      figure
      set(gcf,'Name',sprintf('Vertex %.0f with %.0f faces attached',pidx,nfaces_per_point(pidx)));
      h = patch('vertices',points,'faces',faces(fndx,:),'facecolor','r','edgecolor','k');
      axis equal
      axis vis3d
      hold on
      plot3(centers(1,fndx),centers(2,fndx),centers(3,fndx),'*');
      plot3(points(pidx,1),points(pidx,2),points(pidx,3),'g+');
      ma = mean(face_areas(fndx)); % mean area
      quiver3(centers(1,fndx),centers(2,fndx),centers(3,fndx),...
         face_normals(1,fndx),face_normals(2,fndx),face_normals(3,fndx),.25);
      set(h,'FaceAlpha',.8)
      hold off
      cameratoolbar('Show'); % activate the camera toolbar
      ret = cameratoolbar; % for strange reason, this activates the default orbit mode.
      drawnow
   end

   % -------------------------- Suspicious Faces -------------------------------

   disp(' ');

   for i = 0:2
      disp(sprintf('There are %6.0f faces with %1.0f suspect detects.',...
         sum(suspect_faces == i),i));
   end

   ndx = find(suspect_faces > 2);
   % ndx = find(suspect_faces > 1);
   disp(sprintf(...
      '\nThere are %.0f faces with more than two suspicious direction tests.\n',...
      length(ndx)));

   if length(ndx) > 0
      PLOTLEN = input(sprintf('Plot how many of these %.0f suspect faces: ',length(ndx)));
   else
      % none found
      PLOTLEN = 0; % don't bother asking
   end

   if PLOTLEN > 0
      disp(sprintf('Suspect face is painted green.'));
   end

   mesh_display_faces(points,faces,ndx(1:PLOTLEN))
end

% normalize normals
normals = normals';
normals_norms = sqrt(sum(normals.*conj(normals),2));
gidx = find(normals_norms);
normals(gidx,:) = - normals(gidx,:) ./ repmat(normals_norms(gidx),1,3);

centers = centers';
point_areas = point_areas';
face_normals = face_normals';
face_areas = face_areas';
suspect_faces = suspect_faces';
nfaces_per_point = nfaces_per_point(:);

% done

% ------------------------------ CROSS PRODUCT ---------------------------------
function c = cross(a,b);
% fast computation, no permutes

% Calculate cross product
c = [a(2,:).*b(3,:)-a(3,:).*b(2,:)
   a(3,:).*b(1,:)-a(1,:).*b(3,:)
   a(1,:).*b(2,:)-a(2,:).*b(1,:)];
   
% ------------------------------ SORT_KEY ---------------------------------
function [y,i] = sort_key(x,n)
% SORT_KEY - Sort with given keys
%   [y,i] = sort_key(x,n)
%
% Sort the columns of x using the key orders in n
%  e.g. sort_key(x,[2 1 3]) means sort first by the second column, then ties in
%  the second column are sorted in the first column, then finally the third
%  column.
%
% If n got given, then columns sorted in column order, i.e. [1 2 3 . . .].
%
% y is the sorted matrix, equal to x(i,:);

if ~exist('n','var')
  n = [1:size(x,2)];
end

n = n(:)'; % ensure a row vector

% now flip its ordering
n = n(end:-1:1);
% initialize the indexing
i = [1:size(x,1)]';

for j = n
  % sort the jth column, using the ordering of the previous recursion
  [ignore,ii] = sort(x(i,j)); 
  i = i(ii);
end
y = x(i,:);
