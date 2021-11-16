function figure_s5i(h_ax)

ctl             = RC2Analysis();
probe_id        = 'CA_176_3_rec1_rec2_rec3';
cluster_id      = 274;


%% Data
svm_table = ctl.load_svm_table(probe_id);

idx = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, {'R'});
R_bsl = svm_table.stationary_fr(idx);
R_rsp = svm_table.motion_fr(idx);

idx = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, {'RT'});
RT_bsl = svm_table.stationary_fr(idx);
RT_rsp = svm_table.motion_fr(idx);

assert(length(R_bsl) == length(RT_bsl));
n_trials = length(R_bsl);


%% Plot
for i = 1 : n_trials
    line(h_ax, [1, 2], [R_bsl(i), R_rsp(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [2, 3], [R_rsp(i), RT_bsl(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
    line(h_ax, [3, 4], [RT_bsl(i), RT_rsp(i)], 'color', [0, 0, 0, 0.2], 'linewidth', 0.25);
end

scatter(h_ax, ones(size(R_bsl)), R_bsl, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 2*ones(size(R_rsp)), R_rsp, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 3*ones(size(RT_bsl)), RT_bsl, scatterball_size(0.9), 'k', 'fill')
scatter(h_ax, 4*ones(size(RT_rsp)), RT_rsp, scatterball_size(0.9), 'k', 'fill')

warning('statistical annotations are done manually... check');

p = ranksum(R_bsl, R_rsp);
fprintf(' bsl. vs. R: p = %.3f\n', p);
line(h_ax, [1, 2], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 1.5, 20-1, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(R_rsp, RT_rsp);
fprintf(' R vs. R+T: p = %.3f\n', p);
line(h_ax, [2, 4], [22, 22], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3, 22, 'ns', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(RT_bsl, RT_rsp);
fprintf(' bsl. vs. R+T: p = %.3f\n', p);
line(h_ax, [3, 4], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3.5, 20-1, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

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
