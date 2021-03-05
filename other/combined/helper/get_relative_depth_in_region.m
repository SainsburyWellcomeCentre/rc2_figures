function relative_depth = ...
    get_relative_depth_in_region(from_tip, boundaries)
% inputs:
%   from_tip - distance of object from tip of probe
%   boundaries - structure with fields
%           upper:  N x 1 vector of distance values from tip of probe
%                   corresponding to the upper boundary of N regions
%           lower:  N x 1 vector of distance values from tip of probe
%                   corresponding to the lower boundary of N regions
% outputs:
%   relative_depth - relative depth between upper and lower boundaries of
%       region.. if outside limits or boundaries is empty nan is returned

if isempty(boundaries)
    relative_depth = nan;
    return
end

idx = find(from_tip < boundaries.upper & from_tip > boundaries.lower);

% if no region found
if isempty(idx)
    relative_depth = nan;
    return
end

relative_depth = 1 - ((from_tip - boundaries.lower(idx)) / ...
    (boundaries.upper(idx) - boundaries.lower(idx)));

