function depths = get_relative_depth(T2, boundaries)

depths = nan(size(T2, 1), 1);

for ti = 1 : size(T2, 1)
    
    probe_name  = T2.probe_name{ti};
    region_str  = T2.cluster_region{ti}{1};
    from_tip    = T2.cluster_from_tip(ti);
    
    if strcmp(region_str, 'VISp2/3')
        disp('');
    end
    
    % make sure that this is consistent
    idx         = strcmp(boundaries.probe_name, probe_name);
    
    upper       = boundaries.upper(idx);
    lower       = boundaries.lower(idx);
    regions     = boundaries.region(idx);
    
    a           = find(from_tip < upper & from_tip > lower);
    assert(isequal(region_str, regions{a}));
    
    depths(ti) = 1 - (from_tip - lower(a)) / (upper(a) - lower(a));
end






% %
% depths = nan(length(clusters), 1);
% 
% % iterate over clusters
% for clust_i = 1 : length(clusters)
%     
%     %distance of cluster in um from tip of probe
%     d = clusters(clust_i).distance_from_probe_tip;
%     
%     % distance of boundaries from tip of probe
%     b = anatomy.region_boundaries;
%     
%     % find first boundary which cluster is above
%     % boundaries are ordered from largest to smallest so the index we
%     % require is the last value for which d is > boundary distance
%     b_i = find(d < b, 1, 'last');
%     
%     % upper and lower boundary of region in which cluster exists
%     upper_boundary = b(b_i);
%     lower_boundary = b(b_i+1);
%     
%     % relative depth in region
%     depths(clust_i) = 1 - (d - lower_boundary) / (upper_boundary - lower_boundary);
% end
