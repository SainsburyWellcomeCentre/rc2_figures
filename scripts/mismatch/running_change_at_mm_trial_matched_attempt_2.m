% For each mismatch trial, takes the running speed around the mismatch and
% looks for periods most similar to that running speed in the period before
% the mismatch.

% Second attempt:
%   Allow the search for each mismatch period to be over ALL trials instead 
%   of the same trial.


clear all
close all

n_sds                   = 2;
window_1                = [-0.15, 0.05];
window_2                = [0.1, 0.3];
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
store_details           = [];

fname = '1s';

% average trace is a 1s long trace from -1 to 1s around mismatch onset
load('avg_to_compare_1s.mat', 'avg_to_compare');

% template velocity
template_velocity = avg_to_compare(:);

% the number of samples to compare on each window
n_samples_to_compare = length(template_velocity);

% minimum amplitude we will attempt to find
template_amplitude = range(template_velocity);





for probe_i = 1 : length(probe_fnames)
    
    data                = load_formatted_data(probe_fnames{probe_i}, config);
    clusters            = data.VISp_clusters;
    
    exp_obj             = MismatchExperiment(data, config);
    
    for prot_i = protocol
        
        % get trials for this protocol
        trials = exp_obj.trials_of_type(prot_i);
        n_trials = length(trials);
        
        % get running traces for each trial to display
        [display_running, display_t] = exp_obj.running_around_mismatch_by_protocol(prot_i, display_window);
        
        n_samples = size(display_running, 1) * trials(1).fs;
        common_t = display_window(1) + (0:n_samples-1)*(1/10e3);
        
        % preallocate cell array for spike rates of each cluster
        mm_spike_rate = cell(1, length(clusters));
        matched_spike_rate = cell(1, length(clusters));
        
        for cluster_i = 1 : length(clusters)
            
            % for this cluster, get the spike rate around the mismatch
            mm_spike_rate{cluster_i} = exp_obj.firing_around_mismatch_by_protocol(clusters(cluster_i), prot_i, display_window);
            
            % make sure it is the same number of trials
            assert(n_trials == size(display_running, 2), ...
                    'Size of spike matrix traces is not equal to number of trials');
            
            % get FiringRate object for later use in getting the firing
            % rate traces
            cluster_fr(cluster_i) = FiringRate(clusters(cluster_i).spike_times);
        end
        
        n_samples_before_match_to_show = find(display_t > 0, 1);
        n_samples_after_match_to_show = sum(display_t > 0);
        
        % search these trials (with translation)
        search_trials = [exp_obj.trials_of_type(1), exp_obj.trials_of_type(2)];
        
        % store the data each loop
        velocities_to_search = {};
        times_for_search = {};
        
        % gather all running data for this mouse
        for trial_i = 1 : length(search_trials)
            
            mm_onset_t      = search_trials(trial_i).mismatch_onset_t();
            mm_onset_idx    = find(search_trials(trial_i).probe_t > mm_onset_t, 1, 'first');
            
            analysis_window = search_trials(trial_i).analysis_window();
            
            search_idx_1 = n_samples_before_match_to_show : mm_onset_idx - n_samples_after_match_to_show;
            search_idx_2 = mm_onset_idx + 3 * 10000 : find(analysis_window, 1, 'last') - n_samples_after_match_to_show;
            
            % velocities
            velocities_to_search{end+1} = search_trials(trial_i).velocity(search_idx_1);
            velocities_to_search{end+1} = search_trials(trial_i).velocity(search_idx_2);
            
            % corresponding probe times
            times_for_search{end+1} = search_trials(trial_i).probe_t(search_idx_1);
            times_for_search{end+1} = search_trials(trial_i).probe_t(search_idx_2);
        end
        
        err = {};
        err_t = {};
        
        % do the search
        for search_i = 1 : length(velocities_to_search)
            
            % number of samples we have to search
            n_samples_to_search = length(velocities_to_search{search_i}) - n_samples_to_compare;
            
            % preallocate error and 
            err{search_i} = nan(n_samples_to_search, 1);
            err_t{search_i} = nan(n_samples_to_search, 1);
            
            for sample_i = 1 : n_samples_to_search - 3
                
                subsearch_velocity = velocities_to_search{search_i}(sample_i + (0:n_samples_to_compare-1));
                err{search_i}(sample_i) = sum((subsearch_velocity - template_velocity).^2);
                err_t{search_i}(sample_i) = times_for_search{search_i}(n_samples_before_match_to_show + sample_i);
            end
        end
        
        
        
        % take the 26 sample points with the lowest error
        min_errors  = nan(1, length(err));
        min_idx     = nan(1, length(err));
        
        for search_i = 1 : length(err)
            [a, b] = min(err{search_i});
            if isempty(a)
                min_errors(search_i) = inf;
                min_idx(search_i) = -1;
            else
                [min_errors(search_i), min_idx(search_i)] = min(err{search_i});
            end
        end
        
        
        % sort these errors
        [min_errors_sorted, min_errors_sorted_idx] = sort(min_errors, 'ascend');
        
        
        min_errors_to_take = min_errors_sorted_idx(1:26);
        
        store_running_matched = [];
        
        trigger_t = nan(1, length(min_errors_to_take));
        
        for search_i = 1 : length(min_errors_to_take)
            
            trigger_t(search_i) = err_t{min_errors_to_take(search_i)}(min_idx(search_i));
            time_base = common_t + trigger_t(search_i);
            
            vel = velocities_to_search{min_errors_to_take(search_i)}(min_idx(search_i) - n_samples_before_match_to_show + (0 : length(display_t)-1));
            
            store_running_matched = [store_running_matched, vel(:)];
            
            for cluster_i = 1 : length(clusters)
                matched_spike_rate{cluster_i}(:, end+1) = cluster_fr(cluster_i).get_convolution(time_base);
            end
        end
        
        
        % 
        include_trial = false(1, n_trials);
        
        
        for trial_i = 1 : n_trials
            
            % was there a change in velocity for this trial?
            changed_down = exp_obj.trial_changed_velocity(trials(trial_i).id, window_1, window_2, n_sds);
            
            % skip trial if there was no change in velocity
            if ~changed_down
                continue
            end
            
            store_running_mm = [store_running_mm, display_running(:, trial_i)];
            
            matched_t = trials(trial_i).probe_t(I + n_samples_before_match_to_show);
            
            include_trial(trial_i) = true;
        end
        
        
        for cluster_i = 1 : length(clusters)
            store_spikes_mm         = [store_spikes_mm, mean(mm_spike_rate{cluster_i}(:, include_trial), 2)];
            store_spikes_matched    = [store_spikes_matched, mean(matched_spike_rate{cluster_i}, 2)];
        end
    end
end




%% PLOT AVERAGES
yM = 60;

h_fig                   = figs.a4figure();

subplot(2, 2, 1)
hold on

plot(display_t, store_running_mm, 'color', [0.6, 0.6, 0.6]);
plot(display_t, mean(store_running_mm, 2), 'k');
ylim([0, yM]);
xlim([-1, 1]);
line([0, 0], [0, yM], 'color', 'k')
text(0, yM, sprintf('n = %i', size(store_running_mm, 2)), 'verticalalignment', 'top', 'horizontalalignment', 'left');
xlabel('Time from MM onset (s)')
ylabel('Running (cm/s)')
title('Mismatch trials');
box off


subplot(2, 2, 2)
hold on
plot(display_t, store_running_matched, 'color', [0.6, 0.6, 0.6]);
plot(display_t, mean(store_running_matched, 2), 'k');
ylim([0, yM]);
line([0, 0], [0, yM], 'color', 'k')
text(0, yM, sprintf('n = %i', size(store_running_matched, 2)), 'verticalalignment', 'top', 'horizontalalignment', 'left');
title('Matched trials');
box off


yL = [-4, 6];
bsl = display_t > -1 & display_t < 0;

subplot(2, 2, 3)
hold on

m_rm = bsxfun(@minus, store_spikes_mm, mean(store_spikes_mm(bsl, :), 1));
m = nanmean(m_rm, 2)';
s = nanstd(m_rm, [], 2)'/sqrt(sum(~isnan(m_rm(1, :))));
h = fill([display_t, display_t(end:-1:1)], [m-s, m(end:-1:1)+s(end:-1:1)], 'r');
set(h, 'facealpha', 0.6);
plot(display_t, m, 'r');
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
h = fill([display_t, display_t(end:-1:1)], [m-s, m(end:-1:1)+s(end:-1:1)], 'r');
set(h, 'facealpha', 0.6);
plot(display_t, m, 'r');
ylim(yL);
line([0, 0], yL, 'color', 'k');
title('Matched');
box off

FigureTitle(gcf, 'Average running speed around MM onset');
figs.save_fig(sprintf('averages_with_spikes_%s.pdf', fname));





