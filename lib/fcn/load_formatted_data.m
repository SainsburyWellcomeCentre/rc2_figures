function data = load_formatted_data(probe_recording, config)

formatted_data_fname = fullfile(config.formatted_data_dir, [probe_recording, '.mat']);
data = load_data(formatted_data_fname);
data.probe_recording = probe_recording;
data.experiment_type = get_experiment_type(data.sessions(1).id, config);
data = DataController(data, config);



function exp_type = get_experiment_type(probe_recording, config)

rec_table = readtable(fullfile(config.local_data_dir, 'session_list.csv'));
idx = strcmp(rec_table.recording_id, probe_recording);
exp_type = rec_table.short_name{idx};
