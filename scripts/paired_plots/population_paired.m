function population_paired(experiment, spiking_class)
%%

config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir(experiment, 'population_unity_plots', spiking_class);

csvs                    = CSVManager(config);
csvs.save_on            = false;
csvs.set_csv_fulldir(figs.curr_dir);

if strcmp(experiment, 'mismatch_nov20+visual_flow')
    probe_fnames            = experiment_details('visual_flow', 'protocols');
    probe_fnames            = [probe_fnames, experiment_details('mismatch_nov20', 'protocols')];
else
    probe_fnames            = experiment_details(experiment, 'protocols');
end

if strcmp(experiment, 'visual_flow')
    protocols           = VisualFlowExperiment.protocol_ids;
    protocol_labels     = VisualFlowExperiment.protocol_label;
elseif strcmp(experiment, 'darkness')
    protocols           = DarknessExperiment.protocol_ids;
    protocol_labels     = DarknessExperiment.protocol_label;
elseif strcmp(experiment, 'passive')
    protocols           = PassiveExperiment.protocol_ids;
    protocol_labels     = PassiveExperiment.protocol_label;
elseif strcmp(experiment, 'head_tilt')
    protocols           = HeadTiltExperiment.protocol_ids;
    protocol_labels     = HeadTiltExperiment.protocol_label;
elseif strcmp(experiment, 'mismatch_nov20')
    protocols           = MismatchExperiment.protocol_ids;
    protocol_labels     = MismatchExperiment.protocol_label;
elseif strcmp(experiment, 'mismatch_nov20+visual_flow')
     protocol_labels     = {'MVT', 'MV'};
end

cluster_id              = cell(length(protocol_labels), 1);
probe_name              = cell(length(protocol_labels), 1);
protocol_id             = cell(length(protocol_labels), 1);

x_all                   = cell(length(protocol_labels), 1);
y_all                   = cell(length(protocol_labels), 1);
is_increase             = cell(length(protocol_labels), 1);
p_all                   = cell(length(protocol_labels), 1);


for probe_i = 1 : length(probe_fnames)
    
    data                = load_formatted_data(probe_fnames{probe_i}, config);
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
    elseif strcmp(experiment, 'head_tilt')
        exp_obj         = HeadTiltExperiment(data, config);
    elseif strcmp(experiment, 'mismatch_nov20')
        exp_obj         = MismatchExperiment(data, config);
    elseif strcmp(experiment, 'mismatch_nov20+visual_flow')
        exp_obj         = get_experiment(data, config);
        if strcmp(data.experiment_type, 'visual_flow')
            protocols = [1, 2];
        else
            protocols = [2, 4];
        end
    end
    
    for prot_i = 1 : length(protocols)
        
        for cluster_i = 1 : length(clusters)
            
            x           = exp_obj.trial_stationary_fr(clusters(cluster_i).id, protocols(prot_i));
            y           = exp_obj.trial_motion_fr(clusters(cluster_i).id, protocols(prot_i));
            
            % store the cluster
            probe_name{prot_i}{end+1, 1} = probe_fnames{probe_i};
            protocol_id{prot_i}(end+1, 1) = protocols(prot_i);
            cluster_id{prot_i}(end+1, 1) = clusters(cluster_i).id;
            
            [x_all{prot_i}(end+1, 1), ...
             y_all{prot_i}(end+1, 1), ...
             p_all{prot_i}(end+1, 1), ...
             is_increase{prot_i}(end+1, 1)] = compare_groups_with_signrank(x, y);
            
        end
    end
end


csvs.create_table(  'probe_name',       cat(1, probe_name{:}), ...
                    'cluster_id',       cat(1, cluster_id{:}), ...
                    'protocol_id',      cat(1, protocol_id{:}), ...
                    'stationary_fr',    cat(1, x_all{:}), ...
                    'motion_fr',        cat(1, y_all{:}), ...
                    'p_val_signrank',   cat(1, p_all{:}), ...
                    'is_increase',      cat(1, is_increase{:}))
csvs.save('population_motion_vs_stationary');


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