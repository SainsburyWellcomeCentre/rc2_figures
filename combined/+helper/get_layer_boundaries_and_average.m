function boundaries = get_layer_boundaries_and_average(probe_fnames, formatted_dir)

warning('off', 'MATLAB:table:RowsAddedExistingVars');
boundaries = table();
r = 0;

layers = {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'};

% for each recording
for probe_i = 1 : length(probe_fnames)
    
    load(fullfile(formatted_dir, probe_fnames{probe_i}), 'anatomy');
    
    for i = 1 : length(anatomy.region_str)
        
        if ~any(strcmp(layers, anatomy.region_str{i}))
            continue
        end
        
        r = r + 1;
        
        this_instance = 1;
        
        if r > 1
            
            idx = strcmp(boundaries.region(1:r-1), anatomy.region_str{i}) & ...
                strcmp(boundaries.region(1:r-1), probe_fnames{probe_i});
            
            if sum(idx) > 0
                this_instance = sum(idx) + 1;
            end    
        end
        
        boundaries.probe_name{r} = probe_fnames{probe_i};
        boundaries.region{r} = anatomy.region_str{i};
        boundaries.upper(r) = anatomy.region_boundaries(i);
        boundaries.lower(r) = anatomy.region_boundaries(i+1);
        boundaries.instance(r) = this_instance;
    end
end




% boundaries = {};
% regions = {};
% 
% % for each recording
% for probe_i = 1 : length(probe_fnames)
%     
%     load(fullfile(formatted_dir, probe_fnames{probe_i}), 'anatomy');
%     
%     % store the boundaries of the layers
%     boundaries{probe_i} = anatomy.region_boundaries;
%     regions{probe_i} = anatomy.region_str;
% end
% 
% % average the boundary positions for these regions
% layers = {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'};
% 
% % preallocate
% % matrix for layers of boundaries (+1 because there is one more boundary
% % than number of layers)
% avg_boundaries = nan(length(layers)+1, length(probe_fname));
% 
% % for each layer
% for layer_i = 1 : length(layers)
%     % for each recording
%     for probe_i = 1 : length(probe_fname)
%         
%         % find the boundary for the layer
%         r_i = find(strcmp(layers{layer_i}, regions{probe_i}));
%         
%         % on the first layer we need above and below, otherwise just below
%         if layer_i == 1
%             avg_boundaries(1, probe_i) = boundaries{probe_i}(r_i);
%             avg_boundaries(2, probe_i) = boundaries{probe_i}(r_i+1);
%         else
%             avg_boundaries(layer_i+1, probe_i) = boundaries{probe_i}(r_i+1);
%         end
%     end
% end
% 
% % average their distances from the probe tip
% avg_boundaries = nanmean(avg_boundaries, 2);
