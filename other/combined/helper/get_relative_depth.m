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
