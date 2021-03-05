table_fname = 'mismatch_nov20_40ms_baseline_preceding_mulit_window.mat';
load(table_fname);

probe_fnames = unique(T.probe_name);
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_dir = {'down', 'up', 'down', 'up'};
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+T', '(gain down)'}, {'V+T', '(gain up)'}};
N_PROT = length(protocols);

save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\40ms_baseline_preceding_multi_window';
if ~isfolder(save_dir)
    mkdir(save_dir);
end

n_total = zeros(1, length(probe_fnames));
n_sig = zeros(N_PROT, length(probe_fnames));


for probe_i = 1 : length(probe_fnames)
    
    cluster_ids = unique(T.cluster_id(strcmp(T.probe_name, probe_fnames{probe_i})));
    
    save_fnames = {};
    
    for cluster_i = 1 : length(cluster_ids)
        
        idx = strcmp(T.probe_name, probe_fnames{probe_i}) & ...
            T.cluster_id == cluster_ids(cluster_i);
        
        region_str = T.cluster_region{find(idx, 1)};
        is_cortical = ~isempty(regexp(region_str, 'VISp', 'once'));
        
        figure('position', [141    78   754   896]);
        h_ax = [];
        yL = -inf;
        
        if is_cortical
            n_total(probe_i) = n_total(probe_i) + 1;
        end
        
        for prot_i = 1 : N_PROT
            
            idx = strcmp(T.probe_name, probe_fnames{probe_i}) & ...
                T.cluster_id == cluster_ids(cluster_i) & ...
                strcmp(T.protocol, protocols{prot_i}) & ...
                strcmp(T.gain_direction, gain_dir{prot_i});
            
            baseline = T.fr_baseline(idx);
            
            
            for wind_i = 1 : n_windows
                response{wind_i} = cellfun(@(x)(x(wind_i)), T.fr_response(idx));
                p_val(wind_i, prot_i) = signrank(baseline, response{wind_i});
            end
            
            
            if any(p_val(:, prot_i) < 0.05) && is_cortical
                n_sig(prot_i, probe_i) = n_sig(prot_i, probe_i) + 1;
            end
            
            response_avg = cellfun(@mean, response);
            
            
%             r = r + 1;
%             results(r, 1) = probe_i;
%             results(r, 2) = cluster_i;
%             results(r, 3) = prot_i;
%             results(r, 4) = is_cortical;
%             results(r, 5) = isup;
%             results(r, 6) = isdown;
            
            sp_n = prot_i;            
            h_ax(prot_i) = subplot(2, 2, sp_n);
            hold on;
            line([-baseline_window_t*1e3, 0], mean(baseline)*[1, 1], 'color', 'k');
            
            for wind_i = 1 : n_windows
                if p_val(wind_i, prot_i) < 0.05
                    col = [0.8500    0.3250    0.0980];
                else
                    col = 'k';
                end
                fill(1e3*[(wind_i-1)*window_t, wind_i*window_t, wind_i*window_t, (wind_i-1)*window_t], ...
                    [0, 0, response_avg([wind_i, wind_i])], col);
            end
            
            
%             line(get(gca, 'xlim'), m_baseline*[1, 1], 'color', 'k');
%             line(get(gca, 'xlim'), (m_baseline+nstd*s_baseline)*[1, 1], 'color', 'k', 'linestyle', '--');
%             line(get(gca, 'xlim'), (m_baseline-nstd*s_baseline)*[1, 1], 'color', 'k', 'linestyle', '--');
            h = title(title_str{prot_i});
            if any(p_val(:, prot_i) < 0.05)
                set(h, 'color', 'r')
            end
            
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


