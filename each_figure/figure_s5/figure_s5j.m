function figure_s5j(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('darkness', 'mismatch_darkness_oct21');
R_trial_groups      = {'R'};
RT_trial_groups      = {'RT', 'RT_gain_up'};


%% Data

c                   = 0;
x_med               = [];
y_med               = [];
direction           = [];

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters    = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        [~, ~, direction(c), x_med(c), y_med(c)] = this_data.is_motion_vs_motion_significant(clusters(jj).id, R_trial_groups, RT_trial_groups);
    end
end



%% Plot
fmt.xy_limits       = [0, 20];
fmt.tick_space      = 5;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR R (Hz)';
fmt.ylabel          = 'FR R+T (Hz)';
fmt.include_inset   = false;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, x_med, y_med, direction, fmt);
