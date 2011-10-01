function [] = save_fstri(filename,points,faces,normals)

% SAVE_TRI   Save FreeSurfer ASCII .tri file
%
%   SYNTAX
%       [] = SAVE_FSTRI(FILENAME,POINTS,FACES,NORMALS)
%
% 
%
%   Created by Alexandre Gramfort on 2008-03-09.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.
%

me = 'SAVE_FSTRI';

if nargin == 0
    eval(['help ',lower(me)])
    return
end

if nargin<4 | isempty(normals)
    normals = mesh_normals(points,faces);
end

fid = fopen(filename,'w');
npoints = size(points,1);
nfaces = size(faces,1);
fprintf(fid,'%g\n',npoints);
fprintf(fid,'%g %g %g %g %g %g\n',[points, normals]');
fprintf(fid,'%g\n',nfaces);
fprintf(fid,'%g %g %g\n',faces');
fclose(fid);

end
