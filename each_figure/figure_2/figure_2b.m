function figure_2b(data, h_ax1, h_ax2, h_ax3)

probe_id            = 'CAA-1112874_rec1_rec2_rec3';
cluster_id          = 187;
trial_group_label   = 'RVT_gain_up';
padding             = [-1, 1];
fs                  = 10000;


%% get trials
this_data           = get_data_for_probe_id(data, probe_id);
these_trials        = this_data.get_trials_with_trial_group_label(trial_group_label);
n_trials            = length(these_trials);

% spike times
this_cluster        = this_data.get_cluster_with_id(cluster_id);


mm_start_t = nan(1, n_trials);
for ii = 1 : n_trials
    mm_start_t(ii) = these_trials{ii}.mismatch_onset_t();
end


common_t = this_data.timebase(padding, fs);
mm_spike_times = cell(1, n_trials);
fr_conv = nan(length(common_t), n_trials);

for ii = 1 : n_trials
    
    start_time = mm_start_t(ii);
    
    spike_idx = this_cluster.spike_times > (start_time + padding(1)) & ...
                this_cluster.spike_times < (start_time + padding(2));

    mm_spike_times{ii} = this_cluster.spike_times(spike_idx) - start_time;
    fr_conv(:, ii) = this_cluster.fr.get_convolution(start_time + common_t);
end

fr_mean = mean(fr_conv, 2);
fr_sem = std(fr_conv, [], 2) / sqrt(n_trials);



%% plot
patch(h_ax1, 'xdata', [0, 0.25, 0.25, 0], 'ydata', [0, 0, 1, 1], 'facecolor', [0.9, 0.9, 0.9], 'edgecolor', [0.9, 0.9, 0.9]);
set(h_ax1, 'xlim', padding);
text(h_ax1, 0.125, 1.01, 'slip', 'color', 'k', 'fontsize', 6, 'horizontalalignment', 'center', 'verticalalignment', 'top');
axis(h_ax1, 'off');

for i = 1 : n_trials
    
    scatter(h_ax2, mm_spike_times{i}, (n_trials - i + 1) * ones(size(mm_spike_times{i})), ...
            scatterball_size(0.754), 'k', 'fill', 'markerfacealpha', 0.5);
end

plot(h_ax3, common_t, fr_mean, 'color', 'k', 'linewidth', 0.75);
plot(h_ax3, common_t, fr_mean+fr_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax3, common_t, fr_mean-fr_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);

ylabel(h_ax2, 'trial #', 'fontsize', 8)
ylabel(h_ax3, 'FR (Hz)', 'fontsize', 8)



%% format
set(h_ax2,  'clipping', 'off', ...
            'color', 'none', ...
            'fontsize', 8, ...
            'xcolor', 'none', ...
            'xlim', padding, ...
            'ylim', [0.5, n_trials+0.5], ...
            'ytick', [1, n_trials], ...
            'yticklabels', [n_trials, 1]);


set(h_ax3,  'clipping', 'off', ...
            'color', 'none', ...
            'fontsize', 8, ...
            'xcolor', 'none', ...
            'xlim', padding, ...
            'ylim', [0, 50], ...
            'ytick', [0, 25, 50], ...
            'yticklabels', {'0', '', '50'})


