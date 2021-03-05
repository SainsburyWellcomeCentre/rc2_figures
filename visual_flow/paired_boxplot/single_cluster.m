% general config info
config                  = RC2AnalysisConfig();

% where to save figure
figs                    = RC2Figures(config);
figs.save_on            = false;
figs.set_figure_subdir('visual_flow', 'single_cluster_box_plots', 'all_conditions');

% get details of the experiment
probe_fnames            = experiment_details('visual_flow', 'protocols');

plot_array             = PlotArray(3, 2);

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    vf                  = VisualFlowExperiment(data, config);
    clusters            = data.selected_clusters;
    
    %%
    for cluster_i = 1 : length(clusters)
        
        h_fig           = figs.a4figure();
        u               = PairedBoxPlot.empty();
        
        for prot_i = 1 : length(vf.protocol_ids)
            
            pos         = plot_array.get_position(prot_i);
            h_ax        = axes('units', 'centimeters', 'position', pos);
            
            x           = vf.trial_stationary_fr(clusters(cluster_i).id, prot_i);
            y           = vf.trial_motion_fr(clusters(cluster_i).id, prot_i);
            
            u(prot_i)   = PairedBoxPlot(x, y, h_ax);
            
            u(prot_i).xticklabel('Stationary', 'Motion');
            u(prot_i).ylabel('(Hz)');
            u(prot_i).title(vf.protocol_label{prot_i});
        end
        
        m               = min([u(:).min]);
        M               = max([u(:).max]);
        
        for prot_i = 1 : length(u)
            u(prot_i).ylim([m, M]);
        end
        
        FigureTitle(h_fig, sprintf('%s, Cluster %i, %s', ...
                probe_fnames{probe_i}, ...
                clusters(cluster_i).id, ...
                clusters(cluster_i).region_str));
            
        figs.save_fig_to_join();
        
    end
    %%
    figs.join_figs(sprintf('%s.pdf', probe_fnames{probe_i}));
    figs.clear_figs();
    
end
