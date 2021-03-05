clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

formatted_data_dir  = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

probe_fname = 'CAA-1112874_rec1_rec2_rec3';
cluster_id = 187;
window_t = [-1, 1];

% common time base of response window
common_time_base        = linspace(window_t(1), ...
    window_t(2), ...
    round(range(window_t)*10e3));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% location of the formatted data and cluster ID list
formatted_data_fname = fullfile(formatted_data_dir, [probe_fname, '.mat']);

% load the formatted data
data = load_data(formatted_data_fname);

% get selected clusters
selected_clusters = get_selected_clusters(data);
selected_cluster = get_cluster_by_id(selected_clusters, cluster_id);

cluster_fr = FiringRate(selected_cluster.spike_times);

% get mismatch trials
trials = [data.sessions(1).trials];

n_trials = length(trials);

% get the start and end of the gain change for each trial
protocol    = cell(n_trials, 1);
gain_dir    = cell(n_trials, 1);

% store whether to reject the trial (by default accept)
accept_trial = true(n_trials, 1);

% store the mismatch onset time for each trial (in probe time)
mm_start_t  = nan(n_trials, 1);

% spike convolution for each cluster for each trial
fr_convolution = cell(n_trials, 1);


% for each trial, get protocol type, gain direction, mismatch
% start time, whether it is a botched trial, and the spike
% convolution for each cluster
for trial_i = 1 : n_trials
    
    % save protocol and gain direction
    protocol{trial_i} = trials(trial_i).protocol;
    gain_dir{trial_i} = trials(trial_i).config.gain_direction;
    
    % start of and end of mismatch window
    mm_start_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == 1) + 1;
    mm_end_sample = find(diff(trials(trial_i).teensy_gain > 2.5) == -1) + 1;
    mm_start_t(trial_i) = trials(trial_i).probe_t(mm_start_sample);
    mm_end_t = trials(trial_i).probe_t(mm_end_sample);
    
    % reject trials in which the mismatch window is < 50ms
    if mm_end_t - mm_start_t(trial_i) < 0.05
        accept_trial(trial_i) = false;
    end
    
    % time base of response window
    response_window_time_base = mm_start_t(trial_i) + common_time_base;
    
    % convolved firing rate for each cluster for each trial
    fr_convolution{trial_i} = ...
        cluster_fr.get_convolution(response_window_time_base)';
    
end


%%
title_str = {{'MVT', '(gain down)'}, {'MVT', '(gain up)'}, {'MV', '(gain down)'}, {'MV', '(gain up)'}};
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_directions = {'down', 'up', 'down', 'up'};
yl = [0, 50];

figure
x = common_time_base;
for prot_i = 1 : 4
    
    % index of trials with this protocol and gain direction
    this_protocol_flag = strcmp(protocols{prot_i}, protocol) & ...
        strcmp(gain_directions{prot_i}, gain_dir) & ...
        accept_trial;
    
    subplot(2, 2, prot_i);
    hold on;
    
    
    % concatentate all responses for cluster, for protocol
    fr_conv_cat = cat(2, fr_convolution{this_protocol_flag});
    
    fr_mean = mean(fr_conv_cat, 2);
    fr_sem = std(fr_conv_cat, [], 2)/sqrt(size(fr_conv_cat, 2));
    
    upper = fr_mean + fr_sem;
    lower = fr_mean - fr_sem;
    
%     plot(x, upper, 'color', [0.7, 0.7, 0.7], 'linewidth', 1)
%     plot(x, lower, 'color', [0.7, 0.7, 0.7], 'linewidth', 1)
    h = fill([x, x(end:-1:1)], [upper; lower(end:-1:1)]', [0.7, 0.7, 0.7]);
    set(h, 'edgecolor', 'none');
    plot(x, fr_mean, 'k', 'linewidth', 2);
    line([0, 0], yl, 'color', 'k', 'linestyle', '--');
    line([0.2, 0.2], yl, 'color', 'k', 'linestyle', '--');
    ylim(yl)
    box off
    set(gca, 'plotboxaspectratio', [3, 1, 1], 'clipping', 'off');
    title(title_str{prot_i});
    ylabel('Avg. firing rate (Hz)');
    xlabel('Time (s)');
end

