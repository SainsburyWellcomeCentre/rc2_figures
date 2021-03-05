experiment              = 'darkness';

config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir(experiment, 'tuning', 'all_conditions');

probe_fnames            = experiment_details(experiment, 'protocols');

plot_array             = PlotArray(3, 2);

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    clusters            = data.selected_clusters;
    
    if strcmp(experiment, 'visual_flow')
        exp_obj         = VisualFlowExperiment(data, config);
    elseif strcmp(experiment, 'darkness')
        exp_obj         = DarknessExperiment(data, config);
    end
    
    for cluster_i = 1 : length(clusters)
        %%
        h_fig           = figs.a4figure();
        
        u               = TuningCurvePlot.empty();
        
        if clusters(cluster_i).id == 415
            disp('');
        end
        
        for prot_i = 1 : length(exp_obj.protocol_ids)
            
            pos         = plot_array.get_position(prot_i);
            h_ax        = axes('units', 'centimeters', 'position', pos);
            
            [fr, sd, n, x, shuff, stat_fr, stat_sd, stat_n] = ...
                exp_obj.tuning_curve(clusters(cluster_i).id, prot_i);
            
            stat_rate = exp_obj.trial_stationary_fr(clusters(cluster_i).id, prot_i);
            mot_rate = exp_obj.trial_motion_fr(clusters(cluster_i).id, prot_i);
            
            p_signrank = signrank(stat_rate, mot_rate);
            
            u(prot_i)   = TuningCurvePlot(fr, sd, n, x, shuff, stat_fr, stat_sd, stat_n, p_signrank, h_ax);
            
            if prot_i == length(exp_obj.protocol_ids)
                u(prot_i).xlabel('Speed (cm/s)');
                u(prot_i).ylabel('Firing rate (Hz)');
            end
            
            u(prot_i).title(exp_obj.protocol_label{prot_i});
        end
        
        mx               = min([u(:).xmin]);
        Mx               = max([u(:).xmax]);
        my               = min([u(:).ymin]);
        My               = max([u(:).ymax]);
        
        for prot_i = 1 : length(u)
            u(prot_i).xlim([mx, Mx]);
            u(prot_i).ylim([my, My]);
        end
        
        FigureTitle(h_fig, sprintf('%s, Cluster %i, %s', ...
                probe_fnames{probe_i}, ...
                clusters(cluster_i).id, ...
                clusters(cluster_i).region_str));
        
        figs.save_fig_to_join();
        
    end
    
    figs.join_figs(sprintf('%s.pdf', probe_fnames{probe_i}));
    figs.clear_figs();
    
end
