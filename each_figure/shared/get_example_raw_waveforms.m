function [rs_waveform, fs_waveform, rs_mean, fs_mean, rs_isis_ms, fs_isis_ms, t, isi_edges] = get_example_raw_waveforms(data, ap, rs_id, fs_id)

prepad = 20;
postpad = 40;

isi_limit = 30; % ms
isi_bin = 0.25; % ms
isi_edges = -isi_limit : isi_bin : isi_limit;

%%
% time base
t = 1e3*(-prepad:postpad)/30e3;

fs_cluster = data.get_cluster_with_id(fs_id);
rs_cluster = data.get_cluster_with_id(rs_id);

fs_waveform = [];
rs_waveform = [];

for i = 1:100
    fs_waveform(end+1, :) = ap.uV_per_bit * double(ap.data(fs_cluster.cluster.peak_channel+1, double(fs_cluster.cluster.spike_sample_point(i)) + (-prepad:postpad)));
end

for i = 1:100
    rs_waveform(end+1, :) = ap.uV_per_bit * double(ap.data(rs_cluster.cluster.peak_channel+1, double(rs_cluster.cluster.spike_sample_point(i)) + (-prepad:postpad)));
end

fs_waveform = fs_waveform';
rs_waveform = rs_waveform';

fs_mean = mean(fs_waveform, 2);
rs_mean = mean(rs_waveform, 2);

fs_waveform = fs_waveform - mean(fs_mean(1:10));
rs_waveform = rs_waveform - mean(rs_mean(1:10));

fs_mean = fs_mean - mean(fs_mean(1:10));
rs_mean = rs_mean - mean(rs_mean(1:10));


%% ISI distributions
rs_isis_ms = isi_values(rs_cluster.spike_times, isi_limit);
fs_isis_ms = isi_values(fs_cluster.spike_times, isi_limit);



function all_isis = isi_values(these_spike_times, isi_limit)

all_isis = [];
n_spikes = length(these_spike_times);
N = min(50000, n_spikes);
I = randperm(n_spikes, N);
these_spike_times = these_spike_times(I);
n_spikes = N;
for i = 1 : n_spikes-1
    idx = these_spike_times - these_spike_times(i) > 0 & ...
        these_spike_times - these_spike_times(i) < isi_limit;
    all_isis = [all_isis; these_spike_times(idx) - these_spike_times(i)];
end
all_isis = 1e3 * [-all_isis, all_isis];
