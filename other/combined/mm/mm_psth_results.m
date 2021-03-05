% load the table data
table_fname = 'mismatch_nov20_100ms_peak_response.mat';

% where to save figures
save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\peak_response';


load(fname_fname);

% unique recording names
probe_fnames = unique(T.probe_name);

% 
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_dir = {'down', 'up', 'down', 'up'};
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+T', '(gain down)'}, {'V+T', '(gain up)'}};

n_protocols = length(protocols);

% create 
if ~isfolder(save_dir)
    mkdir(save_dir);
end

nstd = 2;
nbins = 2;

r = 0;
results = [];

x_baseline = -400:20:0;
x_baseline = (x_baseline(1:end-1) + x_baseline(2:end))/2;
x_response = 0:20:400;
x_response = (x_response(1:end-1) + x_response(2:end))/2;


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
        
        % for each protocol
        for prot_i = 1 : n_protocols
            
            % get index of this protocol for this cluster
            prot_idx = cluster_idx & ...
                strcmp(T.protocol, protocols{prot_i}) & ...
                strcmp(T.gain_direction, gain_dir{prot_i});
            
            % get baseline firing rates
            baseline_fr = T.fr_baseline(prot_idx);
            response_fr = T.fr_response(prot_idx);
            
            % perform stats test
            p_val = signrank(baseline_fr, response_fr);
            
            
            
            
            
            psth_baseline = sum(cat(1, T.hstgm_baseline{prot_idx}), 1);
            psth_response = sum(cat(1, T.hstgm_response{prot_idx}), 1);
            
            m_baseline = nanmean(psth_baseline);
            s_baseline = nanstd(psth_baseline);
            
            up = psth_response > (m_baseline + nstd*s_baseline);
            down = psth_response < (m_baseline - nstd*s_baseline);
            
            isup_idx = strfind(up, true(1, nbins));
            isdown_idx = strfind(down, true(1, nbins));
            
            isup = ~isempty(isup_idx); %#ok<*STREMP>
            isdown = ~isempty(isdown_idx);
            
            r = r + 1;
            results(r, 1) = probe_i;
            results(r, 2) = cluster_i;
            results(r, 3) = prot_i;
            results(r, 4) = is_cortical;
            results(r, 5) = isup;
            results(r, 6) = isdown;
            
            sp_n = prot_i;            
            h_ax(1, prot_i) = subplot(2, 2, sp_n);
            hold on;
            
            bar(x_baseline, psth_baseline, 'barwidth', 1, 'facecolor', 'k');
            bar(x_response, psth_response, 'barwidth', 1, 'facecolor', 'k');
            
            if isup
                bar(x_response(isup_idx(1)+(0:nbins-1)), psth_response(isup_idx(1)+(0:nbins-1)), ...
                    'barwidth', 1, 'facecolor', 'r');
            end
            
            if isdown
                bar(x_response(isdown_idx(1)+(0:nbins-1)), psth_response(isdown_idx(1)+(0:nbins-1)), ...
                    'barwidth', 1, 'facecolor', 'r');
            end
            
            line(get(gca, 'xlim'), m_baseline*[1, 1], 'color', 'k');
            line(get(gca, 'xlim'), (m_baseline+nstd*s_baseline)*[1, 1], 'color', 'k', 'linestyle', '--');
            line(get(gca, 'xlim'), (m_baseline-nstd*s_baseline)*[1, 1], 'color', 'k', 'linestyle', '--');
            
            title(title_str{prot_i});
            set(gca, 'plotboxaspectratio', [3, 1, 1]);
            
            yL = max(yL, max(get(gca, 'ylim')));
            
        end
        
        for prot_i = 1 : N_PROT
            set(gcf, 'currentaxes', h_ax(1, prot_i));
            set(h_ax(1, prot_i), 'ylim', [0, yL]);
            line([0, 0], [0, yL], 'color', 'k');
            line([200, 200], [0, yL], 'color', 'k');
        end
        
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fnames{probe_i}, cluster_ids(cluster_i), region_str));
        
        save_fnames{cluster_i} = fullfile(save_dir, sprintf('%s_%03i.pdf', probe_fnames{probe_i}, cluster_ids(cluster_i)));
        print(save_fnames{cluster_i}, '-bestfit', '-dpdf')
        
    end
    
    % join the PDFs
    output_fname = fullfile(save_dir, sprintf('%s_psth.pdf', probe_fnames{probe_i}));
    join_pdfs(save_fnames, output_fname, true);
    
    close all;
    
end



%%
for prot_i = 1 : N_PROT
    fprintf('%s:\n', [title_str{prot_i}{1}, ', ' title_str{prot_i}{2}]);
    idx = results(:, 3) == prot_i & results(:, 4) == 1 & results(:, 1) ~= 5;
    fprintf('# up:          %i/%i\n', sum(idx & results(:, 5) == 1), sum(idx));
    fprintf('# down:        %i/%i\n', sum(idx & results(:, 6) == 1), sum(idx));
    fprintf('# up and down: %i/%i\n', sum(idx & results(:, 5) == 1 & results(:, 6) == 1), sum(idx));
end
