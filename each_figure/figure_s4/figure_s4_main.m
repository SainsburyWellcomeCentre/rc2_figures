function figure_s4_main()

fig.h_fig = a4figure();

label_positions = {'a', [56, 297 - 19, 0, 0];
                   'b', [123, 297 - 19, 0, 0]};

axes_positions = {'a_upper_left', [68, 297 - 50, 23.5, 23.5];
                  'a_lower_left', [68, 297 - 81, 23.5, 23.5];
                  'a_upper_right', [99, 297 - 50, 23.5, 23.5];
                  'a_lower_right', [99, 297 - 81, 23.5, 23.5];
                  'b_upper', [130, 297 - 50, 23.5, 23.5];
                  'b_lower', [130, 297 - 81, 23.5, 23.5]};

fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

bsl_limits = [-0.4, 0];


%% Load
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


%%
set(fig.h_fig, 'currentaxes', fig.h_ax('a_upper_left')); hold on;
these_traces = [decrease_traces{:}];
plot_running_traces(common_t(1:100:end), these_traces(1:100:end, :), 'Negative change trials');
ylabel('speed (cm/s)', 'fontsize', 8);

set(fig.h_fig, 'currentaxes', fig.h_ax('a_upper_right')); hold on;
these_traces = [no_change_traces{:}];
plot_running_traces(common_t(1:100:end), these_traces(1:100:end, :), 'No change trials');

set(fig.h_fig, 'currentaxes', fig.h_ax('b_upper')); hold on;
these_traces = [matched_decrease_traces{:}];
plot_running_traces(common_t(1:100:end), these_traces(1:100:end, :), 'Matched trials');

set(fig.h_fig, 'currentaxes', fig.h_ax('a_lower_left')); hold on;
plot_fr_traces(common_t, [decrease_traces_fr{:}], bsl_limits);
ylabel('\Delta FR (Hz)', 'fontsize', 8);

set(fig.h_fig, 'currentaxes', fig.h_ax('a_lower_right')); hold on;
plot_fr_traces(common_t, [no_change_traces_fr{:}], bsl_limits);
xlabel('time from gain up (s)', 'fontsize', 8);

set(fig.h_fig, 'currentaxes', fig.h_ax('b_lower')); hold on;
plot_fr_traces(common_t, [matched_decrease_traces_fr{:}], bsl_limits);



function plot_running_traces(common_t, traces, title_str)

% y-limits
ylimits = [0, 60];
plot_mm_window(gca, ylimits);

% mean and std of running traces
m = mean(traces, 2);
sem = std(traces, [], 2) / sqrt(size(traces, 2));

upper = m(:)' + sem(:)';
lower = m(:)' - sem(:)';

% plot underlying patch
patch(gca, 'xdata', [common_t, common_t(end:-1:1)], ...
           'ydata', [lower, upper(end:-1:1)], ...
           'facecolor', 'k', ...
           'edgecolor', 'none', ...
           'facealpha', 0.6);

% plot(common_t, traces, 'color', [0.6, 0.6, 0.6], 'linewidth', 0.5);

% overlay mean
plot(common_t, mean(traces, 2), 'color', 'k', 'linewidth', 2);

set(gca, 'xlim', common_t([1, end]), ...
         'ylim', ylimits, ...
         'xtick', 0:20:60, ...
         'fontsize', 8);

text(gca, 0, ylimits(2), {title_str, sprintf('n = %i', size(traces, 2))}, ...
        'fontsize', 8, ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'bottom');



function plot_fr_traces(common_t, traces, bsl_limits)

yl = [-5, 10];

% baseline subtrace traces
bsl_idx = common_t >= bsl_limits(1) & common_t < bsl_limits(2);
traces = bsxfun(@minus, traces, mean(traces(bsl_idx, :), 1));

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
line(h_ax, [0, 0], yl, 'color', 'k', 'linewidth', 0.5);
% mm_time = 0.25;
% patch(h_ax, 'xdata', [0, mm_time, mm_time, 0], ...
%             'ydata', yl([1, 1, 2, 2]), ...
%             'facecolor', [0.6, 0.6, 0.6], ...
%             'edgecolor', 'none');
