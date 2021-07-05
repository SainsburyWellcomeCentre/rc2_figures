function figure_1_main(data)

h_fig = a4figure();

label_positions = {'b', [75, 297 - 50, 0, 0]; 
                   'c', [75, 297 - 85, 0, 0];
                   'd', []};
               
axes_positions = [];

setup_labels(h_fig, label_positions);
h_ax = setup_axes(h_fig, axes_positions);

figure_1a(data, h_ax(1))
figure_1b(data, h_ax(2))
figure_1c(data, h_ax(3))
figure_1d(data, h_ax(4))
figure_1e(data, h_ax(5))
figure_1f(data, h_ax(6))
figure_1g(data, h_ax(7))
