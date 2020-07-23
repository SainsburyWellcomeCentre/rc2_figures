% Get time to restrict analysis of recording CAA-1110265
%   After passing the entire recording through kilosort, we see that
%   the beginning of this recording was unstable until about 450s.
%   So here we compute the time at which to reanalyze the recording.
%   We find the time after 450s at which a 'batch' of protocols starts, so
%   that we have an equal number of the 6 distinct protocols.

% Prior to this we must format the original recording
%   C:\Users\Lee\Documents\mvelez\rc2_scripts\script_format
% to get the file CAA-1110265_rec1_rec2_rec3.mat.

% load the formatted data
load('CAA-1110265_rec1_rec2_rec3.mat', 'sessions', 't_sync');

% create a session object
session_obj = Session(sessions(1), t_sync{1});

% from observations of the spiking, something happens around this time,
% after which the units are relatively stable
min_time = 450;

% this is the number of protocols we run as a batch (after they have all
% run, these 6 different protocols repeat in a different order)
protocol_batch_size = 6;

% get the start time of each batch
batch_start_times = arrayfun(@(x)(x.probe_t(1)), session_obj.trials(1:protocol_batch_size:end));

% find which of the batches start after the min_time
first_batch_idx = find(batch_start_times > min_time, 1);

% the time of that batch
first_batch_time = batch_start_times(first_batch_idx);

disp(first_batch_time)

% % timebase of the probe recording
% probe_timebase = (0:length(trigger)-1)*(1/30e3);
% 
% % find the (probe) sample point when this batch starts
% batch_start_time_on_probe = find(probe_timebase > first_batch_time, 1);
