function [boundaries, regions, avg_boundaries, layers] = get_layer_boundaries_and_average(probe_fnames, formatted_dir)

boundaries = {};
regions = {};

% for each recording
for probe_i = 1 : length(probe_fnames)
    
    load(fullfile(formatted_dir, probe_fnames{probe_i}), 'anatomy');
    
    % store the boundaries of the layers
    boundaries{probe_i} = anatomy.region_boundaries;
    regions{probe_i} = anatomy.region_str;    
end

% average the boundary positions for these regions
layers = {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b'};

% preallocate
% matrix for layers of boundaries (+1 because there is one more boundary
% than number of layers)
avg_boundaries = nan(length(layers)+1, length(probe_fname));

% for each layer
for layer_i = 1 : length(layers)
    % for each recording
    for probe_i = 1 : length(probe_fname)
        
        % find the boundary for the layer
        r_i = find(strcmp(layers{layer_i}, regions{probe_i}));
        
        % on the first layer we need above and below, otherwise just below
        if layer_i == 1
            avg_boundaries(1, probe_i) = boundaries{probe_i}(r_i);
            avg_boundaries(2, probe_i) = boundaries{probe_i}(r_i+1);
        else
            avg_boundaries(layer_i+1, probe_i) = boundaries{probe_i}(r_i+1);
        end
    end
end

% average their distances from the probe tip
avg_boundaries = nanmean(avg_boundaries, 2);
