function this_data = get_data_for_recording_id(data, recording_id)

d = [data(:).data];
idx = strcmp({d(:).probe_recording}, recording_id);
this_data = data(idx);
