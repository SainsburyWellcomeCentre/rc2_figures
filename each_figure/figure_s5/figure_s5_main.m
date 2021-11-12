function figure_s5_main()

load('running_around_mismatch_matched_trials', 'lib_git', ...
                                               'common_t', ...
                                               'decrease_traces', ...
                                               'no_change_traces', ...
                                               'matched_decrease_traces', ...
                                               'decrease_traces_fr', ...
                                               'no_change_traces_fr', ...
                                               'matched_decrease_traces_fr');


% make sure this file was generated using a specific commit of the
% rc2_analysis library
original_lib_git_sha1 = '8bef97444b17a948acbcbc6b6160e4223485f227'; %'cdf7873a79d87b56f1651721d2aace3e3b67a648';
assert(strcmp(lib_git.sha1, original_lib_git_sha1));

a4figure();

subplot(2, 3, 1); hold on
plot_running_traces(common_t, [decrease_traces{:}]);

subplot(2, 3, 2); hold on
plot_running_traces(common_t, [no_change_traces{:}]);

subplot(2, 3, 3); hold on
plot_running_traces(common_t, [matched_decrease_traces{:}]);

subplot(2, 3, 4); hold on
plot_fr_traces(common_t, [decrease_traces_fr{:}]);

subplot(2, 3, 5); hold on
plot_fr_traces(common_t, [no_change_traces_fr{:}]);

subplot(2, 3, 6); hold on
plot_fr_traces(common_t, [matched_decrease_traces_fr{:}]);



function plot_running_traces(common_t, traces)

yl = [0, 60];
plot_mm_window(gca, yl);
plot(common_t, traces, 'color', [0.5, 0.5, 0.5], 'linewidth', 0.5);
plot(common_t, mean(traces, 2), 'color', 'k', 'linewidth', 1);
set(gca, 'xlim', common_t([1, end]), 'ylim', yl);


function plot_fr_traces(common_t, traces)

yl = [0, 15];
plot_mm_window(gca, yl);
m = mean(traces, 2);
sem = std(traces, [], 2) / sqrt(size(traces, 2));
upper = m(:)' + sem(:)';
lower = m(:)' - sem(:)';
patch(gca, 'xdata', [common_t, common_t(end:-1:1)], ...
           'ydata', [lower, upper(end:-1:1)], ...
           'facecolor', 'r', ...
           'edgecolor', 'none', ...
           'facealpha', 0.5);
plot(gca, common_t, m, 'color', 'r', 'linewidth', 1);
set(gca, 'xlim', common_t([1, end]), 'ylim', yl);


function plot_mm_window(h_ax, yl)
mm_time = 0.25;
patch(h_ax, 'xdata', [0, mm_time, mm_time, 0], ...
            'ydata', yl([1, 1, 2, 2]), ...
            'facecolor', [0.6, 0.6, 0.6], ...
            'edgecolor', 'none');
