experiment              = 'darkness';

config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir(experiment, 'population_unity_plots');

probe_fnames            = experiment_details(experiment, 'protocols');

if strcmp(experiment, 'visual_flow')
    protocols           = VisualFlowExperiment.protocol_ids;
    protocol_labels     = VisualFlowExperiment.protocol_label;
elseif strcmp(experiment, 'darkness')
    protocols           = DarknessExperiment.protocol_ids(1:2);
    protocol_labels     = DarknessExperiment.protocol_label(1:2);
end

x_all                   = cell(length(protocols));
y_all                   = cell(length(protocols));
p_all                   = cell(length(protocols));

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    clusters            = data.VISp_clusters;
    
    if strcmp(experiment, 'visual_flow')
        exp_obj         = VisualFlowExperiment(data, config);
    elseif strcmp(experiment, 'darkness')
        exp_obj         = DarknessExperiment(data, config);
    end
    
    for prot_y = 1 : length(protocols)-1
        for prot_x = prot_y+1 : length(protocols)
            
            for cluster_i = 1 : length(clusters)
                
                x           = exp_obj.trial_motion_fr(clusters(cluster_i).id, protocols(prot_x));
                y           = exp_obj.trial_motion_fr(clusters(cluster_i).id, protocols(prot_y));
                
                x_all{prot_y, prot_x}(end+1) = nanmedian(x);
                y_all{prot_y, prot_x}(end+1) = nanmedian(y);
                p_all{prot_y, prot_x}(end+1) = signrank(x, y);
                
            end
        end
    end
end


%%
h_fig                   = figs.a4figure();
plot_array             = PlotArray(6, 6);
u                       = UnityPlotPopulation.empty();

for prot_y = 1 : length(protocols)-1
    for prot_x = prot_y+1 : length(protocols)
        
        sp_idx      = (prot_y-1)*length(protocols) + prot_x;
        pos         = plot_array.get_position(sp_idx);
        h_ax        = axes('units', 'centimeters', 'position', pos);
        
        u(end+1)   = UnityPlotPopulation(x_all{prot_y, prot_x}, ...
            y_all{prot_y, prot_x}, ...
            p_all{prot_y, prot_x}, ...
            h_ax);
        
        u(end).plot();
        
        u(end).xlabel(protocol_labels{prot_x});
        u(end).ylabel(protocol_labels{prot_y});
        u(end).add_histogram(1);
    end
end

m               = min([u(:).min]);
M               = max([u(:).max]);

for prot_i = 1 : length(u)
    u(prot_i).xlim([m, M])
end

FigureTitle(h_fig, 'population, all vs. all');
figs.save_fig('population_all_vs_all.pdf');