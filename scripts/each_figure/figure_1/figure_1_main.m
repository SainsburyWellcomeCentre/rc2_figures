function fig = figure_1_main(data)

fig.h_fig = a4figure();

label_positions = {'a', [37, 297 - 22, 0, 0];
                   'b', [37, 297 - 67, 0, 0]; 
                   'c', [37, 297 - 101, 0, 0];
                   'd', [83, 297 - 22, 0, 0];
                   'e', [83, 297 - 49, 0, 0];
                   'f', [83, 297 - 67, 0, 0];
                   'g', [83, 297 - 89, 0, 0];
                   'h', [83, 297 - 126, 0, 0];
                   'i', [130, 297 - 22, 0, 0];
                   'j', [130, 297 - 67, 0, 0];
                   'k', [130, 297 - 89, 0, 0];
                   'l', [130, 297 - 126, 0, 0]};

axes_positions = {'a', [44, 297 - 57, 32, 26];
                  'b_upper', [48, 297 - 78, 28.5, 6];
                  'b_lower', [48, 297 - 93, 28.5, 8];
                  'c_upper', [48, 297 - 143, 28.5, 38];
                  'c_lower', [48, 297 - 162, 28.5, 15];
                  'd', [93, 297 - 38, 32, 12];
                  'e', [93, 297 - 60, 32, 15];
                  'f', [95, 297 - 79.5, 29, 11];
                  'g', [95, 297 - 116.5, 29, 29];
                  'h', [97.5, 297 - 155, 24, 29];
                  'i', [136, 297 - 57, 32, 26];
                  'j', [138, 297 - 79.5, 29, 11];
                  'k', [138, 297 - 116.5, 29, 29];
                  'l', [140.5, 297 - 155, 24, 29]};

fig.h_labels = setup_labels(fig.h_fig, label_positions);
fig.h_ax = setup_axes(fig.h_fig, axes_positions);

% tic; figure_1a(data, fig.h_ax('a')); fprintf('1A took: %.3f\n', toc);
% tic; figure_1b(data, fig.h_ax('b_upper'), fig.h_ax('b_lower')); fprintf('1B took: %.3f\n', toc);
% % tic; figure_1c(data, fig.h_ax('c_upper'), fig.h_ax('c_lower')); fprintf('1C took: %.3f\n', toc);
% tic; figure_1d(data, fig.h_ax('d')); fprintf('1D took: %.3f\n', toc);
% tic; figure_1e(data, fig.h_ax('e')); fprintf('1E took: %.3f\n', toc);
% tic; figure_1f(data, fig.h_ax('f')); fprintf('1F took: %.3f\n', toc);
tic; figure_1g(data, fig.h_ax('g')); fprintf('1G took: %.3f\n', toc);
% tic; figure_1h(data, fig.h_ax('h')); fprintf('1H took: %.3f\n', toc);
% tic; figure_1i(data, fig.h_ax('i')); fprintf('1I took: %.3f\n', toc);
% tic; figure_1j(data, fig.h_ax('j')); fprintf('1J took: %.3f\n', toc);
% tic; figure_1k(data, fig.h_ax('k')); fprintf('1K took: %.3f\n', toc);
% tic; figure_1l(data, fig.h_ax('l')); fprintf('1L took: %.3f\n', toc);
