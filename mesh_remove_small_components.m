function [map_clean] = mesh_remove_small_components(points,faces,map,min_size,data)
%   MESH_REMOVE_SMALL_COMPONENTS
%       [MAP_CLEAN] = MESH_REMOVE_SMALL_COMPONENTS(POINTS,FACES,MAP,MIN_SIZE,DATA)
%
%   Set map values to zero if they don't belong to the biggest component
%   or if they belong to a component that in small then a certain size
%
%   Created by Alexandre Gramfort on 2008-11-13.
%   Copyright (c) 2007-2011 Alexandre Gramfort. All rights reserved.


if nargin == 3
    min_size = [];
end

if nargin<5
    data = [];
end

map_clean = zeros(size(map));

for ii=1:size(map,2)
    if find(map(:,ii)~=0)
        [mcomp,compsz] = mesh_map_components(points,faces,map(:,ii));
        if ~isempty(data) % select components based on L2 norm using data
            for jj=1:length(compsz)
                compsz(jj) = norm(data(mcomp==jj,ii),'fro');
            end
        end
        if isempty(min_size)
            [max_size,max_idx] = max(compsz);
            cmp_idx = find(mcomp==max_idx);
            map_clean(cmp_idx,ii) = map(cmp_idx,ii);
        else
            gidx = find(compsz >= min_size);
            compsz(gidx);
            for k=1:length(gidx)
                cmp_idx = find(mcomp==gidx(k));
                map_clean(cmp_idx,ii) = map(cmp_idx,ii);
            end
        end
    end
end

end %  function