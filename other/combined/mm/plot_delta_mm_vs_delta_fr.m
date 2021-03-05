table_fname = 'mismatch_nov20_600ms_peak_baseline_preceding.mat'; % C:\Users\Lee\Documents\mvelez\data\tables\mismatch_nov20\
table2_fname = 'mismatch_nov20_400ms_psth_baseline_preceding.mat';
load(table_fname, 'T');
load(table2_fname, 'Tpsth');

probe_fnames = unique(T.probe_name);
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_dir = {'down', 'up', 'down', 'up'};
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+T', '(gain down)'}, {'V+T', '(gain up)'}};
N_PROT = 4;

save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\600ms_peak_baseline_preceding';
if ~isfolder(save_dir)
    mkdir(save_dir);
end

n_clust = zeros(1, length(probe_fnames));
sig_mm_response = zeros(N_PROT, length(probe_fnames));
sig_mm_corr = zeros(N_PROT, length(probe_fnames));

% T(cellfun(@isempty, regexp(T.cluster_region, 'VISp')), :) = [];

for probe_i = 1 : length(probe_fnames)
    
    cluster_ids = unique(T.cluster_id(strcmp(T.probe_name, probe_fnames{probe_i})));
    
    save_fnames = {};
    
    for cluster_i = 1 : length(cluster_ids)
        
        figure('position', [141    78   754   896]);
        h_ax = [];
        yL = -inf;
        yl2 = inf;
        yL2 = -inf;
        xl2 = inf;
        xL2 = -inf;
        
        p_val = nan(N_PROT, 1);
        r = nan(N_PROT, 1);
        p_r = nan(N_PROT, 1);
        m = nan(N_PROT, 2);
        
        idx = strcmp(T.probe_name, probe_fnames{probe_i}) & ...
            T.cluster_id == cluster_ids(cluster_i);
        
        region_str = T.cluster_region{find(idx, 1)};
        is_cortical = ~isempty(regexp(region_str, 'VISp', 'once'));
        
        if is_cortical
            n_clust(probe_i) = n_clust(probe_i) + 1;
        end
        
        for prot_i = 1 : N_PROT
            
            idx = strcmp(T.probe_name, probe_fnames{probe_i}) & ...
                T.cluster_id == cluster_ids(cluster_i) & ...
                strcmp(T.protocol, protocols{prot_i}) & ...
                strcmp(T.gain_direction, gain_dir{prot_i});
            
            baseline = T.fr_baseline(idx);
            mm = T.fr_mm(idx);
            delta_mm = T.delta_mm(idx);
            delta_fr = T.delta_fr(idx);
            
            assert(nansum(delta_fr - (mm - baseline)) < 0.1);
            
            sp_n = N_PROT + prot_i;            
            h_ax(1, prot_i) = subplot(4, N_PROT, sp_n);
            hold on;
            scatter(ones(sum(idx), 1), baseline, [], 'k', 'fill');
            scatter(2*ones(sum(idx), 1), mm, [], 'k', 'fill');
            line([ones(1, sum(idx)); 2*ones(1, sum(idx))], [T.fr_baseline(idx)'; T.fr_mm(idx)'], ...
                'color', [0.5, 0.5, 0.5]);
            line([0.8, 1.2], nanmedian(T.fr_baseline(idx))*[1, 1], 'color', 'k', 'linewidth', 2);
            line([1.8, 2.2], nanmedian(T.fr_mm(idx))*[1, 1], 'color', 'k', 'linewidth', 2);
            title(title_str{prot_i});
            
            yL = max(yL, max(get(h_ax(1, prot_i), 'ylim')));
            
            p_val(prot_i) = signrank(T.fr_mm(idx), T.fr_baseline(idx));
            
            if p_val(prot_i) < 0.05 && is_cortical
                sig_mm_response(prot_i, probe_i) = sig_mm_response(prot_i, probe_i) + 1;
            end
            
            if prot_i == 1
                ylabel('Firing rate (Hz)');
            end
            
            sp_n = 2*N_PROT + prot_i;            
            h_ax(2, prot_i) = subplot(4, N_PROT, sp_n);
            hold on;
            scatter(delta_mm, delta_fr, [], 'k');
            idx2 = ~isnan(delta_mm) & ~isnan(delta_fr);
            [r(prot_i), p_r(prot_i)] = corr(delta_mm(idx2), delta_fr(idx2)); % , 'type', 'spearman'
            m(prot_i, :) = polyfit(delta_mm(idx2), delta_fr(idx2), 1);
            
            if p_r(prot_i) < 0.05 && is_cortical
                sig_mm_corr(prot_i, probe_i) = sig_mm_corr(prot_i, probe_i) + 1;
            end
            
            yl2 = min(yl2, min(get(h_ax(2, prot_i), 'ylim')));
            yL2 = max(yL2, max(get(h_ax(2, prot_i), 'ylim')));
            xl2 = min(xl2, min(get(h_ax(2, prot_i), 'xlim')));
            xL2 = max(xL2, max(get(h_ax(2, prot_i), 'xlim')));
            
            if prot_i == 1
                xlabel('\DeltaMM (cm/s)');
                ylabel('\DeltaFR (MM - BSL)');
            end
            
        end
        
        for prot_i = 1 : N_PROT
            
            set(gcf, 'currentaxes', h_ax(1, prot_i));
            
            set(h_ax(1, prot_i), 'ylim', yL*[-0.1, 1], ...
                       'xtick', [1, 2], ...
                       'xticklabel', {'BSL', 'MM'}, ...
                       'xlim', [0.7, 2.3])
            
            h_txt = text(0.7, yL, sprintf('p = %.2f', p_val(prot_i)), ...
                'horizontalalignment', 'left', 'verticalalignment', 'top');
            
            if p_val(prot_i) < 0.05
                set(h_txt, 'color', 'r');
            end
            
            
            set(gcf, 'currentaxes', h_ax(2, prot_i));
            set(h_ax(2, prot_i), 'xlim', [xl2, xL2], 'ylim', [yl2, yL2]);
            line([xl2, xL2], m(prot_i, 1)*[xl2, xL2] + m(prot_i, 2), 'color', 'k', 'linestyle', '--');
            line([xl2, xL2], [0, 0], 'color', [0.8, 0.8, 0.8]);
            line([0, 0], [yl2, yL2], 'color', [0.8, 0.8, 0.8]);
            h_txt = text(xl2, yL2, sprintf('R^2 = %.2f, p = %.2f', r(prot_i)^2, p_r(prot_i)), ...
                'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 8);
            
            if p_r(prot_i) < 0.05
                set(h_txt, 'color', 'r');
            end
        end
        
        FigureTitle(gcf, sprintf('%s, Cluster %i, %s', probe_fnames{probe_i}, cluster_ids(cluster_i), region_str));
        
        save_fnames{cluster_i} = fullfile(save_dir, sprintf('%s_%03i.pdf', probe_fnames{probe_i}, cluster_ids(cluster_i)));
        print(save_fnames{cluster_i}, '-bestfit', '-dpdf')
    end
    
    % join the PDFs
    output_fname = fullfile(save_dir, sprintf('%s_mismatch_responsiveness.pdf', probe_fnames{probe_i}));
    join_pdfs(save_fnames, output_fname, true);
    
    close all;
end


sum(n_clust([1:4, 6]))
sum(sig_mm_response(:, [1:4, 6]), 2)
sum(sig_mm_corr(:, [1:4, 6]), 2)