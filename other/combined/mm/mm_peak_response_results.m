%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_suffix = '100ms_peak_response_CONTROL';

% load the table data
table_fname = sprintf('mismatch_nov20_%s.mat', file_suffix);

% where to save figure
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20\mismatch_nov20_response\100ms_around_max_or_min_response_CONTROL';
save_on = true;


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

% store whether the p-value is significant
cluster_count = 0;
results = [];

% for each recording
for probe_i = 1 : length(probe_fnames)
    
    % entries in the table corresponding to this recording
    probe_idx = strcmp(T.probe_name, probe_fnames{probe_i});
    
    % clusters in this recording
    cluster_ids = unique(T.cluster_id(probe_idx));
    
    % for storing the temporary pdf names
    save_fnames = {};
    
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
        
        % create figure
        figure('position', [141    78   754   896]);
        h_ax = [];
        yL = -inf;
        
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
            results(3, cluster_count, prot_i) = is_cortical;
            results(4, cluster_count, prot_i) = probe_i;
            
            % plot
            % create subplot
            h_ax(prot_i, 1) = subplot(4, 4, 4 + prot_i);
            hold on;
            
            % scatter baseline and response
            scatter(ones(length(baseline_fr), 1), baseline_fr, [], 'k', 'fill');
            scatter(2*ones(length(max_response_fr), 1), max_response_fr, [], 'k', 'fill');
            
            % plot lines between points
            for trial_i = 1 : length(baseline_fr)
                line([1, 2], [baseline_fr(trial_i), max_response_fr(trial_i)], 'color', 'k');
            end
            
            % x tick labels
            set(gca, 'xtick', [1, 2], 'xticklabel', {'BSL', 'MM max'}, 'xlim', [0.5, 2.5]);
            
            % get the largest y-limit
            yL = max(yL, max(get(gca, 'ylim')));
            
            % axis title
            title(title_str{prot_i});
            
            % create subplot
            h_ax(prot_i, 2) = subplot(4, 4, 8 + prot_i);
            hold on;
            
            % scatter baseline and response
            scatter(ones(length(baseline_fr), 1), baseline_fr, [], 'k', 'fill');
            scatter(2*ones(length(min_response_fr), 1), min_response_fr, [], 'k', 'fill');
            
            % plot lines between points
            for trial_i = 1 : length(baseline_fr)
                line([1, 2], [baseline_fr(trial_i), min_response_fr(trial_i)], 'color', 'k');
            end
            
            % x tick labels
            set(gca, 'xtick', [1, 2], 'xticklabel', {'BSL', 'MM min'}, 'xlim', [0.5, 2.5]);
            
            % get the largest y-limit
            yL = max(yL, max(get(gca, 'ylim')));
            
        end
        
        
        for prot_i = 1 : n_protocols
            
            set(gcf, 'currentaxes', h_ax(prot_i, 1));
            set(h_ax(prot_i, 1), 'ylim', [0, yL]);
            h_text = text(0.5, yL, sprintf('p = %.2f', p_val_max(prot_i)), ...
                'horizontalalignment', 'left', ...
                'verticalalignment', 'top');
            
            % if significant, label p-value red
            if p_val_max(prot_i) < 0.05
                set(h_text, 'color', 'r');
            end
            
            
            set(gcf, 'currentaxes', h_ax(prot_i, 2));
            set(h_ax(prot_i, 2), 'ylim', [0, yL]);
            h_text = text(0.5, yL, sprintf('p = %.2f', p_val_min(prot_i)), ...
                'horizontalalignment', 'left', ...
                'verticalalignment', 'top');
            
            % if significant, label p-value red
            if p_val_min(prot_i) < 0.05
                set(h_text, 'color', 'r');
            end
        end
        
        % add figure title, recording name, cluster id and brain region of
        % cluster
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fnames{probe_i}, cluster_ids(cluster_i), region_str));
        
        if save_on
            % save the pdf and store the name
            save_fnames{cluster_i} = fullfile(save_dir, sprintf('%s_%03i.pdf', probe_fnames{probe_i}, cluster_ids(cluster_i)));
            print(save_fnames{cluster_i}, '-bestfit', '-dpdf')
        end
    end
    
    if save_on
        % join the PDFs
        output_fname = fullfile(save_dir, sprintf('%s_%s.pdf', probe_fnames{probe_i}, file_suffix));
        join_pdfs(save_fnames, output_fname, true);
    end
    
    close all;
    
end


% examine the reults
f_valid_clusters = results(3, :, 1) == 1 & results(4, :, 1) ~= 5;

% 1. number of clusters passing each condition
pass = squeeze(results(1, f_valid_clusters, :) < 0.05 | results(2, f_valid_clusters, :) < 0.05);
sum(pass, 1)

% gainup or gaindown with translation
sum(sum(pass(:, 1:2), 2) > 0)


