function figure_1g(data, h_ax)
%%Figure 1G

experiment_groups   = {'visual_flow'};
V_trial_groups      = {'V_RVT', 'V_RV'};
VT_trial_groups     = {'VT_RVT', 'VT_RV'};


%% Data

[x_median, y_median, direction] = ...
    unity_plot_data(data, experiment_groups, V_trial_groups, VT_trial_groups, inf);


%% Plot
fmt.xy_limits       = [0, 60];
fmt.tick_space      = 20;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR VF (Hz)';
fmt.ylabel          = 'FR VF+T (Hz)';
fmt.include_inset   = true;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, x_median, y_median, direction, fmt);
