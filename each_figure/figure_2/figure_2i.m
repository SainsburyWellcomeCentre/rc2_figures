function figure_2i(data, h_ax)

csv_dir = 'D:\mvelez\summary_data\stationary_vs_motion_fr';

recording_ids       = experiment_details('visual_flow');

cols                = get_colours();

cluster_count       = 0;
R_VF_p_val          = [];
T_VF_p_val          = [];

for rec_i = 1 : length(recording_ids)
    
    this_data = get_data_for_recording_id(data, recording_ids{rec_i});
    
    csv_fname = fullfile(csv_dir, sprintf('%s.csv', recording_ids{rec_i}));
    svm_table = readsvmtable(csv_fname);
    
    clusters = this_data.VISp_clusters();
    
    for clust_i = 1 : length(clusters)
        
        idx_rvf = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'EncoderOnly';
        idx_tvf = svm_table.cluster_id == clusters(clust_i).id & svm_table.protocol == 'StageOnly' & svm_table.replay_of == 'EncoderOnly';
        
        R_VF_mot = svm_table.motion_firing_rate(idx_rvf);
        R_VF_stat = svm_table.stationary_firing_rate(idx_rvf);
        
        T_VF_mot = svm_table.motion_firing_rate(idx_tvf);
        T_VF_stat = svm_table.stationary_firing_rate(idx_tvf);
        
        cluster_count = cluster_count + 1;
        
        R_VF_p_val(cluster_count) = signrank(R_VF_mot, R_VF_stat);
        T_VF_p_val(cluster_count) = signrank(T_VF_mot, T_VF_stat);
        
    end
end

%% plot

A = R_VF_p_val < 0.05;
B = T_VF_p_val < 0.05;

% make sure they overlap completely otherwise something more complicated is
% required
assert(sum(A&B) == sum(B));

base_diameter_mm = 25;
key_size = 3.1;

base_area_mm_2 = pi * (base_diameter_mm / 2)^2;

A_area_mm = base_area_mm_2 * (sum(A)/length(A));
A_radius_mm = sqrt(A_area_mm / pi);

B_area_mm = base_area_mm_2 * (sum(B)/length(A));
B_radius_mm = sqrt(B_area_mm / pi);


% do something simple because they overlap completely
scatter(h_ax, -base_diameter_mm/2, 0, scatterball_size(base_diameter_mm), 'markerfacecolor', 'k', 'markeredgecolor', 'none', 'markerfacealpha', 0.1);
scatter(h_ax, -A_radius_mm, 0, scatterball_size(2 * A_radius_mm), 'markerfacecolor', cols('running'), 'markeredgecolor', 'none','markerfacealpha', 0.3);
scatter(h_ax, -B_radius_mm, 0, scatterball_size(2 * B_radius_mm), 'markerfacecolor', cols('translation'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);

xlim(h_ax, [-base_diameter_mm, 0])
ylim(h_ax, [-base_diameter_mm/2, base_diameter_mm/2])

axis(h_ax, 'off');
set(h_ax, 'clipping', 'off');

prc_R_VF = 100*sum(A)/length(B);
prc_T_VF = 100*sum(B)/length(B);

text(h_ax, -base_diameter_mm * 1.2, 0, sprintf('%.1f%%', prc_R_VF), 'fontsize', 8, 'color', cols('running'), 'horizontalalignment', 'center', 'verticalalignment', 'middle');
text(h_ax, -B_radius_mm, 0, sprintf('%.1f%%', prc_T_VF), 'fontsize', 8, 'color', cols('translation'), 'horizontalalignment', 'center', 'verticalalignment', 'middle');

scatter(h_ax, -base_diameter_mm * 1.2, base_diameter_mm/2 + base_diameter_mm*0.1, scatterball_size(key_size), 'markerfacecolor', 'k', 'markeredgecolor', 'none', 'markerfacealpha', 0.1);
scatter(h_ax, -base_diameter_mm * 1.2, base_diameter_mm/2 + base_diameter_mm*0.1 - key_size, scatterball_size(key_size), 'markerfacecolor', cols('running'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);
scatter(h_ax, -base_diameter_mm * 1.2, base_diameter_mm/2 + base_diameter_mm*0.1 - 2*key_size, scatterball_size(key_size), 'markerfacecolor', cols('translation'), 'markeredgecolor', 'none', 'markerfacealpha', 0.3);


text(h_ax, -base_diameter_mm * 1.15 + key_size/2, base_diameter_mm/2 + base_diameter_mm*0.1, 'all cells', 'fontsize', 6, 'color', 'k', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
col_str = sprintf('\\color[rgb]{%.3f,%.3f,%.3f}R\\color{black}+\\color[rgb]{%.3f,%.3f,%.3f}VF', cols('running'), cols('visual_flow'));
text(h_ax, -base_diameter_mm * 1.15 + key_size/2, base_diameter_mm/2 + base_diameter_mm*0.1 - key_size, col_str, 'fontsize', 6, 'horizontalalignment', 'left', 'verticalalignment', 'middle');
col_str = sprintf('\\color[rgb]{%.3f,%.3f,%.3f}T\\color{black}+\\color[rgb]{%.3f,%.3f,%.3f}VF', cols('translation'), cols('visual_flow'));
text(h_ax, -base_diameter_mm * 1.15 + key_size/2, base_diameter_mm/2 + base_diameter_mm*0.1 - 2*key_size, col_str, 'fontsize', 6, 'color', cols('translation'), 'horizontalalignment', 'left', 'verticalalignment', 'middle');

line(h_ax, -base_diameter_mm - 0.5 + [0, 4.2], [0, -1.2], 'color', 'k', 'linewidth', 0.5);

% Potentially if something more complicated required:
% s = SimpleVenn(h_ax);
% s.A = sum(A);
% s.B = sum(B);
% s.A_and_B = sum(A & B);
% s.N = length(A);
% s.name_A = '';
% s.name_B = '';
% s.all_col = 'k';
% s.A_col = cols('running');
% s.B_col = cols('translation');
% s.plot(true);
% set(s.h_all_patch, 'facealpha', 0.1);
% set(s.h_A_patch, 'facealpha', 0.3);
% set(s.h_B_patch, 'facealpha', 0.3);


