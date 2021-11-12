function this_data = get_data_for_probe_id(data, probe_id)

idx = strcmp({data(:).probe_id}, probe_id);
this_data = data(idx);
