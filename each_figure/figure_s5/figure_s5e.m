function figure_s5e(data, h_ax)

ctl                 = RC2Analysis();
probe_ids           = ctl.get_probe_ids('darkness', 'mismatch_darkness_oct21');

trial_group_labels = cell(1, length(probe_ids));
for ii = 1 : length(probe_ids)
    if contains(probe_ids{ii}, 'CA_176')
        trial_group_labels{ii} = {'T_bank', 'T_RT', 'T_R'};
    elseif contains(probe_ids{ii}, 'CAA-11124')
        trial_group_labels{ii} = {'T_RT', 'T_R'};
    elseif strcmp(ctl.get_experiment_group_from_probe_id(probe_ids{ii}), 'mismatch_darkness_oct21')
        trial_group_labels{ii} = {'T'};
    end
end

cols                = {[229, 37, 33]/255;
                       [243, 153, 123]/255;
                       [138, 16, 2]/255};

%% Data

c                   = 0;
p_val               = [];
slope               = [];
classification      = [];

for ii = 1 : length(probe_ids)
    
    if isempty(data)
        this_data   = ctl.load_formatted_data(probe_ids{ii});
    else
        this_data   = get_data_for_probe_id(data, probe_ids{ii});
    end
    
    clusters    = this_data.VISp_clusters();
    
    for jj = 1 : length(clusters)
            
        tuning = this_data.load_tuning_curves(clusters(jj).id, trial_group_labels{ii});
        [~, p_svm, direction] = this_data.is_stationary_vs_motion_significant(clusters(jj).id, trial_group_labels{ii});
        
        c = c + 1;
        slope(c) = tuning.shuffled.beta(1);
        p_val(c) = tuning.shuffled.p;
        
        if p_val(c) < 1e-4
            p_val(c) = 1e-4;
        end
        
        classification(c) = nan;
        if p_svm < 0.05 && direction == 1
            classification(c) = 1;
        end
        if tuning.shuffled.p < 0.05 && tuning.shuffled.beta(1) >= 0 && mean(nanmean(tuning.tuning)) > nanmean(tuning.stationary_fr)
            classification(c) = 2;
        end
        if tuning.shuffled.p < 0.05 && tuning.shuffled.beta(1) < 0 && mean(nanmean(tuning.tuning)) > nanmean(tuning.stationary_fr)
            classification(c) = 3;
        end
    end
end


%% Print
assignin('base', 'classification_exc', classification);


%% Plot

x_lim = [1e-5, 1];
y_lim = [-0.2, 0.5];
y_tick = -0.2:0.2:0.4;
y_tick_label = {'-0.2', '0.0', '0.2', '0.4'};

hold on;
scatter(h_ax, p_val(classification == 1), slope(classification == 1), scatterball_size(1), cols{1}, 'fill');
scatter(h_ax, p_val(classification == 2), slope(classification == 2), scatterball_size(1), cols{2}, 'fill');
scatter(h_ax, p_val(classification == 3), slope(classification == 3), scatterball_size(1), cols{3}, 'fill');

set(h_ax, 'xscale', 'log', 'xlim', x_lim, 'ylim', y_lim, 'ytick', y_tick, 'yticklabel', y_tick_label, 'fontsize', 8);

line(h_ax, [0.05, 0.05], y_lim, 'color', [0.6, 0.6, 0.6], 'linestyle', '--');
line(h_ax, x_lim, [0, 0], 'color', [0.6, 0.6, 0.6], 'linestyle', '--');

xl = get(h_ax, 'xlim');

text(h_ax, 10^mean(log10(xl)), y_lim(2), sprintf('Excited %.1f%%', 100*sum(~isnan(classification))/length(classification)), ...
        'fontsize', 8, 'horizontalalignment', 'center', 'verticalalignment', 'bottom')

xlabel(h_ax, 'Significance (p-value)', 'fontsize', 8);
ylabel(h_ax, 'slope', 'fontsize', 8);
