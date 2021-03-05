function T = gather_stationary_vs_motion_table(probe_fnames, table_dir)

T = table();

% for each recording
for probe_i = 1 : length(probe_fnames)
    
    table_fname = fullfile(table_dir, sprintf('%s_stationary_vs_motion_table.mat', probe_fnames{probe_i}));
    temp = load(table_fname, 'T');
    T = [T; temp.T];
end

% restrict table to cortical clusters
is_cortical = ismember(T.cluster_region, {'VISp1', 'VISp2/3', 'VISp4', 'VISp5', 'VISp6a', 'VISp6b', 'VISpX'});
T(~is_cortical, :) = [];
