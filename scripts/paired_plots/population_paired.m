function population_paired(experiment, spiking_class)

% experiment              = 'darkness';
% spiking_class            = 'any';   % 'any', 'RS', 'FS'


%%
config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir(experiment, 'population_unity_plots', spiking_class);

probe_fnames            = experiment_details(experiment, 'protocols');

if strcmp(experiment, 'visual_flow')
    protocols           = VisualFlowExperiment.protocol_ids;
    protocol_labels     = VisualFlowExperiment.protocol_label;
elseif strcmp(experiment, 'darkness')
    protocols           = DarknessExperiment.protocol_ids;
    protocol_labels     = DarknessExperiment.protocol_label;
elseif strcmp(experiment, 'passive')
    protocols           = PassiveExperiment.protocol_ids;
    protocol_labels     = PassiveExperiment.protocol_label;
end

x_all                   = cell(length(protocols), 1);
y_all                   = cell(length(protocols), 1);
is_increase             = cell(length(protocols), 1);
p_all                   = cell(length(protocols), 1);

for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    clusters            = data.VISp_clusters([], spiking_class);
    
    if isempty(clusters)
        continue
    end
    
    if strcmp(experiment, 'visual_flow')
        exp_obj         = VisualFlowExperiment(data, config);
    elseif strcmp(experiment, 'darkness')
        exp_obj         = DarknessExperiment(data, config);
    elseif strcmp(experiment, 'passive')
        exp_obj         = PassiveExperiment(data, config);
    end
    
    for prot_i = 1 : length(protocols)
        
        for cluster_i = 1 : length(clusters)
            
            x           = exp_obj.trial_stationary_fr(clusters(cluster_i).id, protocols(prot_i));
            y           = exp_obj.trial_motion_fr(clusters(cluster_i).id, protocols(prot_i));
            
            [x_all{prot_i}(end+1), ...
             y_all{prot_i}(end+1), ...
             p_all{prot_i}(end+1), ...
             is_increase{prot_i}(end+1)] = compare_groups_with_signrank(x, y);
            
        end
    end
end


%%
h_fig                   = figs.a4figure();
plot_array              = PlotArray(3, 2);
u                       = UnityPlotPopulation.empty();

for prot_i = 1 : length(protocols)
    
    pos         = plot_array.get_position(prot_i);
    h_ax        = axes('units', 'centimeters', 'position', pos);
    
    u(end+1)   = UnityPlotPopulation(x_all{prot_i}, ...
        y_all{prot_i}, ...
        p_all{prot_i}, ...
        is_increase{prot_i}, ...
        h_ax);
    
    u(end).plot();
    
    u(end).xlabel('Stationary (Hz)');
    u(end).ylabel('Motion (Hz)');
    
    u(end).title(protocol_labels{prot_i});
    u(end).add_histogram(1);
end

m               = min([u(:).min]);
M               = max([u(:).max]);

for prot_i = 1 : length(u)
    u(prot_i).xlim([m, M])
end

FigureTitle(h_fig, 'population, motion vs. stationary');
figs.save_fig('population_motion_vs_stationary.pdf');