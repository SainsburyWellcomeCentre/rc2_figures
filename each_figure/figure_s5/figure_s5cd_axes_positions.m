function [h_ax_main, h_ax_histogram] = figure_s5cd_axes_positions(h_fig)
% creates the axes for figure S5C & D

main_axis_size_xy       = 18.5;
histogram_axis_size_x   = 5.5;
histogram_axis_size_y   = 15;
main_x_offset           = 50;
main_y_offset           = 297 - 81;
histogram_from_main_x   = 24;
main_x_spacing          = 40;
main_y_spacing          = 22;

n_x                     = 2;
n_y                     = 3;

main_axis_pos           = cell(n_y, n_x);
histogram_axis_pos      = cell(n_y, n_x);

for ii = 1 : n_x
    for jj = 1 : n_y
        
        main_axis_pos{jj, ii} = [main_x_offset + (ii - 1) * main_x_spacing,
                                 main_y_offset - (jj - 1) * main_y_spacing,
                                 main_axis_size_xy,
                                 main_axis_size_xy];
                             
        % specifiy histogram axis relative to main axis
        histogram_axis_pos{jj, ii} = [main_axis_pos{jj, ii}(1) + histogram_from_main_x,
                                      main_axis_pos{jj, ii}(2) + (main_axis_size_xy - histogram_axis_size_y),
                                      histogram_axis_size_x,
                                      histogram_axis_size_y];
                             
    end
end

h_ax_main           = cell(n_y, n_x);
h_ax_histogram      = cell(n_y, n_x);

% create the axes
for ii = 1 : n_x
    for jj = 1 : n_y
        
        h_ax_main{jj, ii} = a4axis(h_fig, main_axis_pos{jj, ii}); hold on;
        h_ax_histogram{jj, ii} = a4axis(h_fig, histogram_axis_pos{jj, ii}); hold on;
    end
end
