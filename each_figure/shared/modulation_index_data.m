function [modulation_index, direction, avg_anatomy, averaged_cortical_position] = ...
    modulation_index_data(data, experiment_groups, x_trial_group_labels, y_trial_group_labels, max_n_trials)

ctl                     = RC2Analysis();

probe_ids               = ctl.get_probe_ids(experiment_groups{:});

c                       = 0;
modulation_index        = [];
p_val                   = [];
direction               = [];

relative_depth          = [];
layer                   = {};
anatomies               = Anatomy.empty();


for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data       = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data       = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters            = this_data.VISp_clusters();
    
    anatomies{ii}       = data.anatomy;
    
    for jj = 1 : length(clusters)
        
        c  = c + 1;
        
        % get relative depth within layer and label of the layer for this
        % cluster
        [relative_depth(c), layer{c}]   = this_data.get_relative_layer_depth_of_cluster(clusters(jj).id);
        
        % make sure that the layer returned by above function is same as
        % that stored in the cluster structure
        assert(strcmp(layer{c}, clusters(jj).region_str));
        
        [~, p_val(c), direction(c), x_median, y_median] = ...
            this_data.is_motion_vs_motion_significant(clusters(jj).id, x_trial_group_labels, y_trial_group_labels, max_n_trials);
        
        modulation_index(c)             = (y_median - x_median) / (y_median + x_median);
    end
end

avg_anatomy = AverageAnatomy(anatomies);
averaged_cortical_position = avg_anatomy.from_pia_using_relative_position(relative_depth, layer);
