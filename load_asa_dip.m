function [points,orientations,faces] = load_asa_dip(fname)

% LOAD_ASA_DIP   Read ASA .dip files
%
%   SYNTAX
%       [POINTS,ORIENTATIONS,FACES] = LOAD_ASA_DIP(FNAME)
%
%
%   Created by Alexandre Gramfort on 2008-04-21.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'LOAD_ASA_DIP';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

npoints = read_asa_tag(fname, 'NumberPositions=', '%d');
nfaces = read_asa_tag(fname, 'NumberPolygons=', '%d');
Unit = read_asa_tag(fname, 'UnitPosition', '%s');

points = read_asa_tag(fname, 'PositionsFixed', '%f');
if any(size(points)~=[npoints,3])
  points_file = read_asa_tag(fname, 'PositionsFixed', '%s');
  [path, name, ext] = fileparts(fname);
  fid = fopen(fullfile(path, points_file), 'rb', 'ieee-le');
  pnt = fread(fid, [3,npoints], 'float')';
  fclose(fid);
end

orientations = read_asa_tag(fname, 'MomentsFixed', '%f');
if any(size(orientations)~=[orientations,3])
  orientations_file = read_asa_tag(fname, 'MomentsFixed', '%s');
  [path, name, ext] = fileparts(fname);
  fid = fopen(fullfile(path, orientations_file), 'rb', 'ieee-le');
  pnt = fread(fid, [3,npoints], 'float')';
  fclose(fid);
end

faces_type = read_asa_tag(fname, 'TypePolygons=', '%f');
assert(faces_type==3);

faces = read_asa_tag(fname, 'Polygons', '%f');
if any(size(faces)~=[nfaces,3])
  faces_file = read_asa_tag(fname, 'Polygons', '%s');
  [path, name, ext] = fileparts(fname);
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

