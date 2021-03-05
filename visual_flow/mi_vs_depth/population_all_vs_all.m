config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir('visual_flow', 'population_mi_vs_depth');

probe_fnames            = experiment_details('visual_flow', 'protocols');

protocols               = VisualFlowExperiment.protocol_ids;
protocol_labels         = VisualFlowExperiment.protocol_label;

x_all                   = cell(length(protocols));
y_all                   = cell(length(protocols));
p_all                   = cell(length(protocols));
relative_depth          = [];
layer                   = {};
anatomies               = Anatomy.empty();

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    vf                  = VisualFlowExperiment(data, config);
    clusters            = data.VISp_clusters;
    anatomies(probe_i)  = Anatomy(data);
    
    for cluster_i = 1 : length(clusters)
        
        [relative_depth(end+1), layer{end+1}] = ...
                anatomies(probe_i).VISp_layer_relative_depth(clusters(cluster_i).distance_from_probe_tip);
        assert(strcmp(layer{end}, clusters(cluster_i).region_str));
        
        for prot_y = 1 : length(protocols)-1
            for prot_x = prot_y+1 : length(protocols)
            
                x           = vf.trial_motion_fr(clusters(cluster_i).id, prot_x);
                y           = vf.trial_motion_fr(clusters(cluster_i).id, prot_y);
                
                x_all{prot_y, prot_x}(end+1) = nanmedian(x);
                y_all{prot_y, prot_x}(end+1) = nanmedian(y);
                p_all{prot_y, prot_x}(end+1) = signrank(x, y);
                
            end
        end
    end
end

% average the anatomy
avg_anatomy = AverageAnatomy(anatomies);
[boundaries, cluster_positions] = ...
    avg_anatomy.mi_vs_depth_positions(relative_depth, layer);

%%
h_fig                   = figs.a4figure();
array                   = PlotArray(6, 6);
mi                      = MIDepthPlot.empty();

for prot_y = 1 : length(protocols)-1
    for prot_x = prot_y+1 : length(protocols)
        
        sp_idx      = (prot_y-1)*length(protocols) + prot_x;
        pos         = array.get_position(sp_idx);
        h_ax        = axes('units', 'centimeters', 'position', pos);
        
        mi(end+1)   = MIDepthPlot(x_all{prot_y, prot_x}, ...
                            y_all{prot_y, prot_x}, ...
                            p_all{prot_y, prot_x}, ...
                            cluster_positions, boundaries, ...
                            avg_anatomy.VISp_layers, h_ax);
        
        if prot_y == 1 && prot_x == 2 
            mi(end).print_layers('left');
            mi(end).xlabel('MI');
        end
        
        str = [protocol_labels{prot_y}, '/', protocol_labels{prot_x}];
        mi(end).title(str);
    end
end


FigureTitle(h_fig, 'population, all vs. all');
figs.save_fig('population_all_vs_all.pdf');