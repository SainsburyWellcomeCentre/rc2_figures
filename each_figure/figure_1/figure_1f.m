function figure_1f(h_ax)
%%Figure 1F

probe_id                = 'CAA-1110264_rec1_rec2';
cluster_id              = 209;
V_trial_group_labels    = {'V_RVT', 'V_RV'};
VT_trial_group_labels   = {'VT_RVT', 'VT_RV'};


%% Load

[V_bsl, V_rsp, VT_bsl, VT_rsp] = line_plot_data(probe_id, cluster_id, V_trial_group_labels, VT_trial_group_labels);


%% Plot
fmt.y_limits = [0, 20];
fmt.y_ticks = 0:10:20;
fmt.labels = {'bsl.', 'VF', 'bsl.', 'VF+T'};

line_plot_plot(h_ax, V_bsl, V_rsp, VT_bsl, VT_rsp, fmt);


%% Annotate

warning('statistical annotations are done manually... check!');

p = ranksum(V_bsl, V_rsp);
fprintf('   bsl. vs. VF: p = %.3f\n', p);
line(h_ax, [1, 2], [9, 9], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 1.5, 9-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(V_rsp, VT_rsp);
fprintf('   VF vs. VF+T: p = %.3f\n', p);
line(h_ax, [2, 4], [22, 22], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3, 22-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(VT_bsl, VT_rsp);
fprintf('   bsl. vs. VF+T: p = %.3f\n', p);
line(h_ax, [3, 4], [18, 18], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3.5, 18-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
