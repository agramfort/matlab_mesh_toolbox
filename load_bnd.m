function [points,faces,normals] = load_bnd(filename)

% LOAD_BND   Load .bnd mesh files and converting the units of the vertices to mm
%
%   SYNTAX
%       [POINTS,FACES,NORMALS] = LOAD_BND(FILENAME)
%
%
%   Created by Alexandre Gramfort on 2008-03-29.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'LOAD_BND';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

npoints = read_asa_tag(filename, 'NumberPositions=', '%d');
nfaces = read_asa_tag(filename, 'NumberPolygons=', '%d');
Unit = read_asa_tag(filename, 'UnitPosition', '%s');

points = read_asa_tag(filename, 'Positions', '%f');
if any(size(points)~=[npoints,3])
  points_file = read_asa_tag(filename, 'Positions', '%s');
  [path, name, ext] = fileparts(filename);
  fid = fopen(fullfile(path, points_file), 'rb', 'ieee-le');
  pnt = fread(fid, [3,npoints], 'float')';
  fclose(fid);
end

faces = read_asa_tag(filename, 'Polygons', '%f');
if any(size(faces)~=[nfaces,3])
  faces_file = read_asa_tag(filename, 'Polygons', '%s');
  [path, name, ext] = fileparts(filename);
  fid = fopen(fullfile(path, faces_file), 'rb', 'ieee-le');
  faces = fread(fid, [3,nfaces], 'int32')';
  fclose(fid);
end
faces = faces + 1;

if strcmp(lower(Unit),'mm')
  points   = 1*points;
elseif strcmp(lower(Unit),'cm')
  points   = 100*points;
elseif strcmp(lower(Unit),'m')
  points   = 1000*points;
else
  warning(sprintf('Unknown unit of distance for triangulated boundary (%s)', Unit));
end

if nargout
    normals = mesh_normals(points,faces);
end
