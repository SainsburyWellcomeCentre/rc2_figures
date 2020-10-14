% compare responses between all conditions
input('sure?')
clear all

import helper.*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% name of the probe recordings to analyze
probe_fnames = {'CAA-1112529_rec1_rec2_rec3', ...
        'CAA-1112530_rec1_rec2_rec3', ...
        'CAA-1112531_rec1_rec2_rec3', ...
        'CAA-1112532_rec1_rec2_rec3'};%     'CAA-1110262_rec1_rec2_rec3', ...

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
    
    % load data for this mouse
    formatted_fname = fullfile(formatted_dir, [probe_fnames{probe_i}, '.mat']);
    
    % compute the table of stationary/motion values
    T = stationary_vs_motion_table(formatted_fname);
    
    % save
    save_fname = sprintf('%s_stationary_vs_motion_table.mat', probe_fnames{probe_i});
    save_fname = fullfile(save_dir, save_fname);
    save(save_fname, 'T');
end
