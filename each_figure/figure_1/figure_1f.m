function figure_1f(h_ax)

ctl             = RC2Analysis();
probe_id        = 'CAA-1110264_rec1_rec2';
cluster_id      = 209;



%% Load
svm_table = ctl.load_svm_table(probe_id);

idx = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, {'V_RVT', 'V_RV'});
VF_bsl = svm_table.stationary_fr(idx);
VF_rsp = svm_table.motion_fr(idx);

idx = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, {'VT_RVT', 'VT_RV'});
VF_T_bsl = svm_table.stationary_fr(idx);
VF_T_rsp = svm_table.motion_fr(idx);


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
line(h_ax, [1, 2], [9, 9], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 1.5, 9-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(VF_rsp, VF_T_rsp);
fprintf(' VF vs. VF+T: p = %.3f\n', p);
line(h_ax, [2, 4], [22, 22], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3, 22-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(VF_T_bsl, VF_T_rsp);
fprintf(' bsl. vs. VF+T: p = %.3f\n', p);
line(h_ax, [3, 4], [18, 18], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3.5, 18-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');


set(h_ax, 'xlim', [0.5, 4.5], ...
          'xtick', [], ...
          'ylim', [0, 20], ...
          'ytick', 0:10:20, ...
          'yticklabel', {'0', '', '20'}, ...
          'fontsize', 8, ...
          'clipping', 'off');
ylabel(h_ax, 'FR (Hz)', 'fontsize', 8);

text(h_ax, 1, -2, 'bsl.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 2, -2, 'VF', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 3, -2, 'bsl.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(h_ax, 4, -2, 'VF+T', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'top');

