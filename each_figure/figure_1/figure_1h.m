function figure_1h(data, h_ax)
%%Figure 1H

experiment_groups           = {'visual_flow'};
V_trial_group_labels        = {'V_RVT', 'V_RV'};
VT_trial_group_labels       = {'VT_RVT', 'VT_RV'};


%% Data

[modulation_index, direction, avg_anatomy, averaged_cortical_position] = ...
    modulation_index_data(data, experiment_groups, V_trial_group_labels, VT_trial_group_labels, inf);


%% Print
responsive_idx  = abs(direction) == 1;
n_responsive    = sum(responsive_idx);
mi_avg          = mean(modulation_index(responsive_idx));
mi_std          = std(modulation_index(responsive_idx));

fprintf('\n\nFigure 1H, VF vs. VF+T, modulation index\n');
fprintf('Avg. MI of responsive clusters: %.2f + %.2f (n=%i)\n', mi_avg, mi_std, n_responsive);
fprintf('  # MI nan: %i\n', sum(isnan(modulation_index)));


%% Plot

fmt.x_label = {'Modulation index', 'VF vs. VF+T'};

modulation_index_plot(h_ax, modulation_index, direction, avg_anatomy, averaged_cortical_position, fmt);
