function [out_points,out_faces,out_normals] = mesh_refine(points,faces,maxlength)

%  Refine mesh using QSlim
% 
%   QSLIM program by
%
%       Michael Garland
%       Department of Computer Science
%       University of Illinois
%       201 North Goodwin Avenue
%       Urbana, IL 61801-2302
%
%   [OUT_POINTS,OUT_FACES,OUT_NORMALS] = MESH_REFINE(POINTS,FACES,MAXLENGTH)
% 
%   MAXLENGTH : max edge length in new mesh
%
%   Created by Alexandre Gramfort on 2008-02-27.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


% Try to find qslim
[status, result] = system(['smfrefine -h']);
if status ~= 0
    error('smfrefine command not found');
end

infile = [tempname,'.smf'];
outfile = [tempname,'.smf'];
% write input in smf format
save_smf(infile, points, faces);

try 
    % perform simplication
    [status, result] = system(['smfrefine -o ',outfile,' -t ' num2str(maxlength),' ',infile]);

    % read back result
    [out_points,out_faces] = load_smf(outfile);
catch 
    % delete temporary files
    delete infile;
    delete outfile;
    error('Error with smfrefine')
    return
end

% delete temporary files
delete(infile);
delete(outfile);

out_normals = mesh_normals(out_points,out_faces);

end %  function
