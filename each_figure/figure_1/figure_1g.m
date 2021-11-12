function figure_1g(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('visual_flow');
VF_trial_groups     = {'V_RVT', 'V_RV'};
VF_T_trial_groups   = {'VT_RVT', 'VT_RV'};

c                   = 0;
x_med               = [];
y_med               = [];
direction           = [];

for ii = 1 : length(probe_ids)
    
    this_data   = get_data_for_probe_id(data, probe_ids{ii});
    clusters    = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
        
        c = c + 1;
        [~, ~, direction(c), x_med(c), y_med(c)] = this_data.is_motion_vs_motion_significant(clusters(jj).id, VF_trial_groups, VF_T_trial_groups);
    end
end



%% Plot
fmt.xy_limits       = [0, 60];
fmt.tick_space      = 20;
fmt.line_order      = 'top';
fmt.xlabel          = 'FR VF (Hz)';
fmt.ylabel          = 'FR VF+T (Hz)';
fmt.include_inset   = true;
fmt.colour_by       = 'significance';

unity_plot_plot(h_ax, x_med, y_med, direction, fmt);




% ctl         = RC2Analysis();
% probe_ids   = ctl.get_probe_ids('visual_flow');
% 
% 
% VF_trial_groups = {'V_RVT', 'V_RV'};
% VF_T_trial_groups = {'VT_RVT', 'VT_RV'};
% 
% cols        = get_colours();
% 
% VF_med      = [];
% VF_T_med    = [];
% p_val       = [];
% direction   = [];
% cluster_count = 0;
% 
% 
% for ii = 1 : length(probe_ids)
%     
%     if ~isempty(data)
%         this_data = get_data_for_probe_id(data, probe_ids{ii});
%     else
%         this_data = ctl.load_formatted_data(probe_ids{ii});
%     end
%     
%     clusters = this_data.VISp_clusters();
%     
%     for jj = 1 : length(clusters)
%         
%         VF = this_data.motion_fr_for_trial_group(clusters(jj).id, VF_trial_groups);
%         VF_T = this_data.motion_fr_for_trial_group(clusters(jj).id, VF_T_trial_groups);
%         
%         cluster_count = cluster_count + 1;
%         VF_med(cluster_count) = nanmedian(VF);
%         VF_T_med(cluster_count) = nanmedian(VF_T);
%         
%         if clusters(jj).id == 401
%             disp('')
%         end
%         [~, p_val(cluster_count), direction(cluster_count)] = this_data.is_motion_vs_motion_significant(clusters(jj).id, {'V_RVT', 'V_RV'}, {'VT_RVT', 'VT_RV'});
%         cluster_id(cluster_count) = clusters(jj).id;
%         probe_id(cluster_count) = ii;
%     end
% end
% 
% 
% 
% %% Plot
% xy_limits = [0, 70];
% 
% line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
% line(h_ax, xy_limits, xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
% 
% idx = direction == 0;
% scatter(h_ax, VF_med(idx), VF_T_med(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
% idx = direction == 1;
% scatter(h_ax, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_increase'));
% idx = direction == -1;
% scatter(h_ax, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_decrease'));
% 
% set(h_ax, 'xlim', xy_limits, ...
%           'xtick', 0:20:xy_limits(2), ...
%           'xticklabel', {'0', '', '', '60'}, ...
%           'ylim', xy_limits, ...
%           'ytick', 0:20:xy_limits(2), ...
%           'yticklabel', {'0', '', '', '60'}, ...
%           'fontsize', 8, ...
%           'clipping', 'off');
% xlabel(h_ax, 'FR VF (Hz)', 'fontsize', 8);
% ylabel(h_ax, 'FR VF+T (Hz)', 'fontsize', 8);
% 
% text(h_ax, 3, 40, sprintf('%.1f%%', 100*sum(direction == 1)/length(direction)), 'color', 'k', 'fontsize', 8, ...
%     'color', cols('sig_increase'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');
% text(h_ax, 40, 3, sprintf('%.1f%%', 100*sum(direction == -1)/length(direction)), 'color', 'k', 'fontsize', 8, ...
%     'color', cols('sig_decrease'), 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
% 
% 
% 
% % inset
% axis_position = get(h_ax, 'position');
% 
% inset_offset_units  = 45;
% inset_size_units    = 25;
% inset_pad           = 3;
% inset_xy_limits     = [0, 5];
% 
% inset_axis_position(1) = axis_position(1) + (inset_offset_units/xy_limits(2)) * axis_position(3);
% inset_axis_position(2) = axis_position(2) + (inset_offset_units/xy_limits(2)) * axis_position(4);
% inset_axis_position(3) = (inset_size_units/xy_limits(2)) * axis_position(3);
% inset_axis_position(4) = (inset_size_units/xy_limits(2)) * axis_position(4);
% 
% patch(h_ax, 'xdata', [inset_offset_units-inset_pad, ...
%              inset_offset_units+inset_size_units+inset_pad, ...
%              inset_offset_units+inset_size_units+inset_pad, ...
%              inset_offset_units-inset_pad], ...
%             'ydata', [inset_offset_units-inset_pad, ...
%              inset_offset_units-inset_pad, ...
%              inset_offset_units+inset_size_units+inset_pad, ...
%              inset_offset_units+inset_size_units+inset_pad], ...
%             'facecolor', [0.9, 0.9, 0.9], ...
%             'edgecolor', 'none');
% 
% h_inset = axes('position', inset_axis_position);
% hold on;
% 
% idx = direction == 0;
% scatter(h_inset, VF_med(idx), VF_T_med(idx), scatterball_size(0.73), [0.5, 0.5, 0.5]);
% idx = direction == 1;
% scatter(h_inset, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_increase'));
% idx = direction == -1;
% scatter(h_inset, VF_med(idx), VF_T_med(idx), scatterball_size(1.25), cols('sig_decrease'));
% 
% 
% line(h_inset, inset_xy_limits, inset_xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
% line(h_inset, inset_xy_limits, inset_xy_limits, 'color', 'k', 'linewidth', 0.5, 'linestyle', '--');
% 
% set(h_inset, 'xlim', inset_xy_limits, ...
%           'xtick', inset_xy_limits, ...
%           'xticklabel', '', ...
%           'ylim', inset_xy_limits, ...
%           'ytick', inset_xy_limits, ...
%           'yticklabel', '');
% 
