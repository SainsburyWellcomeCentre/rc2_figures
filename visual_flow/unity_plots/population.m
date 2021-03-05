config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir('visual_flow', 'population_unity_plots');

probe_fnames            = experiment_details('visual_flow', 'protocols');

protocols               = VisualFlowExperiment.protocol_ids;
protocol_labels         = VisualFlowExperiment.protocol_label;

x_all                   = cell(length(protocols), 1);
y_all                   = cell(length(protocols), 1);
p_all                   = cell(length(protocols), 1);

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    vf                  = VisualFlowExperiment(data, config);
    clusters            = data.VISp_clusters;
    
    for prot_i = 1 : length(protocols)
        
        for cluster_i = 1 : length(clusters)
            
            x           = vf.trial_stationary_fr(clusters(cluster_i).id, prot_i);
            y           = vf.trial_motion_fr(clusters(cluster_i).id, prot_i);
            
            x_all{prot_i}(end+1) = nanmedian(x);
            y_all{prot_i}(end+1) = nanmedian(y);
            p_all{prot_i}(end+1) = signrank(x, y);
            
            fprintf('%s, nnan x: %i\n', probe_fnames{probe_i}, sum(isnan(x)));
            fprintf('%s, nnan y: %i\n', probe_fnames{probe_i}, sum(isnan(y)));
            
        end
    end
end

%%
h_fig                   = figs.a4figure();
plot_array             = PlotArray(3, 2);

u                       = UnityPlotPopulation.empty();

for prot_i = 1 : length(protocols)
    
    pos         = plot_array.get_position(prot_i);
    h_ax        = axes('units', 'centimeters', 'position', pos);
    
    u(end+1)   = UnityPlotPopulation(x_all{prot_i}, ...
        y_all{prot_i}, ...
        p_all{prot_i}, ...
        h_ax);
    
    u(end).xlabel('Stationary (Hz)');
    u(end).ylabel('Motion (Hz)');
    
    u(end).title(protocol_labels{prot_i});
    u(end).add_histogram(1);
end

m               = min([u(:).min]);
M               = max([u(:).max]);

for prot_i = 1 : length(u)
    u(prot_i).xlim([m, M]);
end

FigureTitle(h_fig, 'population, motion vs. stationary');
figs.save_fig('population_motion_vs_stationary.pdf');