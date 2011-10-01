function [points,faces,normals] = load_tri(filename)

% LOAD_TRI   Load .tri file
%
%   SYNTAX
%       [POINTS,FACES,NORMALS] = LOAD_TRI(FILENAME)
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'LOAD_TRI';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

fid = fopen(filename);
s = fgetl(fid);
npoints = sscanf(s,'- %d');
points = fscanf(fid,'%g %g %g %g %g %g\n',[6 npoints]);
points = points';
normals = points(:,4:6);
points = points(:,1:3);
s = '';
while isempty(findstr('-',s))
s = fgetl(fid);
end
[nfaces] = sscanf(s,'- %d %d %d');
nfaces = nfaces(1);
dim2 = 3;
faces = fscanf(fid,'%d %d %d\n',[dim2 nfaces]);
faces = faces';
if dim2==4
    faces = faces(:,2:4)+1;
else
    faces = faces+1;
end
fclose(fid);
faces = uint32(faces);
