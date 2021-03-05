clear all
close all



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_suffix = '100ms_ANOVA';

% load the table data
table_fname = sprintf('mismatch_nov20_%s.mat', file_suffix);

% where to save figure
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\unity_plot_anova';
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

for probe_i = 1 : length(probe_fnames)
    
    % entries in the table corresponding to this recording
    probe_idx = strcmp(T.probe_name, probe_fnames{probe_i});
    
    % clusters in this recording
    cluster_ids = unique(T.cluster_id(probe_idx));
    
    % for storing the temporary pdf names
    save_fnames = {};
    
    for cluster_i = 1 : length(cluster_ids)
        
        % count clusters
        cluster_count = cluster_count + 1;
        
        % entries in table corresponding to this cluster
        cluster_idx = probe_idx & T.cluster_id == cluster_ids(cluster_i);
        
        % brain region this cluster belongs to
        region_str = T.cluster_region{find(cluster_idx, 1)};
        
        % is the brain region in VIS cortex
        is_cortical = ~isempty(regexp(region_str, 'VISp', 'once'));        
        
        p = nan(2, n_protocols);
        p_control = nan(2, n_protocols);
        
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
        
    end
    
    h_ax = subplot(2, 2, prot_i);
    
    hold on;
    
    if prot_i == 1 || prot_i == 3
        u = unity_plot(T2, true(length(T2.p), 1), h_ax, 'v', true, 1, [0, 40]);
    else
        u = unity_plot(T2, true(length(T2.p), 1), h_ax, [], true, 1, [0, 40]);
    end
    
    set(u.ax, 'xlim', [0, 40], 'ylim', [0, 40]);
    
    xlabel('Baseline FR (Hz)');
    ylabel('Response FR (Hz)');
    title(title_str{prot_i});
    
end