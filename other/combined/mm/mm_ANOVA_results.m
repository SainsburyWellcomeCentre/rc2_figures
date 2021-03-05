table_fname = 'mismatch_nov20_100ms_ANOVA.mat';
load(table_fname);

probe_fnames = unique(T.probe_name);
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_dir = {'down', 'up', 'down', 'up'};
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+T', '(gain down)'}, {'V+T', '(gain up)'}};
N_PROT = length(protocols);

file_suffix = 'anova';

save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\mm_anova';
save_on = false;

if save_on && ~isfolder(save_dir)
    mkdir(save_dir);
end


% store whether the p-value is significant
cluster_count = 0;
results = [];

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
        
        % create figure
        figure('position', [141    78   754   896]);
        h_ax = [];
        yL = -inf;
        
        
        p = nan(2, N_PROT);
        p_control = nan(2, N_PROT);
        
        for prot_i = 1 : N_PROT
            
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
            
%             [~, response_idx] = max(avg_response);
            response_measure = avg_response - avg_bsl;
            
            % store significance
            results(1, cluster_count, prot_i) = p(1, prot_i);
            results(2, cluster_count, prot_i) = is_cortical;
            results(3, cluster_count, prot_i) = probe_i;
            results(4, cluster_count, prot_i) = p_control(1, prot_i);
            results(5, cluster_count, prot_i) = response_measure;
            results(6, cluster_count, prot_i) = cluster_ids(cluster_i);
            
            % plot
            % create subplot
            h_ax(prot_i, 1) = subplot(2, 2, prot_i);
            hold on;
            
            % scatter baseline and response
            for wind_i = 1 : n_windows
%               
                x = -2*n_windows*window_t + (wind_i-.5)*window_t;
                scatter(x*ones(length(response_control(wind_i, :)), 1), ...
                    response_control(wind_i, :), [], 'k', 'fill');
                line(x+window_t*[-.5, .5], ...
                    mean(response_control(wind_i, :))*[1, 1], 'color', 'r', 'linewidth', 1);

                x = -n_windows*window_t + (wind_i-.5)*window_t;
                scatter(x*ones(length(baseline(wind_i, :)), 1), ...
                    baseline(wind_i, :), [], 'k', 'fill');
                line(x+window_t*[-.5, .5], ...
                    mean(baseline(wind_i, :))*[1, 1], 'color', 'r', 'linewidth', 1);
                
                x = (wind_i-.5)*window_t;
                scatter(x*ones(length(response(wind_i, :)), 1), response(wind_i, :), [], 'k', 'fill');
                line(x+window_t*[-.5, .5], mean(response(wind_i, :))*[1, 1], 'color', 'r', 'linewidth', 1);
            end
            
            
            % x tick labels
            set(gca, 'xtick', n_windows*window_t*[-1.5, -.5, .5], ...
                     'xticklabel', {'Control', 'BSL', 'Response'}, ...
                     'xlim', n_windows*window_t*[-2, 1] + [-.5, .5], ...
                     'plotboxaspectratio', [3, 1, 1], ...
                     'fontsize', 8);
            
            % get the largest y-limit
            yL = max(yL, max(get(gca, 'ylim')));
            
            % axis title
            title(title_str{prot_i});
            
        end
        
        
        for prot_i = 1 : N_PROT
            
            set(gcf, 'currentaxes', h_ax(prot_i));
            set(h_ax(prot_i), 'ylim', [0, yL]);
            line([0, 0], [0, yL], 'color', 'k', 'linewidth', 1, 'linestyle', '--');
            line([-n_windows*window_t, -n_windows*window_t], [0, yL], 'color', 'k', 'linewidth', 1, 'linestyle', '--');
            h = text(max(get(h_ax(prot_i), 'xlim')), yL, sprintf('p=%.2f', p(1, prot_i)), ...
                'horizontalalignment', 'right', 'verticalalignment', 'middle');
            if p(1, prot_i) < 0.05
                set(h, 'color', 'r');
            end
            
            
            h = text(min(get(h_ax(prot_i), 'xlim')), yL, sprintf('p=%.2f', p_control(1, prot_i)), ...
                'horizontalalignment', 'left', 'verticalalignment', 'middle');
            if p_control(1, prot_i) < 0.05
                set(h, 'color', 'r');
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
f_valid_clusters = results(2, :, 1) == 1 & results(3, :, 1) ~= 5;

% 1. number of clusters passing each condition
pass = squeeze(results(1, f_valid_clusters, :) < 0.05);
sum(pass, 1)

% gainup or gaindown with translation
sum(sum(pass(:, 1:2), 2) > 0)


% 1. number of clusters passing each condition
pass = squeeze(results(4, f_valid_clusters, :) < 0.05);
sum(pass, 1)

% gainup or gaindown with translation
sum(sum(pass(:, 1:2), 2) > 0)
