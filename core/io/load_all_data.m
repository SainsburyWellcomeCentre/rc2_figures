function data = load_all_data()

config = config_rc2_analysis();

recording_ids  = get_recording_ids('visual_flow', ...
                                   'mismatch_nov20', ...
                                   'darkness');

for i = 1 : length(recording_ids)
    
    fprintf('Loading %s (%i/%i)\n', recording_ids{i}, i, length(recording_ids));
    fname = fullfile(config.formatted_data_dir, recording_ids{i});
    data(i) = load(fname);
end
