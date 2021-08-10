function figure_2e(data, h_ax1, h_ax2, h_ax3)

recording_id        = 'CAA-1112874_rec1_rec2_rec3';
session_n           = 1;
cluster_id          = 187;
protocol_type       = 'EncoderOnlyMismatch';
gain_dir            = 'up';

padding             = [-1, 1];
fs                  = 10000;


%% get trials
this_data           = get_data_for_recording_id(data, recording_id);
idx                 = strcmp({this_data.data.sessions(session_n).trials(:).protocol}, protocol_type);

config              = [this_data.data.sessions(session_n).trials(:).config];
idx_gain            = strcmp({config(:).gain_direction}, gain_dir);

these_trials        = this_data.data.sessions(session_n).trials(idx & idx_gain);
n_trials            = length(these_trials);

% spike times
idx                 = [this_data.data.clusters(:).id] == cluster_id;
spike_times         = this_data.data.clusters(idx).spike_times;


mm_start_t = nan(1, n_trials);
for i = 1 : n_trials
    mm_start_t(i) = these_trials(i).mismatch_onset_t();
end


n_sample_points = (padding(2) - padding(1)) * fs + 1;
common_t = linspace(padding(1), padding(2), n_sample_points);
fr = FiringRate(spike_times);

mm_spike_times = cell(1, n_trials);
fr_conv = nan(n_sample_points, n_trials);

for i = 1 : n_trials
    
    spike_idx = spike_times > (mm_start_t(i) + padding(1)) & ...
                spike_times < (mm_start_t(i) + padding(2));

    mm_spike_times{i} = spike_times(spike_idx) - mm_start_t(i);
    fr_conv(:, i) = fr.get_convolution(mm_start_t(i) + common_t);
end

fr_mean = mean(fr_conv, 2);
fr_sem = std(fr_conv, [], 2) / sqrt(n_trials);


%% plot
patch(h_ax1, 'xdata', [0, 0.25, 0.25, 0], 'ydata', [0, 0, 1, 1], 'facecolor', [0.9, 0.9, 0.9], 'edgecolor', [0.9, 0.9, 0.9]);
set(h_ax1, 'xlim', padding);
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


