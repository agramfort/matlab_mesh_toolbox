function [out_points,out_faces] = mesh_clean(points,faces)

% MESH_CLEAN   clean mesh using QSlim
%
%   QSLIM program by
%
%       Michael Garland
%       Department of Computer Science
%       University of Illinois
%       201 North Goodwin Avenue
%       Urbana, IL 61801-2302
%
%   SYNTAX
%       [OUT_POINTS,OUT_FACES] = MESH_CLEAN(POINTS,FACES)
%
%   Created by Alexandre Gramfort on 2008-02-19.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


% Try to find qslim
[status, result] = system(['smfclean qsdf']);
if ~strfind(result,'FATAL')
    error('smfclean command not found');
end

% write input in smf format
save_smf('tmp.smf', points, faces);

% perform simplication
[status, result] = system(['smfclean -o tmp1.smf tmp.smf']);
disp(result);

% read back result
[out_points,out_faces] = load_smf('tmp1.smf');

% delete temporary files
delete 'tmp.smf';
delete 'tmp1.smf';

end % function