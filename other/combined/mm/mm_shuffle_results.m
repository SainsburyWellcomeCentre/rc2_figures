table_fname = 'mismatch_nov20_shuffle2_table.mat';
load(table_fname);

probe_fnames = unique(T.probe_name);
protocols = {'CoupledMismatch', 'CoupledMismatch', 'EncoderOnlyMismatch', 'EncoderOnlyMismatch'};
gain_dir = {'down', 'up', 'down', 'up'};
title_str = {{'V+T+M', '(gain down)'}, {'V+T+M', '(gain up)'}, {'V+T', '(gain down)'}, {'V+T', '(gain up)'}};
N_PROT = length(protocols);

save_dir = 'C:\Users\Lee\Desktop\Desktop\mvelez\mismatch_nov20_response\mm_shuffle2';
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
            
            idx = find(strcmp(T.probe_name, probe_fnames{probe_i}) & ...
                T.cluster_id == cluster_ids(cluster_i) & ...
                strcmp(T.protocol, protocols{prot_i}) & ...
                strcmp(T.gain_direction, gain_dir{prot_i}), 1, 'first');
            
            assert(length(idx) == 1);
                        
            h_ax(prot_i) = subplot(2, 2, prot_i);
            
            hold on;
            
            for wind_i = 1 : 4
                if (T.real_fr{idx}(wind_i) > T.shuff_fr_up{idx}(wind_i)) | ...
                        (T.real_fr{idx}(wind_i) < T.shuff_fr_down{idx}(wind_i))
                    col = [0.8500    0.3250    0.0980];
                else
                    col = 'k';
                end
                fill(1e3*[(wind_i-1)*0.1, wind_i*0.1, wind_i*0.1, (wind_i-1)*0.1], ...
                    [0, 0, T.real_fr{idx}([wind_i, wind_i])], col);
                line(1e3*0.1*[wind_i-1, wind_i], T.shuff_fr_mean{idx}([wind_i, wind_i]), ....
                    'color', 'k');
                line(1e3*0.1*[wind_i-1, wind_i], T.shuff_fr_up{idx}([wind_i, wind_i]), ....
                    'color', [0.5, 0.5, 0.5]);
                line(1e3*0.1*[wind_i-1, wind_i], T.shuff_fr_down{idx}([wind_i, wind_i]), ....
                    'color', [0.5, 0.5, 0.5]);
                 
            end
            
%             plot((0:3999)/10e3, T.shuff_psth_mean{idx}, 'k');
%             plot((0:3999)/10e3, T.shuff_psth_up{idx}, 'color', [0.5, 0.5, 0.5]);
%             plot((0:3999)/10e3, T.shuff_psth_down{idx}, 'color', [0.5, 0.5, 0.5]);
%             plot((0:3999)/10e3, T.real_psth{idx}, 'r');
            
            h = title(title_str{prot_i});
            if any((T.real_fr{idx} > T.shuff_fr_up{idx})) | any((T.real_fr{idx} < T.shuff_fr_down{idx}))
                set(h, 'color', 'r');
                if is_cortical
                    n_sig(prot_i, probe_i) = n_sig(prot_i, probe_i) + 1;
                end
            end
            
            set(gca, 'plotboxaspectratio', [3, 1, 1]);
            
            yL = max(yL, max(get(gca, 'ylim')));
            
        end
        
        for prot_i = 1 : N_PROT
            set(gcf, 'currentaxes', h_ax(1, prot_i));
            set(h_ax(1, prot_i), 'ylim', [0, yL]);
            line([0, 0], [0, yL], 'color', 'k');
%             line([200, 200], [0, yL], 'color', 'k');
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


