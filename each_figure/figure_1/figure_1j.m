function figure_1j(h_ax)

ctl             = RC2Analysis();
probe_id        = 'CAA-1110264_rec1_rec2';
cluster_id      = 209;



%% Load
svm_table = ctl.load_svm_table(probe_id);

idx = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, 'RV');
R_VF_bsl = svm_table.stationary_fr(idx);
R_VF_rsp = svm_table.motion_fr(idx);

idx = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, 'RVT');
R_VF_T_bsl = svm_table.stationary_fr(idx);
R_VF_T_rsp = svm_table.motion_fr(idx);


assert(length(R_VF_bsl) == length(R_VF_T_bsl));
n_trials = length(R_VF_bsl);



%% Plot
for i = 1 : n_trials
    line(h_ax, [1, 2], [R_VF_bsl(i), R_VF_rsp(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [2, 3], [R_VF_rsp(i), R_VF_T_bsl(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [3, 4], [R_VF_T_bsl(i), R_VF_T_rsp(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
end

scatter(h_ax, ones(size(R_VF_bsl)), R_VF_bsl, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 2*ones(size(R_VF_rsp)), R_VF_rsp, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 3*ones(size(R_VF_T_bsl)), R_VF_T_bsl, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 4*ones(size(R_VF_T_rsp)), R_VF_T_rsp, scatterball_size(0.9), 'k', 'fill')

warning('statistics is done manually... check');

p = ranksum(R_VF_bsl, R_VF_rsp);
fprintf(' bsl. vs. VF: p = %.3f\n', p);
line(h_ax, [1, 2], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 1.5, 20-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(R_VF_rsp, R_VF_T_rsp);
fprintf(' VF vs. VF+T: p = %.3f\n', p);
line(h_ax, [2, 4], [24, 24], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3, 24, 'n.s.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(R_VF_T_bsl, R_VF_T_rsp);
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

