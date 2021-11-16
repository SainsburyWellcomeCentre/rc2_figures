function figure_1l(data, h_ax)
%%Figure 1L

experiment_groups           = {'visual_flow', 'mismatch_nov20', 'mismatch_jul21'};
RV_trial_group_labels       = {'RV', 'RV_gain_up'};
RVT_trial_group_labels      = {'RVT', 'RVT_gain_up'};
max_n_trials                = 10;


%% Data

[modulation_index, direction, avg_anatomy, averaged_cortical_position] = ...
    modulation_index_data(data, experiment_groups, RV_trial_group_labels, RVT_trial_group_labels, max_n_trials);


%% Plot

fmt.x_label = {'Modulation index', 'R+VF vs. R+VF+T'};

modulation_index_plot(h_ax, modulation_index, direction, avg_anatomy, averaged_cortical_position, fmt);
