% Get time to restrict analysis of recording CAA-1112414
%   After passing the entire recording through kilosort, we see that
%   the end of this recording was unstable from about 1800s.
%   So here we compute the time at which to reanalyze the recording.
%   We find the time before 1800s at which a 'batch' of protocols ends, so
%   that we have an equal number of the 4 distinct protocols.

% Prior to this we must format the original recording
%   C:\Users\Lee\Documents\mvelez\rc2_scripts\script_format
% to get the file CAA-1112414_rec1_rec2_rec3.mat.

% load the formatted data
load('CAA-1112414_rec1_rec2_rec3.mat', 'sessions', 't_sync');

% create a session object
session_obj = Session(sessions(1), t_sync{1});

% from observations of the spiking, something happens around this time,
% before which the units are relatively stable
max_time = 1800;

% this is the number of protocols we run as a batch (after they have all
% run, these 4 different protocols repeat in a different order)
protocol_batch_size = 4;

% get the end time of each batch
batch_end_times = arrayfun(@(x)(x.probe_t(end)), session_obj.trials(protocol_batch_size:protocol_batch_size:end));

% find which of the batches ends just before the max_time
last_batch_idx = find(batch_end_times < max_time, 1, 'last');

% the time of that batch
last_batch_time = batch_end_times(last_batch_idx);

disp(last_batch_time)

% % timebase of the probe recording
% probe_timebase = (0:length(trigger)-1)*(1/30e3);
% 
% % find the (probe) sample point when this batch starts
% batch_start_time_on_probe = find(probe_timebase > first_batch_time, 1);
