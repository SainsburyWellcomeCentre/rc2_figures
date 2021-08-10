function figure_1j(data, h_ax)

csv_dir = 'D:\mvelez\summary_data\stationary_vs_motion_fr';
recording_id = 'CAA-1110264_rec1_rec2';
cluster_id = 209;



%% Load
csv_fname = fullfile(csv_dir, sprintf('%s.csv', recording_id));
svm_table = readsvmtable(csv_fname);


idx = svm_table.cluster_id == cluster_id & svm_table.protocol == 'EncoderOnly';
VF_bsl = svm_table.stationary_firing_rate(idx);
VF_rsp = svm_table.motion_firing_rate(idx);

idx = svm_table.cluster_id == cluster_id & svm_table.protocol == 'Coupled';
VF_T_bsl = svm_table.stationary_firing_rate(idx);
VF_T_rsp = svm_table.motion_firing_rate(idx);


assert(length(VF_bsl) == length(VF_T_bsl));
n_trials = length(VF_bsl);



%% Plot
for i = 1 : n_trials
    line(h_ax, [1, 2], [VF_bsl(i), VF_rsp(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [2, 3], [VF_rsp(i), VF_T_bsl(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [3, 4], [VF_T_bsl(i), VF_T_rsp(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
end

scatter(h_ax, ones(size(VF_bsl)), VF_bsl, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 2*ones(size(VF_rsp)), VF_rsp, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 3*ones(size(VF_T_bsl)), VF_T_bsl, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 4*ones(size(VF_T_rsp)), VF_T_rsp, scatterball_size(0.9), 'k', 'fill')

warning('statistics is done manually... check');

p = ranksum(VF_bsl, VF_rsp);
fprintf(' bsl. vs. VF: p = %.3f\n', p);
line(h_ax, [1, 2], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 1.5, 20-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(VF_rsp, VF_T_rsp);
fprintf(' VF vs. VF+T: p = %.3f\n', p);
line(h_ax, [2, 4], [24, 24], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3, 24, 'n.s.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(VF_T_bsl, VF_T_rsp);
fprintf(' bsl. vs. VF+T: p = %.3f\n', p);
line(h_ax, [3, 4], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3.5, 20-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');


set(h_ax, 'xlim', [0.5, 4.5], ...
          'xtick', [], ...
          'ylim', [0, 20], ...
          'ytick', 0:10:20, ...
          'yticklabel', {'0', '', '20'}, ...
          'fontsize', 8, ...
          'clipping', 'off');
ylabel(h_ax, 'FR (Hz)', 'fontsize', 8);

text(h_ax, 1, -2, 'bsl.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 2, -2, 'R+VF', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 3, -2, 'bsl.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 4, -2, 'R+VF+T', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');

