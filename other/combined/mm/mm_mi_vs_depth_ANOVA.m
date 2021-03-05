clear all
close all



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_suffix = '100ms_ANOVA';

% load the table data
table_fname = sprintf('mismatch_nov20_%s.mat', file_suffix);

% location with formatted data (for boundaries)
formatted_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

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

% collect boundaries for 
for probe_i = length(probe_fnames) : -1 : 1
    boundaries{probe_i} = get_VISp_layer_boundaries(probe_fnames{probe_i}, formatted_dir);
end

avg_boundaries = average_boundaries(cat(1, boundaries{:}));


results = [];
results_region = [];

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
        from_tip = T.cluster_from_tip(find(cluster_idx, 1));
        
        % is the brain region in VIS cortex
        is_cortical = ~isempty(regexp(region_str, 'VISp', 'once'));
        
        % compute relative depth of cluster in layer
        relative_depth = get_relative_depth_in_region(from_tip, boundaries{probe_i});
        
        % save the p_values
        p = nan(2, n_protocols);
        p_control = nan(2, n_protocols);
        
        % for each protocol
        for prot_i = 1 : n_protocols
            
            % get index of this protocol for this cluster
            prot_idx = cluster_idx & ...
                strcmp(T.protocol, protocols{prot_i}) & ...
                strcmp(T.gain_direction, gain_dir{prot_i});
            
            % group the firing rates
            baseline = T.fr_baseline(prot_idx);
            response = T.fr_response(prot_idx);
            response_control = T.fr_response_control(prot_idx);
            
            baseline = cat(2, baseline{:});
            response = cat(2, response{:});
            response_control = cat(2, response_control{:});
            
            p(:, prot_i) = mm_do_ANOVA(baseline, response);
            p_control(:, prot_i) = mm_do_ANOVA(baseline, response_control);
            
            avg_response = mean(response(:));
            avg_bsl = mean(baseline(:));
            avg_response_control = mean(response_control(:));
            
%             [~, response_idx] = max(avg_response);
            response_measure = avg_response - avg_bsl;
            
            % store significance
            results(1, cluster_count, prot_i) = p(1, prot_i);
            results(2, cluster_count, prot_i) = p_control(1, prot_i);
            results(3, cluster_count, prot_i) = avg_bsl;
            results(4, cluster_count, prot_i) = avg_response;
            results(5, cluster_count, prot_i) = is_cortical;
            results(6, cluster_count, prot_i) = probe_i;
            results(7, cluster_count, prot_i) = relative_depth;
            results(8, cluster_count, prot_i) = T.cluster_id(find(prot_idx, 1));
            
            results_region{cluster_count, prot_i} = region_str;
        end
    end
end


%%
figure
for prot_i = 1 : 4
    
    cnt = 0;
    T2 = table();
    depths = [];
    
    for i = 1 : cluster_count
        
        if ~results(5, i, prot_i) || results(6, i, prot_i) == 5
            continue
        end
        
        cnt = cnt + 1;
        
        if results(1, i, prot_i) < 0.05 && results(2, i, prot_i) < 0.05
            T2.p(cnt, 1) = nan;
        else
            T2.p(cnt, 1) = results(1, i, prot_i);
        end
        
        T2.fr_x(cnt, 1) = results(3, i, prot_i);
        T2.fr_y(cnt, 1) = results(4, i, prot_i);
        
        T2.cluster_region{cnt, 1} = results_region{i, prot_i};
        T2.cluster_id(cnt, 1) = results(8, i, prot_i);
        T2.probe_id(cnt, 1) = results(6, i, prot_i);
        depths(cnt, 1) = results(7, i, prot_i);
        
    end
    
    h_ax = subplot(2, 2, prot_i);
    hold on;
    if prot_i == 1 || prot_i == 3
        u = mi_vs_depth_plot(T2, true(length(T2.p), 1), depths, avg_boundaries, h_ax, true, 'v');
    else
        u = mi_vs_depth_plot(T2, true(length(T2.p), 1), depths, avg_boundaries, h_ax, true);
    end
    
    set(gca, 'ytick', []);
    title(title_str{prot_i});
    
end