function [bsl_1, rsp_1, bsl_2, rsp_2] = line_plot_data(probe_id, cluster_id, trial_group_labels_1, trial_group_labels_2)

ctl         = RC2Analysis();

svm_table   = ctl.load_svm_table(probe_id);

idx         = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, trial_group_labels_1);
bsl_1       = svm_table.stationary_fr(idx);
rsp_1       = svm_table.motion_fr(idx);

idx         = svm_table.cluster_id == cluster_id & ismember(svm_table.trial_group_label, trial_group_labels_2);
bsl_2       = svm_table.stationary_fr(idx);
rsp_2       = svm_table.motion_fr(idx);

assert(length(bsl_1) == length(bsl_2));
