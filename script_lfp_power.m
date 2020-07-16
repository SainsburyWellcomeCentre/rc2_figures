clear all

% location of LFP recording
animal_id = 'CAA-1110262';
probe_suffix = 'rec1_rec2_rec3';
restrict_batches = true;
batches_to_use = 1;

% Build filename for LFP data...
lf_fname = fullfile('E:\mateoData_probe\janelia_pipeline', animal_id, ...
    sprintf('%s_%s_g0', animal_id, probe_suffix), ...
    sprintf('%s_%s_g0_imec0', animal_id, probe_suffix), ...
    sprintf('%s_%s_g0_t0.imec0.lf.bin', animal_id, probe_suffix));

% KS-dir
ks_dir = fullfile('E:\mateoData_probe\janelia_pipeline', animal_id, 'output', ...
    sprintf('catgt_%s_%s_g0', animal_id, probe_suffix), ...
    sprintf('%s_%s_g0_imec0', animal_id, probe_suffix), ...
    'imec0_ks2');

formatted_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\formatted_data', ...
    sprintf('%s_%s.mat', animal_id, probe_suffix));

track_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\tracks', ...
    sprintf('%s_%s_track.csv', animal_id, probe_suffix));

pd_times_fname = fullfile('C:\Users\Lee\Documents\mvelez\data\photodiode', ...
    sprintf('%s_%s_sftf_times.mat', animal_id, probe_suffix));


% load the times of the photodiode changes
load(pd_times_fname, 'stim_time');

% get the CSD and triggered LFP
% [csd, t, lfp, csd_y, lfp_y] = get_csd_high(lf_fname, stim_time);

% compute the LFP on all channels
[lfp_power, p, channel_list] = get_lfp_power(lf_fname);

% for some mice it is beneficial to restrict the sampling of the LFP
if restrict_batches
    lfp_power = mean(p(:, batches_to_use), 2);
end

% distance from tip of each channel
channel_from_tip = get_channel_distance_from_tip(channel_list);

% take every other channel
lfp_power_plot = lfp_power(1:2:end);
channel_from_tip_plot = channel_from_tip(1:2:end);

% search for the L5 peak
l5_from_tip = search_for_L5(lfp_power_plot, channel_from_tip_plot, 1000);




%% multiunit activity
load(formatted_fname, 'clusters');

% non-noise clusters
idx = [clusters(:).class] == "good";

% distance of non-noise clusters from tip
cluster_dist_from_tip = [clusters(idx).distance_from_probe_tip];


%% PROBE TRACK
[pos, region_id, region_str] = read_track_csv(track_fname);
[boundaries, id, str] = find_layer_boundaries(pos, region_id, region_str);





%% plot
figure('position', [680, 84, 2000, 894]);
h_ax = subplot(1, 2, 1); hold on;
plot(lfp_power_plot, channel_from_tip_plot, 'color', 'k', 'linewidth', 2);
set(gca, 'ylim', [0, 2500])
ylabel('Distance from probe tip (\mum)')
xlabel('Norm. power (500-1250Hz)');
set(gca, 'plotboxaspectratio', [1, 3, 1])
box off
title('LFP power');
line(get(gca, 'xlim'), l5_from_tip*[1, 1], 'color', 'r', 'linestyle', '--');
for i = 1 : length(boundaries)
    line(get(gca, 'xlim'), boundaries(i)*[1, 1], 'color', 'k', 'linestyle', '--');
    if i < length(boundaries)
        y = sum(boundaries([i, i+1]))/2;
        text(max(get(gca, 'xlim')), y, str{i}, 'verticalalignment', 'middle', 'horizontalalignment', 'right');
    end
end

subplot(1, 2, 2); hold on;
histogram(cluster_dist_from_tip, 40, 'orientation', 'horizontal')
set(gca, 'plotboxaspectratio', [1, 3, 1])
set(gca, 'ylim', [0, 2500])
xlabel('# units')
box off
title('MUA')
line(get(gca, 'xlim'), l5_from_tip*[1, 1], 'color', 'r', 'linestyle', '--');
for i = 1 : length(boundaries)
    line(get(gca, 'xlim'), boundaries(i)*[1, 1], 'color', 'k', 'linestyle', '--');
    if i < length(boundaries)
        y = sum(boundaries([i, i+1]))/2;
        text(max(get(gca, 'xlim')), y, str{i}, 'verticalalignment', 'middle', 'horizontalalignment', 'right');
    end
end

% subplot(1, 3, 3); hold on;
% h = imagesc(-csd);
% set(h, 'xdata', t);
% set(h, 'ydata', csd_y);
% xlim(t([1, end]));
% ylim([0, 2500]);
% line([0, 0], get(gca, 'ylim'));
% set(gca, 'ydir', 'normal');
% xlabel('Time (s)')
% ylabel('From tip (um)')
% box off
% line(get(gca, 'xlim'), l5_from_tip*[1, 1], 'color', 'r', 'linestyle', '--');
% axis square
% % title(sprintf('%s, CSD', animal_id), 'interpreter', 'none')
% 
% % stimulus start
% line([0, 0], get(gca, 'ylim'), 'color', 'k')
% 
% for i = 1 : length(lfp_y)
%     plot(t, lfp_y(i) + 0.5*lfp(i, :), 'k', 'linewidth', 0.5)
% end


FigureTitle(gcf, sprintf('%s_%s LFP power', animal_id, probe_suffix));
