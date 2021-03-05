input('Are you sure?');
clear all
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment = {'mismatch_nov20'};  % 'darkness', 'visual_flow', 'head_tilt', 'mismatch_nov20'
combination = {'protocols'};

formatted_data_dir  = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';


pad = [-1, 1];

% common time base of response window
common_time_base        = linspace(pad(1), ...
                                   pad(2), ...
                                   round(range(pad)*10e3));

                               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T = table();
r = 0;

c_clusters = 0;
fr_conv_avg = {};

for exp_i = 1 : length(experiment)
    
    % get details of the experiment
    [probe_fnames, protocols, ~, replay_of, ~, ~, ~, title_str, vis_stim, gain_directions] = experiment_details(experiment{exp_i}, combination{exp_i});
    
    % remove one experiment
    idx = strcmp(probe_fnames, 'CAA-1113221_rec1_rec2_rec3');
    probe_fnames(idx) = [];
    
    % number of protocols
    n_protocols = length(protocols);
    
    % for each probe recording
    for probe_i = 1 : length(probe_fnames)
        
        % location of the formatted data and cluster ID list
        formatted_data_fname = fullfile(formatted_data_dir, [probe_fnames{probe_i}, '.mat']);
        
        % load the formatted data
        data = load_data(formatted_data_fname);
        
        % get selected clusters
        selected_clusters = get_selected_clusters(data);
        
        % store number of clusters
        n_clusters = length(selected_clusters);
        
        % create object array handling firing rates
        for cluster_i = 1 : n_clusters
            cluster_fr(cluster_i) = FiringRate(selected_clusters(cluster_i).spike_times);
        end
        
        % get mismatch trials
        if strcmp(probe_fnames{probe_i}, 'CAA-1112872_rec1_rec1b_rec2_rec3')
            trials = [data.sessions(1).trials, data.sessions(2).trials];
        else
            trials = [data.sessions(1).trials];
        end
        n_trials = length(trials);
        
        % get the start and end of the gain change for each trial
        protocol = cell(n_trials, 1);
        gain_dir = cell(n_trials, 1);
        
        % store whether to reject the trial (by default accept)
        accept_trial = true(n_trials, 1);
        
        % store the mismatch onset time for each trial (in probe time)
        mm_start_t  = nan(n_trials, 1);
        
        % spike convolution for each cluster for each trial
        fr_convolution = cell(n_trials, n_clusters);
        
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
            
            % time base of window to look at
            window_time_base = mm_start_t(trial_i) + common_time_base;
            
            
            % for each cluster, get the convolved firing rate in the "response window" 
            for cluster_i = 1 : n_clusters
                
                % convolved firing rate for each cluster for each trial
                fr_convolution{trial_i, cluster_i} = ...
                    cluster_fr(cluster_i).get_convolution(window_time_base)';
            end
        end
        
        
        for cluster_i = 1 : n_clusters
            
            % determine if it's cortical
            region_str = selected_clusters(cluster_i).region_str;
            
            % is the cluster cortical
            is_cortical = ~isempty(regexp(region_str, 'VISp', 'once'));
            
            % loop over protocols and get averge firing rate for each cluster
            % for each protocol
            for prot_i = 1 : n_protocols
                
                % index of trials with this protocol and gain direction
                this_protocol_flag = strcmp(protocols{prot_i}, protocol) & ...
                    strcmp(gain_directions{prot_i}, gain_dir) & ...
                    accept_trial;
                
                
                % concatentate all responses for cluster, for protocol
                fr_conv_cat = cat(2, fr_convolution{this_protocol_flag, cluster_i});
                
                if is_cortical
                    
                    % average firing rate
                    if prot_i == 1
                        c_clusters = c_clusters + 1;
                    end
                    
                    fr_conv_avg{c_clusters}{prot_i} = mean(fr_conv_cat, 2);
                    
                end
            end
        end
    end
end



%% Average firing rate for each condition
title_str = {{'MVT', '(gain down)'}, {'MVT', '(gain up)'}, {'MV', '(gain down)'}, {'MV', '(gain up)'}};

figure
for prot_i = 1 : 4
    
    subplot(2, 2, prot_i);
    hold on;
    
    all_frs = cellfun(@(x)(x{prot_i}), fr_conv_avg, 'uniformoutput', false);
    all_frs = cat(2, all_frs{:})';
    
    x = common_time_base;
    bsl = x >= -0.1 & x < 0;
    
    all_frs_bsl_rem = bsxfun(@minus, all_frs, mean(all_frs(:, bsl), 2));
    all_frs = all_frs_bsl_rem';
%     all_frs = bsxfun(@rdivide, all_frs_bsl_rem, std(all_frs_bsl_rem, [], 2))';
    
    fr_mean = nanmean(all_frs, 2)';
    fr_std = nanstd(all_frs, [], 2)';
    fr_sem = nanstd(all_frs, [], 2)'/sqrt(size(all_frs, 2));
    
    upper = fr_mean + fr_sem;
    lower = fr_mean - fr_sem; %max(fr_mean - fr_sem, 0);
    
%     plot(x, upper, 'color', [0.7, 0.7, 0.7], 'linewidth', 1)
%     plot(x, lower, 'color', [0.7, 0.7, 0.7], 'linewidth', 1)
    h = fill([x, x(end:-1:1)], [upper, lower(end:-1:1)], [0.7, 0.7, 0.7]);
    set(h, 'edgecolor', 'none');
    plot(x, fr_mean, 'k', 'linewidth', 2);
    yl = [-2, 5];
    line([0, 0], yl, 'color', 'k', 'linestyle', '--');
    line([0.2, 0.2], yl, 'color', 'k', 'linestyle', '--');
    ylim(yl)
    box off
    set(gca, 'plotboxaspectratio', [3, 1, 1], 'clipping', 'off');
    title(title_str{prot_i});
    ylabel('Avg. firing rate (Hz)');
    xlabel('Time (s)');
end
set(gcf, 'renderer', 'painters')




%% Average z-score
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+M', '(gain down)'}, {'V+M', '(gain up)'}};

figure
for prot_i = 1 : 4
    
    subplot(2, 2, prot_i);
    hold on;
    
    all_frs = cellfun(@(x)(x{prot_i}), fr_conv_avg, 'uniformoutput', false);
    all_frs = cat(2, all_frs{:})';
    
    x = common_time_base;
    bsl = x >= -1 & x < 0;
    
    all_frs_bsl_rem = bsxfun(@minus, all_frs, mean(all_frs(:, bsl), 2));
    all_frs = bsxfun(@rdivide, all_frs_bsl_rem, std(all_frs_bsl_rem, [], 2))';
    
    fr_mean = nanmean(all_frs, 2)';
    fr_std = nanstd(all_frs, [], 2)';
    fr_sem = nanstd(all_frs, [], 2)'/sqrt(size(all_frs, 2));
    
    upper = fr_mean + fr_sem;
    lower = fr_mean - fr_sem; %max(fr_mean - fr_sem, 0);
    
    plot(x, upper, 'color', [0.7, 0.7, 0.7], 'linewidth', 1)
    plot(x, lower, 'color', [0.7, 0.7, 0.7], 'linewidth', 1)
    plot(x, fr_mean, 'k', 'linewidth', 2);
    yl = [-1, 2];
    line([0, 0], yl, 'color', 'k', 'linestyle', '--');
    line([0.2, 0.2], yl, 'color', 'k', 'linestyle', '--');
    ylim(yl)
    box off
    set(gca, 'plotboxaspectratio', [3, 1, 1], 'clipping', 'off');
    title(title_str{prot_i});
    ylabel('Avg. firing rate (Hz)');
    xlabel('Time (s)');
end
set(gcf, 'renderer', 'painters')




%%
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+M', '(gain down)'}, {'V+M', '(gain up)'}};

figure
for prot_i = 1 : 4
    
    h_ax = subplot(2, 2, prot_i);
    hold on;
    axis normal;
    
    x = common_time_base;
    
    % take 1s of baseline
    bsl = x >= -1 & x < 0;
    
    
    all_frs = cellfun(@(x)(x{prot_i}), fr_conv_avg, 'uniformoutput', false);
    all_frs = cat(2, all_frs{:})';
    
    % subtract baseline firing rate
    all_frs_bsl_rem = bsxfun(@minus, all_frs, mean(all_frs(:, bsl), 2));
    % divide by standard deviation across 1s
    all_frs_zscore = bsxfun(@rdivide, all_frs_bsl_rem, std(all_frs_bsl_rem(:, bsl), [], 2));
    
    h_im = imagesc(all_frs_zscore);
    set(h_im, 'xdata', x);
    set(gca, 'clim', [-3, 3]);
    
    yl = [0, 80];
    
    line([0, 0], yl, 'color', 'w', 'linestyle', '--');
    line([0.2, 0.2], yl, 'color', 'w', 'linestyle', '--');
    
    ylim(yl);
    
    box off
    set(gca, 'plotboxaspectratio', [1, 2, 1], 'clipping', 'off');
    title(title_str{prot_i});
    ylabel('Cluster #');
    xlabel('Time (s)');
    colormap('parula');
    
    if prot_i == 4
        pos = get(h_ax, 'position');
        ax = axes('position', pos);
        set(ax, 'clim', [-3, 3]);
        h = colorbar;
        set(get(h, 'label'), 'string', 'z-score');
        set(ax, 'visible', 'off');
    end
end
set(gcf, 'renderer', 'painters')






%% Heatmap firing rate
% 'results' from 'mm_ANOVA_results.m'
load('cluster_order_heatmap', 'results');
% load colormap
% load('red2blue_colormap', 'r2bcmap');
r2bcmap = map;%flipud(r2bcmap);

% which are the valid clusters
f_valid_clusters = results(2, :, 1) == 1 & results(3, :, 1) ~= 5;
results = results(:, f_valid_clusters, :);
% order according to response
[~, order_idx] = sort(squeeze(results(5, :, 2)), 'ascend');

[results(3, order_idx, 1); results(6, order_idx, 1)]

% title for subplots
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+M', '(gain down)'}, {'V+M', '(gain up)'}};

yl = [0, 80];
cl = [-8, 8];

figure
for prot_i = 1 : 4
    
    h_ax = subplot(2, 2, prot_i);
    hold on;
    axis normal;
    
    x = common_time_base;
    
    % take 1s of baseline
    bsl = x >= -1 & x < 0;
    
    all_frs = cellfun(@(x)(x{prot_i}), fr_conv_avg, 'uniformoutput', false);
    all_frs = cat(2, all_frs{order_idx})';
    
    % subtract baseline firing rate
    all_frs_bsl_rem = bsxfun(@minus, all_frs, mean(all_frs(:, bsl), 2));
    
    h_im = imagesc(all_frs_bsl_rem);
    set(h_im, 'xdata', x, 'ydata', 80:-1:1);
    set(gca, 'clim', cl, 'ydir', 'reverse');
    
    
    line([0, 0], yl, 'color', 'k', 'linestyle', '--');
    line([0.2, 0.2], yl, 'color', 'k', 'linestyle', '--');
    
    ylim(yl);
    
    box off;
    set(gca, 'plotboxaspectratio', [1, 2, 1], 'clipping', 'off');
    title(title_str{prot_i});
    ylabel('Cluster #');
    xlabel('Time (s)');
    colormap(r2bcmap);
    
    if prot_i == 4
        pos = get(h_ax, 'position');
        ax = axes('position', pos);
        set(ax, 'clim', cl);
        h = colorbar;
        set(get(h, 'label'), 'string', '\DeltaFR (Hz)');
        set(ax, 'visible', 'off');
    end
end
set(gcf, 'renderer', 'painters')



