% compare responses between all conditions
input('sure?')
clear all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% name of the probe recordings to analyze
probe_fnames = {'CA_176_1', ...
                'CA_176_3', ...
                'CAA-1112416', ...
                'CAA-1112417', ...
                'CAA-1110262', ...
                'CAA-1110264', ...
                'CAA-1110265_restricted', ...
                'CAA-1112224', ...
                'CAA-1112529', ...
                'CAA-1112530', ...
                'CAA-1112531', ...
                'CAA-1112532', ...
             };

formatted_dir = 'C:\Users\Lee\Documents\mvelez\data\formatted_data';

% location to save the table of stationary/motion values
save_dir = 'C:\Users\Lee\Documents\mvelez\data\tables\stationary_vs_motion';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CALCULATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for printing progress
pp = PrintProgress();

% for each recording
for probe_i = 1 : length(probe_fnames)
    
    % print progress
    pp.print('Recording', probe_i, length(probe_fnames));
    
    subdir_contents = dir(fullfile(formatted_dir, [probe_fnames{probe_i}, '*']));
    assert(length(subdir_contents) == 1);
    formatted_fname = fullfile(formatted_dir, subdir_contents.name);
    probe_basename = regexprep(subdir_contents.name, '.mat', '');
    
    % compute the table of stationary/motion values
%     T = stationary_vs_motion_table(formatted_fname);
    
    % save
    save_fname = sprintf('%s_stationary_vs_motion_table.mat', probe_basename);
    save_fname = fullfile(save_dir, save_fname);
    
    
    load(save_fname, 'T');
    load(formatted_fname, 'clusters');
    
    for table_i = 1 : size(T, 1)
        
        this_id = T.cluster_id(table_i);
        
        c = get_cluster_by_id(clusters, this_id);
        
        T.duration(table_i) = c.duration;
    end
    
    save(save_fname, '-append', 'T');
    
end
