function figure_1j(h_ax)
%%Figure 1J

probe_id                = 'CAA-1110264_rec1_rec2';
cluster_id              = 209;
RV_trial_group_labels   = 'RV';
RVT_trial_group_labels  = 'RVT';


%% Load

[RV_bsl, RV_rsp, RVT_bsl, RVT_rsp] = line_plot_data(probe_id, cluster_id, RV_trial_group_labels, RVT_trial_group_labels);


%% Plot
fmt.y_limits = [0, 20];
fmt.y_ticks = 0:10:20;
fmt.labels = {'bsl.', 'R+VF', 'bsl.', 'R+VF+T'};

line_plot_plot(h_ax, RV_bsl, RV_rsp, RVT_bsl, RVT_rsp, fmt);


%% Annotate

warning('statistical annotations are done manually... check!');

p = ranksum(RV_bsl, RV_rsp);
fprintf('   bsl. vs. R+VF: p = %.3f\n', p);
line(h_ax, [1, 2], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 1.5, 20-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(RV_rsp, RVT_rsp);
fprintf('   R+VF vs. R+VF+T: p = %.3f\n', p);
line(h_ax, [2, 4], [24, 24], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3, 24, 'n.s.', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

p = ranksum(RVT_bsl, RVT_rsp);
fprintf('   bsl. vs. R+VF+T: p = %.3f\n', p);
line(h_ax, [3, 4], [20, 20], 'color', 'k', 'linewidth', 0.5);
text(h_ax, 3.5, 20-2.5, '*', 'color', 'k', 'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
