config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = false;
figs.set_figure_subdir('visual_flow', 'population_unity_plots');

probe_fnames            = experiment_details('visual_flow', 'protocols');

protocols               = VisualFlowExperiment.protocol_ids;

x_all                   = cell(length(protocols), 1);
y_all                   = cell(length(protocols), 1);
p_all                   = cell(length(protocols), 1);

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    vf                  = VisualFlowExperiment(data, config);
    clusters            = data.VISp_clusters;
    
    for prot_i = 1 : 3
        
        for cluster_i = 1 : length(clusters)
            
            if prot_i == 1
                
                x           = [vf.trial_stationary_fr(clusters(cluster_i).id, 3); ...
                               vf.trial_stationary_fr(clusters(cluster_i).id, 4)];
                y           = [vf.trial_motion_fr(clusters(cluster_i).id, 3); ...
                               vf.trial_motion_fr(clusters(cluster_i).id, 4)];
                
            elseif prot_i == 2
            
                x           = [vf.trial_stationary_fr(clusters(cluster_i).id, 5); ...
                               vf.trial_stationary_fr(clusters(cluster_i).id, 6)];
                y           = [vf.trial_motion_fr(clusters(cluster_i).id, 5); ...
                               vf.trial_motion_fr(clusters(cluster_i).id, 6)];
                
            elseif prot_i == 3
                
                x           = [vf.trial_motion_fr(clusters(cluster_i).id, 5); ...
                               vf.trial_motion_fr(clusters(cluster_i).id, 6)];
                y           = [vf.trial_motion_fr(clusters(cluster_i).id, 3); ...
                               vf.trial_motion_fr(clusters(cluster_i).id, 4)];
                
            end
            
            [x_all{prot_i}(end+1), ...
             y_all{prot_i}(end+1), ...
             p_all{prot_i}(end+1), ...
             is_increase{prot_i}(end+1)] = compare_groups_with_signrank(x, y);
        end
    end
end

%%
h_fig                   = figs.a4figure();
plot_array             = PlotArray(1, 3);

u                       = UnityPlotPopulation.empty();

for prot_i = 1 : 3
    
    pos         = plot_array.get_position(prot_i);
    h_ax        = axes('units', 'centimeters', 'innerposition', pos);
    
    u(end+1)   = UnityPlotPopulation(x_all{prot_i}, y_all{prot_i}, p_all{prot_i}, is_increase{prot_i}, h_ax);
    
    u(end).plot();
    
    if prot_i == 1
        u(end).xlabel('Stationary (Hz)');
        u(end).ylabel('Motion (Hz)');
        u(end).title('VT (MVT & MV)');
    elseif prot_i == 2
        u(end).xlabel('Stationary (Hz)');
        u(end).ylabel('Motion (Hz)');
        u(end).title('V (MVT & MV)');
    elseif prot_i == 3
        u(end).xlabel('V (MVT & MV)');
        u(end).ylabel('VT (MVT & MV)');
        u(end).title({'VT (MVT & MV)', 'vs. V (MVT & MV)'});
    end
    u(end).add_histogram(1);
end

m               = min([u(:).min]);
M               = max([u(:).max]);

for prot_i = 1 : length(u)
    u(prot_i).xlim([m, M])
end

FigureTitle(h_fig, 'population, replays grouped');
figs.save_fig('population_replays_grouped.pdf');