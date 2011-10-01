function [points,faces,normals] = load_vtk(filename)

% LOAD_VTK   Load VTK ascii polydata file
%
%   SYNTAX
%       [POINTS,FACES,NORMALS] = LOAD_VTK(FILENAME)
%
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.

me = 'LOAD_VTK';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

fid = fopen(filename);
s = '';
while isempty(findstr('POINTS',s))
s = fgetl(fid);
end
npoints = sscanf(s,'POINTS %d');
points = fscanf(fid,'%g %g %g\n',[3 npoints]);
points = points';
s = '';
while isempty(findstr('POLYGONS',s))
s = fgetl(fid);
end
[nfaces] = sscanf(s,'POLYGONS %d %d');
dim2 = nfaces(2) / nfaces(1);
nfaces = nfaces(1);
faces = fscanf(fid,'%g %g %g %g\n',[dim2 nfaces]);
faces = faces';
if dim2==4
   faces = faces(:,2:4)+1;
else
   faces = faces+1;
end

normals = mesh_normals(points,faces);

fclose(fid);