function labels = patches_to_labels(patches)
%   PATCHES_TO_LABELS
%       [LABELS] = PATCHES_TO_LABELS(PATCHES)
%
%   Created by Alexandre Gramfort on 2008-11-07.
%   Copyright (c) 2007 Alexandre Gramfort. All rights reserved.


if find(sum(patches,2)>1)
    error('patches should not contain more than one 1 per line')
end

gidx = find(sum(patches,2)==1);

[ii,glabels,vv] = find(patches(gidx,:));

[ii,I] = sort(ii);
glabels = glabels(I);

labels = zeros(size(patches,1),1);
labels(gidx) = glabels;

end %  function