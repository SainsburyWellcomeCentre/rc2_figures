function figure_1b(data, h_ax_up, h_ax_down)
%%Figure 1B

probe_id            = 'CAA-1110264_rec1_rec2';
cluster_id          = 209;
trial_group_label   = 'RVT';
padding             = [-1, 1];
fs                  = 10000;

min_bout_duration   = 2;
include_200ms       = true;
real_motion         = true;


%% Data

% data for this probe ID
if isempty(data)
    ctl             = RC2Analysis();
    this_data       = ctl.load_formatted_data(probe_id);
else
    this_data       = get_data_for_probe_id(data, probe_id);
end

% trials for chosen trial group label, and chosen cluster
these_trials        = this_data.get_trials_with_trial_group_label(trial_group_label);
this_cluster        = this_data.get_cluster_with_id(cluster_id);

% loop over trials and collect motion bouts from each trial
bouts               = [];
for ii = 1 : length(these_trials)
    
    % motion bouts for this trial
    these_bouts     = these_trials{ii}.motion_bouts(include_200ms, real_motion);
    
    % if no bouts on this trial skip to next trial
    if isempty(these_bouts)
        continue
    end
    
    % remove bouts with duration less than 'min_bout_duration'
    remove_idx      = cellfun(@(x)(x.duration < min_bout_duration), these_bouts);
    these_bouts(remove_idx) = [];
    
    % append bouts from this trial
    bouts           = [bouts, these_bouts];
end

% time base for spike traces
common_t            = this_data.timebase(padding, fs);

% loop over bouts and get the convolved spike rate and spike times around
% motion bout onset
bout_spike_times    = {};
for ii = 1 : length(bouts)
    
    start_time      = bouts{ii}.start_time;
    
    % get spike times around bout onset within 'padding' of the onset
    spike_idx       = this_cluster.spike_times > (start_time + padding(1)) & ...
                      this_cluster.spike_times < (start_time + padding(2));
    bout_spike_times{ii} = this_cluster.spike_times(spike_idx) - start_time;
    
    % get convolved spike rate around bout onset
    fr_conv(:, ii)  = this_cluster.fr.get_convolution(start_time + common_t);
end

% take mean and sem of FR across bouts
fr_mean             = mean(fr_conv, 2);
fr_sem              = std(fr_conv, [], 2) ./ sqrt(sum(~isnan(fr_conv), 2));



%% Plot
for ii = 1 : length(bouts)
    scatter(h_ax_up, bout_spike_times{ii}, (length(bouts) - ii + 1)*ones(size(bout_spike_times{ii})), ...
            scatterball_size(1), 'k', 'fill', 'markerfacealpha', 0.5);
end

plot(h_ax_down, common_t, fr_mean, 'color', 'k', 'linewidth', 0.75);
plot(h_ax_down, common_t, fr_mean+fr_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);
plot(h_ax_down, common_t, fr_mean-fr_sem, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.25);


%% Format
ylabel(h_ax_up, 'Bout #', 'fontsize', 8)
ylabel(h_ax_down, 'FR (Hz)', 'fontsize', 8)

set(h_ax_up, 'xcolor', 'none', ...
             'ylim', [1, length(bouts)], ...
             'ytick', [1, length(bouts)], ...
             'yticklabels', [length(bouts), 1], ...
             'fontsize', 8, ...
             'clipping', 'off');

set(h_ax_down, 'xcolor', 'none', ...
               'ylim', [0, 20], ...
               'ytick', [0, 10, 20], ...
               'yticklabels', {'0', '', '20'}, ...
               'fontsize', 8, ...
               'clipping', 'off');


%% Annotate

% line indicating motion onset
line(h_ax_down, [0, 0], [-1, 55], 'color', 'k', 'linestyle', '--', 'linewidth', 0.5);
text(h_ax_down, 0, 55, {'locomotion', 'onset'}, 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'fontsize', 6);

% scale bars
x_scale_bar_duration    = 0.5;  % s
x_scale_bar_end         = common_t(end);
x_scale_bar_y_pos       = -2;

line(h_ax_down, x_scale_bar_end + [-x_scale_bar_duration, 0], x_scale_bar_y_pos([1, 1]), 'color', 'k', 'linewidth', 0.5);
text(h_ax_down, x_scale_bar_end-x_scale_bar_duration/2, x_scale_bar_y_pos, sprintf('%.1fs', x_scale_bar_duration), ...
    'color', 'k', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'top', ...
    'fontsize', 8);

