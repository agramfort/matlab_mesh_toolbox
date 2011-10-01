function [] = save_tri(filename,points,faces,normals)

% SAVE_TRI   Save .tri file
%
%   SYNTAX
%       [] = SAVE_TRI(FILENAME,POINTS,FACES,NORMALS)
%
%
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%

me = 'SAVE_TRI';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

if nargin<4 || isempty(normals)
    normals = mesh_normals(points,faces);
end

fid = fopen(filename,'w');
npoints = size(points,1);
fprintf(fid,'- %g\n',npoints);
fprintf(fid,'%g %g %g %g %g %g\n',[points , normals]');
nfaces = size(faces,1);
faces = faces-1;
fprintf(fid,'- %g %g %g\n', [nfaces nfaces nfaces]);
fprintf(fid,'%g %g %g\n',faces');

fclose(fid);

end %  function
