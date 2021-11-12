function figure_1b(data, h_ax_up, h_ax_low)

probe_id            = 'CAA-1110264_rec1_rec2';
cluster_id          = 209;
trial_group_label   = 'RVT';
padding             = [-1, 1];
fs                  = 10000;

min_bout_duration   = 2;
include_200ms       = true;
real_motion         = true;


%%
this_data           = get_data_for_probe_id(data, probe_id);
these_trials        = this_data.get_trials_with_trial_group_label(trial_group_label);

this_cluster        = this_data.get_cluster_with_id(cluster_id);


bouts = [];
for trial_i = 1 : length(these_trials)
    
    these_bouts = these_trials{trial_i}.motion_bouts(include_200ms, real_motion);
    if isempty(these_bouts)
        continue
    end
    remove_idx = cellfun(@(x)(x.duration < min_bout_duration), these_bouts);
    these_bouts(remove_idx) = [];
    bouts = [bouts, these_bouts];
end

common_t            = this_data.timebase(padding, fs);
bout_spike_times    = {};

for ii = 1 : length(bouts)
    
    start_time = bouts{ii}.start_time;
    
    spike_idx = this_cluster.spike_times > (start_time + padding(1)) & ...
                this_cluster.spike_times < (start_time + padding(2));

    bout_spike_times{ii} = this_cluster.spike_times(spike_idx) - start_time;
    
    fr_conv(:, ii) = this_cluster.fr.get_convolution(start_time + common_t);
end

fr_mean = mean(fr_conv, 2);
fr_sem = std(fr_conv, [], 2) / sqrt(length(bouts));



%% plot
for bout_i = 1 : length(bouts)
    
    scatter(h_ax_up, bout_spike_times{bout_i}, (length(bouts) - bout_i + 1)*ones(size(bout_spike_times{bout_i})), ...
            scatterball_size(1), 'k', 'fill', 'markerfacealpha', 0.5);
end

plot(h_ax_low, common_t, fr_mean, 'color', 'k', 'linewidth', 0.75);
plot(h_ax_low, common_t, fr_mean+fr_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax_low, common_t, fr_mean-fr_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);

ylabel(h_ax_up, 'Bout #', 'fontsize', 8)
ylabel(h_ax_low, 'FR (Hz)', 'fontsize', 8)



%% format
ylim(h_ax_up, [1, length(bouts)]);
set(h_ax_up, 'ytick', [1, length(bouts)], 'yticklabels', [length(bouts), 1], 'xcolor', 'none', 'fontsize', 8)


ylim(h_ax_low, [0, 20]);
set(h_ax_low, 'ytick', [0, 10, 20], 'yticklabels', {'0', '', '20'}, 'xcolor', 'none', 'fontsize', 8)

set(h_ax_up, 'clipping', 'off');
set(h_ax_low, 'clipping', 'off');


%% Annotations
line(h_ax_low, [0, 0], [-1, 55], 'color', 'k', 'linestyle', '--', 'linewidth', 0.5);
text(h_ax_low, 0, 55, {'locomotion', 'onset'}, 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'fontsize', 6);

line(h_ax_low, [common_t(end)-0.5, common_t(end)], [-2, -2], 'color', 'k', 'linewidth', 0.5);
text(h_ax_low, common_t(end)-0.25, -2.2, '0.5s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', 'fontsize', 8);

