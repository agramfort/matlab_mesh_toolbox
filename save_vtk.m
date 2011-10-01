function [] = save_vtk(filename,points,faces,normals,colors)

% SAVE_VTK   Save triangulation in VTK ascii file
%
%   SYNTAX
%       [] = SAVE_VTK(FILENAME,POINTS,FACES,NORMALS,COLORS)
%
%
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%


me = 'SAVE_VTK';

if nargin<4
    normals = [];
end

if nargin<5
    colors = [];
end

if nargin == 0
    eval(['help ',lower(me)])
    return
end

fid = fopen(filename,'w');
fprintf(fid,'# vtk DataFile Version 2.0\n');

fprintf(fid,['File ' filename '\n']);
fprintf(fid,'ASCII\n');
fprintf(fid,'DATASET POLYDATA\n');
npoints = size(points,1);
fprintf(fid,'POINTS %g float\n',npoints);
fprintf(fid,'%g %g %g\n ',points');

nfaces = size(faces,1);

if ~isempty(faces)
    faces(:,2:4) = faces-1;
    faces(:,1) = 3*ones(nfaces,1);
    fprintf(fid,'POLYGONS %g %g\n', [nfaces nfaces*4]);
    fprintf(fid,'%g %g %g %g\n ',faces');
end

fprintf(fid,'CELL_DATA %g\n',nfaces);
if ~isempty(colors) && size(colors,1) == nfaces
    fprintf(fid,['SCALARS scalars float 1\n']);
    fprintf(fid,'LOOKUP_TABLE default\n');
    fprintf(fid,'%g\n ',colors);
end

fprintf(fid,'POINT_DATA %g\n',npoints);
if ~isempty(colors) && size(colors,1) == npoints
    fprintf(fid,['SCALARS scalars float 1\n']);
    fprintf(fid,'LOOKUP_TABLE default\n');
    fprintf(fid,'%g\n ',colors);
end
if ~isempty(normals)
    fprintf(fid,['NORMALS normals float\n']);
    fprintf(fid,'%g ',normals');    
    fprintf(fid,'\n');    
end

fclose(fid);