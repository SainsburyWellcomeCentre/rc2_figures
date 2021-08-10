function figure_1g(data, h_ax)

csv_dir = 'D:\mvelez\summary_data\stationary_vs_motion_fr';

recording_ids       = experiment_details('visual_flow');

cols = get_colours();

VF_med = [];
VF_T_med = [];
p_val = [];
change = {};
cluster_count = 0;


for rec_i = 1 : length(recording_ids)
    
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    
    csv_fname = fullfile(csv_dir, sprintf('%s.csv', recording_ids{rec_i}));
    svm_table = readsvmtable(csv_fname);
    
    clusters = this_data.VISp_clusters();
    
    for clust_i = 1 : length(clusters)
        
        idx = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'ReplayOnly';
        VF = svm_table.motion_firing_rate(idx);
        
        idx = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'StageOnly';
        VF_T = svm_table.motion_firing_rate(idx);
        
        cluster_count = cluster_count + 1;
        VF_med(cluster_count) = nanmedian(VF);
        VF_T_med(cluster_count) = nanmedian(VF_T);
        [p_val(cluster_count), ~, stats] = signrank(VF, VF_T);
        
        % catch cases where medians are equal but there is a significant
        % difference between the groups
        if p_val(cluster_count) < 0.05
            
            if VF_med(cluster_count) == VF_T_med(cluster_count)
                
                [~, ~, stats_opp] = signrank(VF, VF_T);
                if stats_opp.signedrank > stats.signedrank
                    change{cluster_count} = 'increase';
                elseif stats_opp.signedrank < stats.signedrank
                    change{cluster_count} = 'decrease';
                else
                    error('Signed ranks are equal?');
                end
                
            elseif VF_med(cluster_count) < VF_T_med(cluster_count)
                
                change{cluster_count} = 'increase';
            elseif VF_med(cluster_count) > VF_T_med(cluster_count)
                
                change{cluster_count} = 'decrease';
            end
            
        elseif p_val(cluster_count) >= 0.05
            
            change{cluster_count} = 'no_change';
        else
            warning('p value not numeric');
        end
    end
end


%% Plot
xy_limits = [0, 70];

line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');

idx = strcmp(change, 'no_change');
scatter(h_ax, VF_med(idx), VF_T_med(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
idx = strcmp(change, 'increase');
scatter(h_ax, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_increase'));
idx = strcmp(change, 'decrease');
scatter(h_ax, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_decrease'));

set(h_ax, 'xlim', xy_limits, ...
          'xtick', 0:20:xy_limits(2), ...
          'xticklabel', {'0', '', '', '60'}, ...
          'ylim', xy_limits, ...
          'ytick', 0:20:xy_limits(2), ...
          'yticklabel', {'0', '', '', '60'}, ...
          'fontsize', 8, ...
          'clipping', 'off');
xlabel(h_ax, 'FR VF (Hz)', 'fontsize', 8);
ylabel(h_ax, 'FR VF+T (Hz)', 'fontsize', 8);

text(h_ax, 3, 40, sprintf('%.1f%%', 100*sum(strcmp(change, 'increase'))/length(change)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_increase'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');
text(h_ax, 40, 3, sprintf('%.0f%%', 100*sum(strcmp(change, 'decrease'))/length(change)), 'color', 'k', 'fontsize', 8, ...
    'color', cols('sig_decrease'), 'horizontalalignment', 'center', 'verticalalignment', 'bottom');



% inset
axis_position = get(h_ax, 'position');

inset_offset_units  = 45;
inset_size_units    = 25;
inset_pad           = 3;
inset_xy_limits     = [0, 5];

inset_axis_position(1) = axis_position(1) + (inset_offset_units/xy_limits(2)) * axis_position(3);
inset_axis_position(2) = axis_position(2) + (inset_offset_units/xy_limits(2)) * axis_position(4);
inset_axis_position(3) = (inset_size_units/xy_limits(2)) * axis_position(3);
inset_axis_position(4) = (inset_size_units/xy_limits(2)) * axis_position(4);

patch(h_ax, 'xdata', [inset_offset_units-inset_pad, ...
             inset_offset_units+inset_size_units+inset_pad, ...
             inset_offset_units+inset_size_units+inset_pad, ...
             inset_offset_units-inset_pad], ...
            'ydata', [inset_offset_units-inset_pad, ...
             inset_offset_units-inset_pad, ...
             inset_offset_units+inset_size_units+inset_pad, ...
             inset_offset_units+inset_size_units+inset_pad], ...
            'facecolor', [0.9, 0.9, 0.9], ...
            'edgecolor', 'none');

h_inset = axes('position', inset_axis_position);
hold on;

idx = strcmp(change, 'no_change');
scatter(h_inset, VF_med(idx), VF_T_med(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
idx = strcmp(change, 'increase');
scatter(h_inset, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_increase'));
idx = strcmp(change, 'decrease');
scatter(h_inset, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_decrease'));


line(h_inset, inset_xy_limits, inset_xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
line(h_inset, inset_xy_limits, inset_xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');

set(h_inset, 'xlim', inset_xy_limits, ...
          'xtick', inset_xy_limits, ...
          'xticklabel', '', ...
          'ylim', inset_xy_limits, ...
          'ytick', inset_xy_limits, ...
          'yticklabel', '');

