function [points,faces,normals] = load_fstri(filename)

% LOAD_FSTRI   Load .tri file from freesurfer
%
%   SYNTAX
%       [POINTS,FACES,NORMALS] = LOAD_FSTRI(FILENAME)
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'LOAD_FSTRI';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

fid = fopen(filename);
s = fgetl(fid);
npoints = sscanf(s,'%d');
points = fscanf(fid,'%g %g %g\n',[3 npoints]);
points = points';
s = fgetl(fid);;
[nfaces] = double(sscanf(s,'%d'))
faces = fscanf(fid,'%d %d %d\n',[3 nfaces]);
faces = faces';
fclose(fid);
faces = uint32(faces);

normals = mesh_normals(points,faces);

