function boundaries = get_VISp_layer_boundaries(probe_fname, formatted_dir)

warning('off', 'MATLAB:table:RowsAddedExistingVars');
boundaries = table();
r = 0;

layers = {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'};

% load the anatomy... should it be done here?
load(fullfile(formatted_dir, probe_fname), 'anatomy');

% for 
for i = 1 : length(anatomy.region_str)
    
    if ~any(strcmp(layers, anatomy.region_str{i}))
        continue
    end
    
    r = r + 1;
    
    this_instance = 1;
    
    % if we are not on the first region
    if r > 1
        
        % look at previously stored regions
        idx = strcmp(boundaries.region(1:r-1), anatomy.region_str{i});
        
        % if this region already exists
        if sum(idx) > 0
            % say it is instance +1 of the region
            this_instance = sum(idx) + 1;
        end
    end
    
    boundaries.probe_name{r} = probe_fname;
    boundaries.region{r} = anatomy.region_str{i};
    boundaries.upper(r) = anatomy.region_boundaries(i);
    boundaries.lower(r) = anatomy.region_boundaries(i+1);
    boundaries.instance(r) = this_instance;
end
