function fig = figure_s5_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [42, 297 - 22, 0, 0];
                   'b', [83, 297 - 22, 0, 0]; 
                   'c', [42, 297 - 59, 0, 0];
                   'd', [83, 297 - 59, 0, 0];
                   'e', [42, 297 - 136, 0, 0];
                   'f', [83, 297 - 136, 0, 0];
                   'g', [125, 297 - 22, 0, 0];
                   'h', [125, 297 - 59, 0, 0];
                   'i', [125, 297 - 107, 0, 0];
                   'j', [125, 297 - 136, 0, 0]};

axes_positions = {'a', [50, 297 - 47, 27.5, 14];
                  'b', [90, 297 - 51, 27, 27];
                  'e', [50, 297 - 165, 28.5, 28.5];
                  'f', [90, 297 - 165, 28.5, 28.5];
                  'g', [132, 297 - 49, 32, 19];
                  'h', [132, 297 - 91.6, 32, 24];
                  'i', [134, 297 - 125.5, 28.5, 22];
                  'j', [134, 297 - 165, 28.5, 28.5]};

fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

% create special axes for c
[h_ax_s5cd_main, h_ax_s5cd_histogram] = figure_s5cd_axes_positions(fig.h_fig);


tic; figure_s5a(data, fig.h_ax('a')); fprintf('s5A took: %.3f\n', toc);
tic; figure_s5b(data, fig.h_ax('b')); fprintf('s5B took: %.3f\n', toc);
tic; figure_s5cd(data, h_ax_s5cd_main, h_ax_s5cd_histogram); fprintf('s5C & D took: %.3f\n', toc);
tic; figure_s5e(data, fig.h_ax('e')); fprintf('s5E took: %.3f\n', toc);
tic; figure_s5f(data, fig.h_ax('f')); fprintf('s5F took: %.3f\n', toc);
tic; figure_s5g(data, fig.h_ax('g')); fprintf('s5G took: %.3f\n', toc);
tic; figure_s5h(data, fig.h_ax('h')); fprintf('s5H took: %.3f\n', toc);
tic; figure_s5i(fig.h_ax('i')); fprintf('s5I took: %.3f\n', toc);
tic; figure_s5j(data, fig.h_ax('j')); fprintf('s5J took: %.3f\n', toc);
