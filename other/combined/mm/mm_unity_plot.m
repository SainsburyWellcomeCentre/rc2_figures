clear all
close all



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_suffix = '100ms_peak_response_CONTROL';

% load the table data
table_fname = sprintf('mismatch_nov20_%s.mat', file_suffix);

% where to save figure
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\unity_plot';
save_on = false;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load data
load(table_fname);

% unique recording names
probe_fnames = unique(T.probe_name);

% protocols to plot. probably won't change
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_dir = {'down', 'up', 'down', 'up'};
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+M', '(gain down)'}, {'V+M', '(gain up)'}};

% number of protocols
n_protocols = length(protocols);

% create save directory if it doesn't exist
if ~isfolder(save_dir)
    mkdir(save_dir);
end

cluster_count = 0;

% for each recording
for probe_i = 1 : length(probe_fnames)
    
    % entries in the table corresponding to this recording
    probe_idx = strcmp(T.probe_name, probe_fnames{probe_i});
    
    % clusters in this recording
    cluster_ids = unique(T.cluster_id(probe_idx));
    
    % for storing the temporary pdf names
    save_fnames = {};
    
    % count the clusters
    cnts = 0;
    
    % for each cluster
    for cluster_i = 1 : length(cluster_ids)
        
        % count clusters
        cluster_count = cluster_count + 1;
        
        % entries in table corresponding to this cluster
        cluster_idx = strcmp(T.probe_name, probe_fnames{probe_i}) & ...
            T.cluster_id == cluster_ids(cluster_i);
        
        % brain region this cluster belongs to
        region_str = T.cluster_region{find(cluster_idx, 1)};
        
        % is the brain region in VIS cortex
        is_cortical = ~isempty(regexp(region_str, 'VISp', 'once'));
        
        % save the p_values
        p_val_max = nan(1, n_protocols);
        p_val_min = nan(1, n_protocols);
        
        % for each protocol
        for prot_i = 1 : n_protocols
            
            % get index of this protocol for this cluster
            prot_idx = cluster_idx & ...
                strcmp(T.protocol, protocols{prot_i}) & ...
                strcmp(T.gain_direction, gain_dir{prot_i});
            
            % get baseline firing rates
            baseline_fr = T.fr_baseline(prot_idx);
            max_response_fr = T.fr_response_max(prot_idx);
            min_response_fr = T.fr_response_min(prot_idx);
            
            % perform stats test
            p_val_max(prot_i) = signrank(baseline_fr, max_response_fr);
            p_val_min(prot_i) = signrank(baseline_fr, min_response_fr);
            
            % store significance
            results(1, cluster_count, prot_i) = p_val_max(prot_i);
            results(2, cluster_count, prot_i) = p_val_min(prot_i);
            results(3, cluster_count, prot_i) = nanmean(baseline_fr);
            results(4, cluster_count, prot_i) = nanmean(max_response_fr);
            results(5, cluster_count, prot_i) = nanmean(min_response_fr);
            results(6, cluster_count, prot_i) = is_cortical;
            results(7, cluster_count, prot_i) = probe_i;
            
        end
    end
end

%%

figure
for prot_i = 1 : 4
    
    cnt = 0;
    T2.p = [];
    T2.fr_x = [];
    T2.fr_y = [];
    
    for i = 1 : cluster_count
        
        if ~results(6, i, prot_i) || results(7, i, prot_i) == 5
            continue
        end
        
        cnt = cnt + 1;
        
        % whether to take max or min
        if results(1, i, prot_i) < 0.05 && results(2, i, prot_i) < 0.05
            [~, idx] = max(abs(results(4:5, i, prot_i)));
            T2.fr_y(cnt, 1) = results(3+idx, i, prot_i);
            T2.p(cnt, 1) = results(idx, i, prot_i);
        elseif results(1, i, prot_i) < 0.05 && results(2, i, prot_i) >= 0.05
            T2.fr_y(cnt, 1) = results(4, i, prot_i);
            T2.p(cnt, 1) = results(1, i, prot_i);
        elseif results(1, i, prot_i) >= 0.05 && results(2, i, prot_i) < 0.05
            T2.fr_y(cnt, 1) = results(5, i, prot_i);
            T2.p(cnt, 1) = results(2, i, prot_i);
        else
            [~, idx] = max(abs(results(4:5, i, prot_i)));
            T2.fr_y(cnt, 1) = results(3+idx, i, prot_i);
            T2.p(cnt, 1) = results(idx, i, prot_i);
        end
        
        T2.fr_x(cnt, 1) = results(3, i, prot_i);
    end
    
    h_ax = subplot(2, 2, prot_i);
    hold on;
    if prot_i == 1 || prot_i == 3
        u = unity_plot(T2, true(length(T2.p), 1), h_ax, 'v');
    else
        u = unity_plot(T2, true(length(T2.p), 1), h_ax);
    end
    xlabel('Baseline FR (Hz)');
    ylabel('"Control" period FR (Hz)');
    title(title_str{prot_i});
    
end