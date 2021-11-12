function figure_s4cd(data, h_ax_main, h_ax_histogram)

ctl                 = RC2Analysis();
cluster_ids         = [125, 235;
                       231, 233;
                       186, 210];
probe_ids           = {'CAA-1112416_rec1_rec2_rec3', 'CA_176_1_rec1_rec2_rec3';
                       'CAA-1112417_rec1_rec2_rec3', 'CA_176_1_rec1_rec2_rec3';
                       'CA_176_1_rec1_rec2_rec3', 'CA_176_1_rec1_rec2_rec3'};
cols                = {[229, 37, 33]/255, [71, 131, 196]/255;
                       [243, 153, 123]/255, [0, 156, 220]/255;
                       [138, 16, 2]/255, [29, 113, 184]/255};

trial_group_labels = {'T_bank', 'T_RT', 'T_R'};

txt                 = {'Exc. not tuned', 'Sup. not tuned';
                       'Exc. high speeds', 'Sup. high speeds';
                       'Exc. low speeds', 'Sup. low speeds'};

xl                  = [-5, 50];
yl                  = {[0, 10], [0, 10];
                       [0, 10], [0, 10];
                       [0, 10], [0, 5]};

% make sure # axes matches # examples
assert(isequal(size(h_ax_main), size(h_ax_histogram)));
assert(isequal(size(h_ax_main), size(probe_ids)));
                   
for ii = 1 : size(probe_ids, 2)
    for jj = 1 : size(probe_ids, 1)
        
        this_data = get_data_for_probe_id(data, probe_ids{jj, ii});
        tuning = this_data.load_tuning_curves(cluster_ids(jj, ii), trial_group_labels);
        
        tuning_plot = TuningCurvePlot(h_ax_main{jj, ii});
        
        tuning_plot.main_col = cols{jj, ii};
        tuning_plot.dot_size = scatterball_size(1);
        tuning_plot.line_width = 0.25;
        tuning_plot.print_stats = false;
        
        tuning_plot.plot(tuning);
        
        text(h_ax_main{jj, ii}, xl(1), yl{jj, ii}(2), txt{jj, ii}, ...
                'fontsize', 6, ...
                'color', cols{jj, ii}, ...
                'horizontalalignment', 'left', ...
                'verticalalignment', 'middle');
        
        tuning_plot.xlim(xl);
        tuning_plot.ylim(yl{jj, ii});
        
        set(h_ax_main{jj, ii}, 'ytick', [0, yl{jj, ii}(2)/2, yl{jj, ii}(2)], ...
                               'yticklabel', {'0', '', num2str(yl{jj, ii}(2))});
        
        if jj ~= 3
            set(h_ax_main{jj, ii}, 'xtick', [0, 20, 40], 'xticklabel', '');
        else
            set(h_ax_main{jj, ii}, 'xticklabel', {'0', '', '40'});
        end
        
        if jj == 2 && ii == 1
            ylabel(h_ax_main{jj, ii}, 'FR (Hz)');
        end
        
        if jj == 3
            xlabel(h_ax_main{jj, ii}, 'Speed (cm/s)');
        end
        
        
        shuffle_hist = TuningCurveHistogram(h_ax_histogram{jj, ii});
        
        shuffle_hist.dot_size = scatterball_size(1.36);
        shuffle_hist.dot_col = cols{jj, ii};
        shuffle_hist.plot_labels = false;
        
        shuffle_hist.plot(tuning);
        
        set(h_ax_histogram{jj, ii}, 'fontsize', 6, 'ylim', [-0.5, 0.5], 'ytick', [-0.5, 0, 0.5], 'yticklabel', {'-0.5', '', '0.5'});
        
        if jj == 2
            ylabel(h_ax_histogram{jj, ii}, 'r');
        end
        
        if jj == 3
            xlabel(h_ax_histogram{jj, ii}, {'count', '(norm.)'});
        end
    end
end