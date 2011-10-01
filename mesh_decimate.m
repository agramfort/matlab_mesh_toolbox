function [out_points,out_faces,out_normals] = mesh_decimate(points,faces,decimation_factor,options)
% Mesh decimation tool
%
%   Created by Alexandre Gramfort on 2008-02-27.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


me = 'MESH_DECIMATE';

if nargin<4
    options.null = 0;
end

if ~isfield(options, 'use_qslim')
    options.use_qslim = true;
end
use_qslim = options.use_qslim;

if isfield(options, 'null')
    options = rmfield(options,'null');
end

% Try to find qslim
[status, result] = system(['qslim -h']);
if status ~= 0
    disp('QSlim command not found. Using reducepatch command');
    use_qslim = false;
end

if use_qslim
    % write input in smf format
    save_smf('tmp.smf', points, faces);

    if decimation_factor <= 1
        decimation_factor = fix(size(faces,1) * decimation_factor);
    end

    % perform simplication
    [status, result] = system(['qslim -o tmp1.smf -t ' num2str(decimation_factor),' tmp.smf']);

    % read back result
    [out_points,out_faces] = load_smf('tmp1.smf');

    % delete temporary files
    delete 'tmp.smf';
    delete 'tmp1.smf';
else
    [out_faces,out_points] = reducepatch(faces,points,decimation_factor);
end

out_normals = mesh_normals(out_points,out_faces);

end %  function
