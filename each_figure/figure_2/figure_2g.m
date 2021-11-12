function sort_idx = figure_2g(data, h_ax)

force_replication   = true;

ctl                 = RC2Analysis();

probe_ids           = ctl.get_probe_ids('mismatch_nov20', 'mismatch_jul21');
trial_group_label   = 'RVT_gain_up';

cluster_count       = 0;
p_val               = [];
direction           = [];
avg_baseline        = [];
avg_response        = [];

mm                      = MismatchAnalysis();

%% extract and analyze data
for ii = 1 : length(probe_ids)
    
    ii
    
    this_data = get_data_for_probe_id(data, probe_ids{ii});
    clusters = this_data.VISp_clusters();
    
    trials      = this_data.get_trials_with_trial_group_label(trial_group_label);
    
    mm_start_t  = cellfun(@(x)(x.mismatch_onset_t), trials);
    mm_end_t    = cellfun(@(x)(x.mismatch_offset_t), trials);
    
    trials(mm_end_t - mm_start_t < 0.05) = [];
    
    for jj = 1 : length(clusters)
        
        % force a replication of an old figure... to remove in future
        if force_replication
            if ii == 4 && ismember(clusters(jj).id, [224, 225, 230])
                continue
            end
        end
        
        cluster_count = cluster_count + 1;
        avg_baseline(cluster_count) = mm.get_avg_baseline_fr(clusters(jj), trials);
        avg_response(cluster_count) = mm.get_avg_response_fr(clusters(jj), trials);
        [~, p_val(cluster_count), direction(cluster_count)] = mm.is_response_significant(clusters(jj), trials);
    end
end



%% Plot
cols = get_colours();
xy_limits = [0, 35];

line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');

idx = direction == 0;
scatter(h_ax, avg_baseline(idx), avg_response(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
idx = direction == 1;
scatter(h_ax, avg_baseline(idx), avg_response(idx), scatterball_size(1.25), cols('sig_increase'));
idx = direction == -1;
scatter(h_ax, avg_baseline(idx), avg_response(idx), scatterball_size(1.25), cols('sig_decrease'));

set(h_ax, 'xlim', xy_limits, ...
          'xtick', 0:10:xy_limits(2), ...
          'xticklabel', {'0', '', '', '30'}, ...
          'ylim', xy_limits, ...
          'ytick', 0:10:xy_limits(2), ...
          'yticklabel', {'0', '', '', '30'}, ...
          'fontsize', 8);

text(h_ax, mean(xy_limits), xy_limits(1)-0.1*range(xy_limits), 'FR R+VF (Hz)', ...
            'color', 'k', ...
            'fontsize', 8', ...
            'horizontalalignment', 'center', ...
            'verticalalignment', 'top');
% xlabel(h_ax, 'FR R+VF (Hz)', 'fontsize', 8);

ylabel(h_ax, 'FR R+VF+T (Hz)', 'fontsize', 8);

text(h_ax, 1.5, 30, sprintf('%.2f%%', 100*sum(direction == 1)/length(direction)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_increase'), 'horizontalalignment', 'left', 'verticalalignment', 'top');
text(h_ax, 30, 3, sprintf('%.2f%%', 100*sum(direction == -1)/length(direction)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_decrease'), 'horizontalalignment', 'right', 'verticalalignment', 'bottom');
