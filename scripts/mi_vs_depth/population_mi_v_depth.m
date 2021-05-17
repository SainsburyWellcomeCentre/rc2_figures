function population_mi_v_depth(experiment, spiking_class)

% experiment              = 'darkness';
% spiking_class            = 'RS';   % 'any', 'RS', 'FS'


%%
config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir(experiment, 'population_mi_vs_depth', spiking_class);

probe_fnames            = experiment_details(experiment, 'protocols');

if strcmp(experiment, 'visual_flow')
    protocols           = VisualFlowExperiment.protocol_ids;
    protocol_labels     = VisualFlowExperiment.protocol_label;
elseif strcmp(experiment, 'darkness')
    protocols           = DarknessExperiment.protocol_ids;
    protocol_labels     = DarknessExperiment.protocol_label;
end


x_all                   = cell(length(protocols), 1);
y_all                   = cell(length(protocols), 1);
p_all                   = cell(length(protocols), 1);
relative_depth          = [];
layer                   = {};
anatomies               = Anatomy.empty();

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    clusters            = data.VISp_clusters([], spiking_class);
    anatomies(probe_i)  = Anatomy(data);
    
    if strcmp(experiment, 'visual_flow')
        exp_obj         = VisualFlowExperiment(data, config);
    elseif strcmp(experiment, 'darkness')
        exp_obj         = DarknessExperiment(data, config);
    end
    
    for cluster_i = 1 : length(clusters)
        
        [relative_depth(end+1), layer{end+1}] = ...
                anatomies(probe_i).VISp_layer_relative_depth(clusters(cluster_i).distance_from_probe_tip);
        assert(strcmp(layer{end}, clusters(cluster_i).region_str));
        
        for prot_i = 1 : length(protocols)
            
            x           = exp_obj.trial_stationary_fr(clusters(cluster_i).id, protocols(prot_i));
            y           = exp_obj.trial_motion_fr(clusters(cluster_i).id, protocols(prot_i));
            
            x_all{prot_i}(end+1) = nanmedian(x);
            y_all{prot_i}(end+1) = nanmedian(y);
            p_all{prot_i}(end+1) = signrank(x, y);

            fprintf('%s, nnan x: %i\n', probe_fnames{probe_i}, sum(isnan(x)));
            fprintf('%s, nnan y: %i\n', probe_fnames{probe_i}, sum(isnan(y)));
        end
    end
end

% average the anatomy
avg_anatomy = AverageAnatomy(anatomies);
[boundaries, cluster_positions] = ...
    avg_anatomy.mi_vs_depth_positions(relative_depth, layer);


%%
h_fig                   = figs.a4figure();
array                   = PlotArray(3, 2);
mi                      = MIDepthPlot.empty();

for prot_i = 1 : length(protocols)
    
    pos         = array.get_position(prot_i);
    h_ax        = axes('units', 'centimeters', 'position', pos);
    
    mi(prot_i)   = MIDepthPlot(x_all{prot_i}, y_all{prot_i}, p_all{prot_i}, ...
                            cluster_positions, boundaries, ...
                            avg_anatomy.VISp_layers, h_ax);
    
    if prot_i == length(protocols)
        mi(prot_i).print_layers();
        mi(prot_i).xlabel('MI');
    end
    
    mi(prot_i).title(protocol_labels{prot_i});
end

FigureTitle(h_fig, 'population, motion/stationary');
figs.save_fig('population_motion_vs_stationary.pdf');