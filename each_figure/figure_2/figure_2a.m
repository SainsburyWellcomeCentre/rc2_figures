function figure_2a(data, h_ax)

recording_id        = 'CAA-1112872_rec1_rec1b_rec2_rec3';
session_n           = 2;
trial_id            = 33;
padding             = [-1, 1];
fs                  = 10000;

traces_to_plot      = {'running', 'visual_flow', 'translation'};
vertical_spacing    = containers.Map({'translation', 'visual_flow', 'running'}, {7, 65, 120});
gain_offsets        = containers.Map({'translation', 'visual_flow', 'running'}, {0, 65, 120});
gain_heights        = containers.Map({'translation', 'visual_flow', 'running'}, {22.2209, 22.2209 0});

cols                = get_colours();
symbols             = get_symbols();

%% Get data
this_data           = get_data_for_recording_id(data, recording_id);
idx                 = [this_data.data.sessions(session_n).trials(:).id] == trial_id;
this_trial          = this_data.data.sessions(session_n).trials(idx);

mm_onset_idx        = find(diff(this_trial.teensy_gain > 2.5) == 1) + 1;
mm_offset_idx       = find(diff(this_trial.teensy_gain > 2.5) == -1) + 1;

idx_to_show = mm_onset_idx+fs*padding(1):mm_onset_idx+fs*padding(2);

traces = containers.Map({'running', 'visual_flow', 'translation'}, ...
                        {this_trial.treadmill_speed(idx_to_show), ... 
                         this_trial.multiplexer_speed(idx_to_show), ...
                         this_trial.stage_speed(idx_to_show)});

t = (idx_to_show - mm_onset_idx) * (1/fs);

t_off = t(idx_to_show == mm_offset_idx) + 0.05;


%% Plot
% AXIS 
axis_position = normpos2mmpos(get(h_ax, 'position'));
axis_height = axis_position(4);
y_size = 30*(axis_height / constants('size_30cmps'));
patch(h_ax, 'xdata', [0, t_off, t_off, 0], 'ydata', [0, 0, y_size, y_size], 'facecolor', [0.9, 0.9, 0.9], 'edgecolor', 'none');
text(h_ax, 0.125, y_size, 'slip', 'color', 'k', 'fontsize', 6, 'horizontalalignment', 'center', 'verticalalignment', 'top');

text_offset = (t(end)-t(1))*(0.1/6);

for i = 1 : length(traces_to_plot)

    plot(h_ax, t, traces(traces_to_plot{i}) + vertical_spacing(traces_to_plot{i}), ...
        'color', cols(traces_to_plot{i}))
    
    gain_trace = zeros(1, length(t));
    up_idx = t >= 0 & t < 0.05;
    gain_trace(up_idx) = gain_heights(traces_to_plot{i}) * (0:sum(up_idx)-1) / sum(up_idx);
    flat_idx = t >= 0.05 & t < t_off - 0.05;
    gain_trace(flat_idx) = gain_heights(traces_to_plot{i});
    down_idx = t >= t_off - 0.05 & t < t_off;
    gain_trace(down_idx) = gain_heights(traces_to_plot{i}) * (sum(down_idx)-1:-1:0) / sum(down_idx);
    
    plot(h_ax, t, gain_offsets(traces_to_plot{i}) + gain_trace, 'color', cols(traces_to_plot{i}));
    
    text(h_ax, t(1)-text_offset, vertical_spacing(traces_to_plot{i}), symbols(traces_to_plot{i}), ...
         'color', cols(traces_to_plot{i}), 'horizontalalignment', 'right', ...
         'verticalalignment', 'bottom', 'fontsize', 8);
     text(h_ax, t(1), gain_offsets(traces_to_plot{i}), 'gain', 'color', cols(traces_to_plot{i}), ...
         'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 6);
     
end

xlim(h_ax, t([1, end]));
ylim(h_ax, [0, y_size]);
axis(h_ax, 'off');
set(h_ax, 'clipping', 'off');


%% Annotations
% scale bars
line(h_ax, [t(end)-0.5, t(end)], [-15, -15], 'color', 'k', 'linewidth', 0.5);
line(h_ax, [t(end), t(end)]+0.1, [0, 30], 'color', 'k', 'linewidth', 0.5);

text(h_ax, t(end)-0.25, -18, '0.5s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'top', 'fontsize', 8);
text(h_ax, t(end)+0.1, 15, '30cm/s', 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'rotation', 270, 'fontsize', 8);
