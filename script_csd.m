clear all

% location of LFP recording
animal_id = 'CAA-1110264';
probe_suffix = 'rec1_rec2';

% Build filename for LFP data...
lf_fname = fullfile('E:\mateoData_probe\janelia_pipeline', animal_id, ...
    sprintf('%s_%s_g0', animal_id, probe_suffix), ...
    sprintf('%s_%s_g0_imec0', animal_id, probe_suffix), ...
    sprintf('%s_%s_g0_t0.imec0.lf.bin', animal_id, probe_suffix));

pd_times_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\photodiode', ...
    sprintf('%s_%s_sftf_times.mat', animal_id, probe_suffix));


% load the times of the photodiode changes
load(pd_times_fname, 'stim_time');

% get the CSD and triggered LFP
[csd, t, lfp, csd_y, lfp_y] = get_csd(lf_fname, stim_time);



%%
figure; hold on
h = imagesc(-csd);
set(h, 'xdata', t);
set(h, 'ydata', csd_y);
xlim(t([1, end]));
ylim([0, 2500]);
line([0, 0], get(gca, 'ylim'));
set(gca, 'ydir', 'normal');
xlabel('Time (s)')
ylabel('From tip (um)')
box off
% title(sprintf('%s, CSD', animal_id), 'interpreter', 'none')

% stimulus start
line([0, 0], get(gca, 'ylim'), 'color', 'k')

for i = 1 : length(lfp_y)
    plot(t, lfp_y(i) + 3*lfp(i, :), 'k', 'linewidth', 0.5)
end


%%
figure; hold on
for i = 1 : 10:length(csd_y)
    plot(t, csd_y(i) + csd(i, :)/50, 'k', 'linewidth', 0.5)
end