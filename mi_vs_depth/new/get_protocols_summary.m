function T2 = get_protocols_summary(T, prot_y, prot_x, replay_y, replay_x)

warning('off', 'MATLAB:table:RowsAddedExistingVars');
T2 = table();
r = 0;

probe_fnames = unique(T.probe_name);


for probe_i = 1 : length(probe_fnames)
    probe_i
    this_rec = ismember(T.probe_name, probe_fnames{probe_i});
    cluster_ids = unique(T.cluster_id(this_rec));
    
    for clust_i = 1 : length(cluster_ids)
        
        this_cluster = T.cluster_id == cluster_ids(clust_i);
        this_region = T.cluster_region(find(this_cluster, 1));
        this_distance = T.cluster_from_tip(find(this_cluster, 1));
        
        for prot_i = 1 : length(prot_y)
            
            this_prot_y = ismember(T.protocol, prot_y{prot_i});
            idx_y = this_rec & this_cluster & this_prot_y;
            
            if strcmp(prot_x{prot_i}, 'stationary')
                idx_x = idx_y;
            else    
                this_prot_x = ismember(T.protocol, prot_x{prot_i});
                idx_x = this_rec & this_cluster & this_prot_x;
            end
            
            if ~isempty(replay_y{prot_i})
                replay_of_y = cellfun(@(x)(isequal(x, replay_y{prot_i})), T.replay_of);
                idx_y = idx_y & replay_of_y;
            end
            
            if ~isempty(replay_x{prot_i})
                replay_of_x = cellfun(@(x)(isequal(x, replay_x{prot_i})), T.replay_of);
                idx_x = idx_x & replay_of_x;
            end
            
            rate_y = T.motion_firing_rate(idx_y);
            
            if strcmp(prot_x{prot_i}, 'stationary')
                rate_x = T.stationary_firing_rate(idx_x);
            else
                rate_x = T.motion_firing_rate(idx_x);
            end
            
            M = min(length(rate_x), length(rate_y));
            p = signrank(rate_x(1:M), rate_y(1:M));
            
            fr_x = nanmedian(rate_x(1:M));
            fr_y = nanmedian(rate_y(1:M));
            
            r = r + 1;
            
            T2.probe_name{r} = probe_fnames{probe_i};
            T2.cluster_id(r) = cluster_ids(clust_i);
            T2.cluster_region{r} = this_region;
            T2.cluster_from_tip(r) = this_distance;
            T2.prot_y{r} = prot_y{prot_i};
            T2.replay_y{r} = replay_y{prot_i};
            T2.prot_x{r} = prot_x{prot_i};
            T2.replay_x{r} = replay_x{prot_i};
            T2.fr_y(r) = fr_y;
            T2.fr_x(r) = fr_x;
            T2.p(r) = p;
            T2.N(r) = M;
        end
    end
end
