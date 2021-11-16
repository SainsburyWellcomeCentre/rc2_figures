function figure_1k(data, h_ax)
%%Figure 1K

experiment_groups   = {'visual_flow', 'mismatch_nov20', 'mismatch_jul21'};
RV_trial_groups     = {'RV', 'RV_gain_up'};
RVT_trial_groups    = {'RVT', 'RVT_gain_up'};
max_n_trials        = 10;


%% Data

[x_median, y_median, direction] = ...
    unity_plot_data(data, experiment_groups, RV_trial_groups, RVT_trial_groups, max_n_trials);


%% Plot
fmt.xy_limits       = [0, 70];
fmt.tick_space      = 20;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR R+VF (Hz)';
fmt.ylabel          = 'FR R+VF+T (Hz)';
fmt.include_inset   = false;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, x_median, y_median, direction, fmt);
