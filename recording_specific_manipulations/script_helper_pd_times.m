% script for extracting and saving photodiode changes
formatted_fname = 'C:\Users\Lee\Documents\mvelez\data\formatted_data\CAA-1110265_restricted_rec1_rec2_rec3.mat';
save_as = 'CAA-1110265_rec1_rec2_rec3_sftf_times.mat';
stim_type = 'sf_tf';

load(formatted_fname);
session_n = 3;

% create session object
session_obj = Session(sessions(session_n), t_sync{session_n});

pd = session_obj.photodiode;
fs = session_obj.fs;
T = session_obj.probe_t;

fc = 5;
[b, a] = butter(3, fc/(fs/2));
pd_filt = filtfilt(b, a, pd);

figure, plot(pd_filt(1:10:end));
box off
%%
bnd1 = 0.13;
offset = 1000;
white = pd_filt(offset:end) > bnd1;
ups = find(diff(white) == 1) + offset;
downs = find(diff(white) == -1) + offset;


figure, plot(T(1:10:end), pd_filt(1:10:end));
for i = 1 : length(ups)
    line(T(ups(i))*[1, 1], get(gca, 'ylim'), 'color', 'r')
end
for i = 1 : length(downs)
    line(T(downs(i))*[1, 1], get(gca, 'ylim'), 'color', 'g')
end

%%
triggers = sort([downs; ups]);

stim_time = T(triggers(1:end-1));

save(save_as, 'stim_time')