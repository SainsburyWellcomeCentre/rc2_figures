function figure_2g(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('mismatch_nov20', 'mismatch_jul21');
trial_group_label   = 'RVT_gain_up';


%% Data

mm                  = MismatchAnalysis();
mm.method           = 'anova';

c                   = 0;
p_val               = [];
direction           = [];
avg_baseline        = [];
avg_response        = [];
baseline_normal     = [];
response_normal     = [];
spike_class         = {};

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
        baseline_normal(c) = mm.is_baseline_normal(clusters(jj), trials);
        response_normal(c) = mm.is_response_normal(clusters(jj), trials);
        spike_class{c} = clusters(jj).spiking_class;
    end
end


%% Print
fprintf('\n\nFigure 2G, mismatch response R:VF+T\n');
print_unity_plot_stats(avg_baseline, avg_response, direction, spike_class)
fprintf(' Fraction in which we reject normality in baseline: %.2f%% (%i/%i)\n', 100*sum(~baseline_normal)/length(baseline_normal), sum(~baseline_normal), length(baseline_normal));
fprintf(' Fraction in which we reject normality in response: %.2f%% (%i/%i)\n', 100*sum(~response_normal)/length(response_normal), sum(~response_normal), length(response_normal));


%% Plot
fmt.xy_limits       = [0, 45];
fmt.tick_space      = 10;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR R+VF (Hz)';
fmt.ylabel          = 'FR R+VF+T (Hz)';
fmt.include_inset   = false;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, avg_baseline, avg_response, direction, fmt)

% title
text(h_ax, mean(h_ax.XLim), h_ax.YLim(2)+0.05*range(h_ax.YLim), 'R:VF+T', ...
        'fontsize', 8, ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'bottom');
