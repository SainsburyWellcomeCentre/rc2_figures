function figure_2i(data, h_ax)

ctl                 = RC2Analysis();

probe_ids           = ctl.get_probe_ids('darkness', 'mismatch_darkness_oct21');

cols                = get_colours();

cluster_count       = 0;
R_p_val             = [];
T_p_val             = [];

for ii = 1 : length(probe_ids)
    
    % extract data for probe ID
    this_data = get_data_for_probe_id(data, probe_ids{ii});
    % VISp clusters
    clusters = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
        
        cluster_count = cluster_count + 1;
        
        [~, R_p_val(cluster_count)] = this_data.is_stationary_vs_motion_significant(clusters(jj).id, 'R');
        [~, T_p_val(cluster_count)] = this_data.is_stationary_vs_motion_significant(clusters(jj).id, {'T_bank', 'T_RT', 'T_R', 'T'});
    end
end


%% plot

hold on;
A = R_p_val < 0.05;
B = T_p_val < 0.05;

% make sure they overlap completely otherwise something more complicated is
% required
% assert(sum(A&B) == sum(B));
% 
% base_diameter_mm = 25;
% key_size = 3.1;
% 
% base_area_mm_2 = pi * (base_diameter_mm / 2)^2;
% 
% A_area_mm = base_area_mm_2 * (sum(A)/length(A));
% A_radius_mm = sqrt(A_area_mm / pi);
% 
% B_area_mm = base_area_mm_2 * (sum(B)/length(A));
% B_radius_mm = sqrt(B_area_mm / pi);
% 
% 
% % do something simple because they overlap completely
% scatter(h_ax, -base_diameter_mm/2, 0, scatterball_size(base_diameter_mm), 'markerfacecolor', 'k', 'markeredgecolor', 'none', 'markerfacealpha', 0.1);
% scatter(h_ax, -A_radius_mm, 0, scatterball_size(2 * A_radius_mm), 'markerfacecolor', cols('running'), 'markeredgecolor', 'none','markerfacealpha', 0.3);
% scatter(h_ax, -B_radius_mm, 0, scatterball_size(2 * B_radius_mm), 'markerfacecolor', cols('translation'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);
% 
% xlim(h_ax, [-base_diameter_mm, 0])
% ylim(h_ax, [-base_diameter_mm/2, base_diameter_mm/2])
% 
% axis(h_ax, 'off');
% set(h_ax, 'clipping', 'off');
% 
% prc_R = 100*sum(A)/length(B);
% prc_T = 100*sum(B)/length(B);
% 
% text(h_ax, -base_diameter_mm * 1.2, 0, sprintf('%.1f%%', prc_R), 'fontsize', 8, 'color', cols('running'), 'horizontalalignment', 'center', 'verticalalignment', 'middle');
% text(h_ax, -B_radius_mm, 0, sprintf('%.1f%%', prc_T), 'fontsize', 8, 'color', cols('translation'), 'horizontalalignment', 'center', 'verticalalignment', 'middle');
% 
% scatter(h_ax, -base_diameter_mm * 1.2, base_diameter_mm/2 + base_diameter_mm*0.1, scatterball_size(key_size), 'markerfacecolor', 'k', 'markeredgecolor', 'none', 'markerfacealpha', 0.1);
% scatter(h_ax, -base_diameter_mm * 1.2, base_diameter_mm/2 + base_diameter_mm*0.1 - key_size, scatterball_size(key_size), 'markerfacecolor', cols('running'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);
% scatter(h_ax, -base_diameter_mm * 1.2, base_diameter_mm/2 + base_diameter_mm*0.1 - 2*key_size, scatterball_size(key_size), 'markerfacecolor', cols('translation'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);
% 
% text(h_ax, -base_diameter_mm * 1.15 + key_size/2, base_diameter_mm/2 + base_diameter_mm*0.1, 'all cells', 'fontsize', 6, 'color', 'k', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
% col_str = sprintf('\\color[rgb]{%.3f,%.3f,%.3f}R', cols('running'), cols('visual_flow'));
% text(h_ax, -base_diameter_mm * 1.15 + key_size/2, base_diameter_mm/2 + base_diameter_mm*0.1 - key_size, col_str, 'fontsize', 6, 'horizontalalignment', 'left', 'verticalalignment', 'middle');
% col_str = sprintf('\\color[rgb]{%.3f,%.3f,%.3f}T', cols('translation'), cols('visual_flow'));
% text(h_ax, -base_diameter_mm * 1.15 + key_size/2, base_diameter_mm/2 + base_diameter_mm*0.1 - 2*key_size, col_str, 'fontsize', 6, 'color', cols('translation'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');
% 
% line(h_ax, -base_diameter_mm - 0.5 + [0, 4.2], [0, -1.2], 'color', 'k', 'linewidth', 0.5);




% Potentially if something more complicated required:
s = SimpleVenn(h_ax);
s.A = sum(A);
s.B = sum(B);
s.A_and_B = sum(A & B);
s.N = length(A);
s.name_A = '';
s.name_B = '';
s.all_col = 'k';
s.A_col = cols('running');
s.B_col = cols('translation');
s.plot(true);
set(s.h_all_patch, 'facealpha', 0.1, 'edgecolor', 'none');
set(s.h_A_patch, 'facealpha', 0.3, 'edgecolor', 'none');
set(s.h_B_patch, 'facealpha', 0.3, 'edgecolor', 'none');
axis(h_ax, 'off');
set(h_ax, 'clipping', 'off');

x_limits = [min(s.h_all_patch.XData), max(s.h_all_patch.XData)];
y_limits = [min(s.h_all_patch.YData), max(s.h_all_patch.YData)];
key_size = 3.1;

x_pos = x_limits(1) - 0.28 * range(x_limits);
scatter(h_ax, x_pos, y_limits(2) + 0.12*range(y_limits), scatterball_size(key_size), 'markerfacecolor', 'k', 'markeredgecolor', 'none', 'markerfacealpha', 0.1);
scatter(h_ax, x_pos, y_limits(2) - 0*range(y_limits), scatterball_size(key_size), 'markerfacecolor', cols('running'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);
scatter(h_ax, x_pos, y_limits(2) - 0.12*range(y_limits), scatterball_size(key_size), 'markerfacecolor', cols('translation'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);

set(h_ax, 'xlim', x_limits', 'ylim', y_limits);

x_pos = x_limits(1) - 0.2 * range(x_limits);
text(h_ax, x_pos, y_limits(2) + 0.12*range(y_limits), 'all cells', 'fontsize', 6, 'color', 'k', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
col_str = sprintf('\\color[rgb]{%.3f,%.3f,%.3f}R', cols('running'));
text(h_ax, x_pos, y_limits(2) + 0*range(y_limits), col_str, 'fontsize', 6, 'horizontalalignment', 'left', 'verticalalignment', 'middle');
col_str = sprintf('\\color[rgb]{%.3f,%.3f,%.3f}T', cols('translation'));
text(h_ax, x_pos, y_limits(2) - 0.12*range(y_limits), col_str, 'fontsize', 6, 'color', cols('translation'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');

prc_R = 100*sum(A & ~B)/length(B);
prc_T = 100*sum(B & ~A)/length(B);
prc_R_and_T = 100*sum(A & B)/length(B);



text(h_ax, 0, 0, sprintf('%.0f%%', prc_R_and_T), 'fontsize', 8, 'color', 'k', 'horizontalalignment', 'center', 'verticalalignment', 'middle');
text(h_ax, 0.25, 0, sprintf('%.0f%%', prc_T), 'fontsize', 8, 'color', cols('translation'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');
text(h_ax, -0.25, 0, sprintf('%.0f%%', prc_R), 'fontsize', 8, 'color', cols('running'), 'horizontalalignment', 'right', 'verticalalignment', 'middle');


% line(h_ax, -base_diameter_mm - 0.5 + [0, 4.2], [0, -1.2], 'color', 'k', 'linewidth', 0.5);


