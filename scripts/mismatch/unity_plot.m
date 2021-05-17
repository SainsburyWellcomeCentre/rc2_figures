config                  = RC2AnalysisConfig();

figs                    = RC2Figures(config);
figs.save_on            = false;
figs.set_figure_subdir('mismatch_nov20', 'population_unity_plots');

probe_fnames            = experiment_details('mismatch_nov20', 'protocol');

protocols               = MismatchExperiment.protocol_ids;
protocol_labels         = MismatchExperiment.protocol_label;

x_all                   = cell(length(protocols), 1);
y_all                   = cell(length(protocols), 1);
p_all                   = cell(length(protocols), 1);
pt_all                  = cell(length(protocols), 1);
pk_all                  = cell(length(protocols), 1);


for probe_i = 1 : length(probe_fnames)
    probe_i
    data                = config.load_formatted_data(probe_fnames{probe_i});
    mm                  = MismatchExperiment(data, config);
    clusters            = data.VISp_clusters;
    
    for cluster_i = 1 : length(clusters)
        
        for prot_i = 1 : length(protocols)
            
            [baseline, response, response_ctl] = mm.windowed_mm_responses(clusters(cluster_i), prot_i);
            
            x_all{prot_i}(end+1) = nanmean(baseline(:));
            y_all{prot_i}(end+1) = nanmean(response(:));
            
            p = mm_do_ANOVA(baseline', response');
            p_ctl = mm_do_ANOVA(baseline', response_ctl');
            [~, pt] = ttest2(sum(baseline', 2), sum(response', 2));
            
            if p_ctl(1) < 0.05
                p_all{prot_i}(end+1) = nan;
                pt_all{prot_i}(end+1) = nan;
            else
                p_all{prot_i}(end+1) = p(1);
                pt_all{prot_i}(end+1) = pt;
            end
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
        pk_all{prot_i}, ...
        h_ax);
    
    if ismember(prot_i, [1, 3])
        u(end).marker_style = 'v';
    end
    
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