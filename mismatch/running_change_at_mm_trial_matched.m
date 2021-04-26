% For each mismatch trial, takes the running speed around the mismatch and
% looks for periods most similar to that running speed in the period before
% the mismatch.

clear all
close all

window_t                = [-0.2, 0.2];
display_window          = [-1, 1];
protocol                = 2;


%%
config                  = RC2AnalysisConfig();

protocols               = MismatchExperiment.protocol_ids;
protocol_labels         = MismatchExperiment.protocol_label;

figs                    = RC2Figures(config);
figs.save_on            = true;
figs.set_figure_subdir('mismatch', 'running_change_at_mm', 'trial_matched');

probe_fnames            = experiment_details('mismatch_nov20', 'protocol');

running                 = cell(length(probe_fnames));

store_running_mm        = [];
store_running_matched   = [];
store_spikes_mm         = [];
store_spikes_matched    = [];


for probe_i = 1 : length(probe_fnames)
    
    data                = config.load_formatted_data(probe_fnames{probe_i});
    clusters            = data.VISp_clusters;
    
    exp_obj             = MismatchExperiment(data, config);
    
    for prot_i = protocol%1 : length(protocols)  % 
                
        [running, t] = exp_obj.running_around_mismatch(prot_i, display_window);
        
        mm_spike_rate = cell(1, length(clusters));
        for cluster_i = 1 : length(clusters)
            mm_spike_rate{cluster_i} = exp_obj.firing_around_mismatch(clusters(cluster_i), prot_i, display_window);
            cluster_fr(cluster_i) = FiringRate(clusters(cluster_i).spike_times);
        end
        
        trials = exp_obj.trials_of_type(prot_i);
        
        for trial_i = 1 : length(trials)
            trial_i
            comparison_idx = t > window_t(1) & t < window_t(2);
            
            % velocity around mismatch to compare
            mismatch_velocity = running(comparison_idx, trial_i);
            
            % velocity up to the mismatch
            mm_onset_t = trials(trial_i).mismatch_onset_t();
            mm_onset_idx = find(trials(trial_i).probe_t > mm_onset_t, 1, 'first');
            
            normal_velocity = trials(trial_i).velocity((length(mismatch_velocity)+1):mm_onset_idx);
            
            err = nan(length(normal_velocity) - length(mismatch_velocity), 1);
            for sample_i = 1 : length(normal_velocity) - length(mismatch_velocity)
                
                cut_normal_velocity = normal_velocity(sample_i + (0:length(mismatch_velocity)-1));
                err(sample_i) = sum((cut_normal_velocity - mismatch_velocity).^2);
            end
            [~, I] = min(err);
            
            size(running, 1)/2;
            matched_idx = I + round(length(mismatch_velocity)/2) + (0:size(running, 1)-1);
            
            store_running_mm = [store_running_mm, running(:, trial_i)];
            store_running_matched = [store_running_matched, trials(trial_i).velocity(matched_idx)];
            
            n_samples = range(display_window) * trials(1).fs;
            common_t = display_window(1) + (0:n_samples-1)*(1/trials(trial_i).fs);
            matched_t = trials(trial_i).probe_t(I + round(length(mismatch_velocity)/2));
            time_base = common_t + matched_t;
            
            for cluster_i = 1 : length(clusters)
                matched_spike_rate{cluster_i}(:, trial_i) = cluster_fr(cluster_i).get_convolution(time_base);
            end
        end
        
        
        for cluster_i = 1 : length(clusters)
            store_spikes_mm = [store_spikes_mm, mean(mm_spike_rate{cluster_i}, 2)];
            store_spikes_matched = [store_spikes_matched, mean(matched_spike_rate{cluster_i}, 2)];
        end
    end
end



%% PLOT AVERAGES
n_up = size(store_running_mm, 2);
yM = 40;

h_fig                   = figs.a4figure();

subplot(2, 2, 1)
hold on
if n_up > 0
    m = mean(store_running_mm, 2)';
    s = std(store_running_mm, [], 2)';
    fill([t, t(end:-1:1)], [m-s, m(end:-1:1)+s(end:-1:1)], [0.7, 0.7, 0.7]);
    plot(t, m, 'k');
end
ylim([0, yM]);
xlim([-1, 1]);
line([0, 0], [0, yM], 'color', 'k')
text(0, yM, sprintf('n = %i', n_up), 'verticalalignment', 'top', 'horizontalalignment', 'left');
xlabel('Time from MM onset (s)')
ylabel('Running (cm/s)')
title('Mismatch trials');
box off

subplot(2, 2, 2)
hold on
m = mean(store_running_matched, 2)';
s = std(store_running_matched, [], 2)';
fill([t, t(end:-1:1)], [m-s, m(end:-1:1)+s(end:-1:1)], [0.7, 0.7, 0.7]);
plot(t, m, 'k');
ylim([0, yM]);
line([0, 0], [0, yM], 'color', 'k')
text(0, yM, sprintf('n = %i', size(store_running_matched, 2)), 'verticalalignment', 'top', 'horizontalalignment', 'left');
title('Matched trials');
box off

FigureTitle(gcf, 'Average running speed around MM onset');
figs.save_fig('averages.pdf');



n_up = size(store_running_mm, 2);
yL = [-4, 6];
bsl = t > -1 & t < 0;
m_rm = bsxfun(@minus, store_spikes_mm, mean(store_spikes_mm(bsl, :), 1));
m_all = nanmean(m_rm, 2)';
s_all = nanstd(m_rm, [], 2)'/sqrt(sum(~isnan(m_rm(1, :))));


subplot(2, 2, 3)
hold on
if n_up > 0
    
    m_rm = bsxfun(@minus, store_spikes_mm, mean(store_spikes_mm(bsl, :), 1));
    
    m = nanmean(m_rm, 2)';
    s = nanstd(m_rm, [], 2)'/sqrt(sum(~isnan(m_rm(1, :))));
    
    h = fill([t, t(end:-1:1)], [m-s, m(end:-1:1)+s(end:-1:1)], 'r');
    set(h, 'facealpha', 0.6);
    plot(t, m, 'r');
end
ylim(yL);
line([0, 0], yL, 'color', 'k');
ylabel('\Delta Hz');
title('Mismatch');
box off


subplot(2, 2, 4)
hold on
m_rm = bsxfun(@minus, store_spikes_matched, mean(store_spikes_matched(bsl, :), 1));
m = nanmean(m_rm, 2)';
s = nanstd(m_rm, [], 2)'/sqrt(sum(~isnan(m_rm(1, :))));
h = fill([t, t(end:-1:1)], [m-s, m(end:-1:1)+s(end:-1:1)], 'r');
set(h, 'facealpha', 0.6);
plot(t, m, 'r');
ylim(yL);
line([0, 0], yL, 'color', 'k');
title('Matched');
box off

FigureTitle(gcf, 'Average running speed around MM onset');
figs.save_fig('averages_with_spikes.pdf');





