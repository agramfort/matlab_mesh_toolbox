function [inside] = mesh_is_inside(points, faces, test_points,options);

% MESH_IS_INSIDE determines if a point is inside/outside a mesh
%
% [inside] = mesh_is_inside(points, faces, test_points)
%
% where
%   test_points     position of point of interest (should be Nx3)
%   points          mesh vertices
%   faces           mesh triangles
%
% See also SOLID_ANGLE


if nargin<4
    options.null = 0;
end

if ~isfield(options, 'display_mesh')
    options.display_mesh = false;
end
display_mesh = options.display_mesh;

if ~isfield(options, 'verbose')
    options.verbose = false;
end
verbose = options.verbose;

if isfield(options, 'null')
    options = rmfield(options,'null');
end

if nargout == 0
    verbose = 1;
end

ntest_points = size(test_points, 1);
npoints = size(points, 1);
nfaces = size(faces, 1);

% determine a cube that encompases the boundary facesangulation
bound_min = min(points);
bound_max = max(points);

% determine a sphere that is completely inside the boundary facesangulation
bound_org = mean(points);
bound_rad = sqrt(min(sum((points - repmat(bound_org, size(points,1), 1)).^2, 2)));

inside = zeros(ntest_points, 1);
for i=1:ntest_points
  if verbose
    fprintf('%6.2f%%', 100*i/ntest_points);
  end
  if any(test_points(i,:)<bound_min) || any(test_points(i,:)>bound_max)
    % the point is outside the bounding cube
    inside(i) = 0;
    if verbose, fprintf(' outside the bounding cube\n'); end
  elseif sqrt(sum((test_points(i,:)-bound_org).^2, 2))<bound_rad
    % the point is inside the interior sphere
    inside(i) = 1;
    if verbose, fprintf(' inside the interior sphere\n'); end
  else
    % the point is inside the bounding cube but outside the interior sphere
    % compute the total solid angle of the surface, which is zero for a point outside
    % the facesangulation and 4*pi or -4*pi for a point inside (depending on the triangle
    % orientation)
    tmp = points - repmat(test_points(i,:), npoints, 1);
    solang = solid_angle(tmp, faces);
    if any(isnan(solang))
      inside(i) = nan;
    elseif (abs(sum(solang))-2*pi)<0
      % total solid angle is (approximately) zero
      inside(i) = 0;
    elseif (abs(sum(solang))-2*pi)>0
      % total solid angle is (approximately) plus or minus 4*pi
      inside(i) = 1;
    end
    if verbose, fprintf(' solid angle\n'); end
  end
end

if display_mesh
    close
    smart_figure('mesh_is_inside display');
    options.face_alpha = 0.6;
    mesh_display(points,faces,options);
    hold on
    glyph_display(test_points);
    hold off
end

% ****************************************************************************** %

function [w] = solid_angle(r1, r2, r3);

% SOLID_ANGLE of a planar triangle as seen from the origin
%
% The solid angle W subtended by a surface S is defined as the surface
% area W of a unit sphere covered by the surface's projection onto the
% sphere. Solid angle is measured in steradians, and the solid angle
% corresponding to all of space being subtended is 4*pi sterradians.
%
% Use:
%   [w] = solid_angle(v1, v2, v3) or
%   [w] = solid_angle(points, faces)
% where v1, v2 and v3 are the vertices of a single triangle in 3D or
% points and faces contain a description of a triangular mesh (this will
% compute the solid angle for each triangle)

if nargin==2
  % reassign the input arguments
  points = r1;
  faces = r2;
  npoints = size(points,1);
  nfaces = size(faces,1);
  w    = zeros(nfaces,1);
  % compute solid angle for each triangle
  for i=1:nfaces
    r1 = points(faces(i,1),:);
    r2 = points(faces(i,2),:);
    r3 = points(faces(i,3),:);
    w(i) = solid_angle(r1, r2, r3);
  end
  return
elseif nargin==3
  % compute the solid angle for this triangle
  cp23_x = r2(2) * r3(3) - r2(3) * r3(2);
  cp23_y = r2(3) * r3(1) - r2(1) * r3(3);
  cp23_z = r2(1) * r3(2) - r2(2) * r3(1);
  nom = cp23_x * r1(1) + cp23_y * r1(2) + cp23_z * r1(3);
  n1 = sqrt (r1(1) * r1(1) + r1(2) * r1(2) + r1(3) * r1(3));
  n2 = sqrt (r2(1) * r2(1) + r2(2) * r2(2) + r2(3) * r2(3));
  n3 = sqrt (r3(1) * r3(1) + r3(2) * r3(2) + r3(3) * r3(3));
  ip12 = r1(1) * r2(1) + r1(2) * r2(2) + r1(3) * r2(3);
  ip23 = r2(1) * r3(1) + r2(2) * r3(2) + r2(3) * r3(3);
  ip13 = r1(1) * r3(1) + r1(2) * r3(2) + r1(3) * r3(3);
  den = n1 * n2 * n3 + ip12 * n3 + ip23 * n1 + ip13 * n2;
  if (nom == 0)
    if (den <= 0)
      w = nan;
      return
    end
  end
  w = 2 * atan2 (nom, den);
  return
else
  error('invalid input');
end

