function figure_s6b(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('mismatch_darkness_oct21');
trial_group_label   = 'RT_gain_up';


%% Data

mm                  = MismatchAnalysis();

c                   = 0;
p_val               = [];
direction           = [];
avg_baseline        = [];
avg_response        = [];

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data   = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data   = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters        = this_data.VISp_clusters();
    
    trials          = this_data.get_trials_with_trial_group_label(trial_group_label);
    
    % remove trials with small mismatch period
    trials          = remove_invalid_mm_trials(trials);
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        avg_baseline(c) = mm.get_avg_baseline_fr(clusters(jj), trials);
        avg_response(c) = mm.get_avg_response_fr(clusters(jj), trials);
        [~, p_val(c), direction(c)] = mm.is_response_significant(clusters(jj), trials);
    end
end


%% Plot
fmt.xy_limits       = [0, 40];
fmt.tick_space      = 10;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR R (Hz)';
fmt.ylabel          = 'FR R+T (Hz)';
fmt.include_inset   = false;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, avg_baseline, avg_response, direction, fmt)

% title
text(h_ax, mean(h_ax.XLim), h_ax.YLim(2)+0.05*range(h_ax.YLim), 'R:T', ...
        'fontsize', 8, ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'bottom');
