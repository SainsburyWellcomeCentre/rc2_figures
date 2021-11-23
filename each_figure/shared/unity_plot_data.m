function [x_median, y_median, direction, spike_class] = unity_plot_data(data, experiment_groups, x_trial_group_labels, y_trial_group_labels, max_n_trials)

ctl                 = RC2Analysis();

probe_ids           = ctl.get_probe_ids(experiment_groups{:});

c                   = 0;
x_median            = [];
y_median            = [];
direction           = [];
spike_class         = {};

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data   = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data   = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters        = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        [~, ~, direction(c), x_median(c), y_median(c)] = ...
            this_data.is_motion_vs_motion_significant(clusters(jj).id, x_trial_group_labels, y_trial_group_labels, max_n_trials);
        
        spike_class{c} = clusters(jj).spiking_class;
    end
end
