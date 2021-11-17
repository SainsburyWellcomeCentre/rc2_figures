function figure_s6c(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('mismatch_darkness_oct21');
trial_group_label   = 'RT_gain_up';
cols                = get_colours();


%% Data

mm                  = MismatchAnalysis();

c                   = 0;
p_val               = [];
direction           = [];
avg_baseline        = [];
avg_response        = [];
modulation_index    = [];

relative_depth      = [];
layer               = {};
anatomies           = Anatomy.empty();

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters = this_data.VISp_clusters();
    
    anatomies{ii}       = data.anatomy;
    
    trials              = this_data.get_trials_with_trial_group_label(trial_group_label);
    
    trials              = remove_invalid_mm_trials(trials);
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        
        % get relative depth within layer and label of the layer for this
        % cluster
        [relative_depth(c), layer{c}] = this_data.get_relative_layer_depth_of_cluster(clusters(jj).id);
        
        avg_baseline(c) = mm.get_avg_baseline_fr(clusters(jj), trials);
        avg_response(c) = mm.get_avg_response_fr(clusters(jj), trials);
        [~, p_val(c), direction(c)] = mm.is_response_significant(clusters(jj), trials);
        
        modulation_index(c) = (avg_response(c) - avg_baseline(c)) / (avg_response(c) + avg_baseline(c));
    end
end

avg_anatomy = AverageAnatomy(anatomies);
averaged_cortical_position = avg_anatomy.from_pia_using_relative_position(relative_depth, layer);


%% Plot

x_limits = [-1, 1];
histogram_edges = -1:0.1:1;

layer_height_mm = 19.576;
axis_to_layers_mm = 9.655;
subaxis_height_mm = 2.883;
subaxis_y_offset = 1.345;


% get averaged VISp layer boundaries
boundaries = avg_anatomy.average_VISp_boundaries_from_pia;
% merge VISp6a and VIS6b
layer_str = {'L1', 'L2/3', 'L4', 'L5', 'L6'};
boundaries(end-1) = [];

% amount of space for histogram at bottom in y-axis units
cortical_thickness = range(avg_anatomy.average_VISp_boundaries_from_pia);
space_for_histogram = cortical_thickness * (axis_to_layers_mm / layer_height_mm); 

% y-limits of the whole axis including the histogram at bottom (we will
% reverse the y-axis later, so for now space is at the top)
y_limits = [boundaries(1), boundaries(end) + space_for_histogram];

% plot the boundaries and text
for ii = 1 : length(boundaries)
    
    line(h_ax, x_limits, boundaries([ii, ii]), 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
    
    % print layer text
    if ii < length(boundaries)
        x_pos = x_limits(1) - 0.15 * range(x_limits);
        text(h_ax, x_pos, mean(boundaries([ii, ii+1])), layer_str{ii}, ...
                'color', 'k', ...
                'fontsize', 8, ...
                'horizontalalignment', 'center', ...
                'verticalalignment', 'middle');
    end
end



idx = direction == 0;
scatter(h_ax, modulation_index(idx), averaged_cortical_position(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
n_no_change = histcounts(modulation_index(idx), histogram_edges);

idx = direction == 1;
scatter(h_ax, modulation_index(idx), averaged_cortical_position(idx), scatterball_size(1.25), cols('sig_increase'));
n_increase = histcounts(modulation_index(idx), histogram_edges);

idx = direction == -1;
scatter(h_ax, modulation_index(idx), averaged_cortical_position(idx), scatterball_size(1.25), cols('sig_decrease'));
n_decrease = histcounts(modulation_index(idx), histogram_edges);



set(h_ax, 'xlim', x_limits, ...
          'xtick', [-1, 0, 1], ...
          'ylim', y_limits, ...
          'ycolor', 'none', ...
          'ydir', 'reverse', ...
          'fontsize', 8, ...
          'color', 'none');

xlabel(h_ax, 'Modulation index', 'fontsize', 8);
   
text(h_ax, 0, h_ax.YLim(1) - 0.02*range(h_ax.YLim), 'R:T', ...
    'fontsize', 8, ...
    'fontweight', 'normal', ...
    'horizontalalignment', 'center', ...
    'verticalalignment', 'bottom')

% position of the axis we have just used to plot depth vs MI
original_axis_position = get(h_ax, 'position');

% height of axis for histogram (ratio of original axis)
subaxis_height_ratio = subaxis_height_mm / (layer_height_mm + axis_to_layers_mm);

% height offset of this axis (ratio of original axis)
subaxis_y_offset_ratio = subaxis_y_offset / (layer_height_mm + axis_to_layers_mm);

% position of new axis
subaxis_position = [original_axis_position(1), ...
                    original_axis_position(2) + subaxis_y_offset_ratio * original_axis_position(4), ...
                    original_axis_position(3), ...
                    subaxis_height_ratio * original_axis_position(4)];

% create new axis on A4 paper
sub_h_ax = a4axis(h_ax.Parent, normpos2mmpos(subaxis_position));

% maximun count in any of the bins
max_count = max([n_no_change, n_increase, n_decrease]);

% plot the histogram as individual bins
for i = 1 : length(histogram_edges)-1
    
    if n_no_change(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_no_change(i), n_no_change(i)]/max_count, ...
                        'facecolor', [0.8, 0.8, 0.8], 'edgecolor', [0.8, 0.8, 0.8]);
    end
    
    if n_increase(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_increase(i), n_increase(i)]/max_count, ...
                        'facecolor', 'none', 'edgecolor', cols('sig_increase'));
    end
    
    if n_decrease(i) > 0
        patch(sub_h_ax, 'xdata', histogram_edges([i, i+1, i+1, i]), ...
                        'ydata', [0, 0, n_decrease(i), n_decrease(i)]/max_count, ...
                        'facecolor', 'none', 'edgecolor', cols('sig_decrease'));
    end
    
end


set(sub_h_ax, 'xlim', x_limits, ...
              'xtick', [], ...
              'ylim', [0, 1], ...
              'fontsize', 8, ...
              'clipping', 'off');

% draw line from bottom of axis to top
sub_y_limits = [0, 1];
line_length = range(sub_y_limits) * ((layer_height_mm+axis_to_layers_mm-subaxis_y_offset)/subaxis_height_mm);

line(sub_h_ax, [0, 0], sub_y_limits(1) + [0, line_length], 'color', 'k', 'linewidth', 0.5);
set(sub_h_ax, 'ylim', sub_y_limits, 'ytick', sub_y_limits, 'yticklabel', [0, 1], 'layer', 'top');
ylabel(sub_h_ax, {'norm.', 'count'}, 'fontsize', 8);
