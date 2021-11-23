function print_unity_plot_stats(x_medians, y_medians, direction, spike_class)

responsive_idx  = abs(direction) == 1;
increase_idx    = direction == 1;
decrease_idx    = direction == -1;

n_responsive    = sum(responsive_idx);
n_increase      = sum(increase_idx);
n_decrease      = sum(decrease_idx);

n_total         = length(direction);

prc_responsive  = 100 * n_responsive / n_total;
n_nan           = sum(isnan(x_medians) | isnan(y_medians));

pop_fr_stationary           = median(x_medians);
pop_fr_stationary_q         = prctile(x_medians, [25, 75]);

pop_fr_motion               = median(y_medians);
pop_fr_motion_q             = prctile(y_medians, [25, 75]);

pop_fr_delta                = median(y_medians - x_medians);
pop_fr_delta_q              = prctile(y_medians - x_medians, [25, 75]);

pop_fr_increase_delta       = median(y_medians(increase_idx) - x_medians(increase_idx));
pop_fr_increase_delta_q     = prctile(y_medians(increase_idx) - x_medians(increase_idx), [25, 75]);

pop_fr_decrease_delta       = median(y_medians(decrease_idx) - x_medians(decrease_idx));
pop_fr_decrease_delta_q     = prctile(y_medians(decrease_idx) - x_medians(decrease_idx), [25, 75]);


% 1. Responsiveness
fprintf(' # responsive %.2f%% (%i/%i)\n', prc_responsive, n_responsive, n_total);
fprintf('  # nan %i\n', n_nan);
fprintf(' # increase: %i/%i\n', n_increase, n_total);
fprintf(' # decrease: %i/%i\n', n_decrease, n_total);

% 2. Firing rates
fprintf(' Population FR delta:      %.2f Hz, Q1 = %.2f Hz, Q2 = %.2f Hz\n', pop_fr_delta, pop_fr_delta_q(1), pop_fr_delta_q(2));
fprintf(' Population FR X: %.2f Hz, Q1 = %.2f Hz, Q2 = %.2f Hz\n', pop_fr_stationary, pop_fr_stationary_q(1), pop_fr_stationary_q(2));
fprintf(' Population FR Y:     %.2f Hz, Q1 = %.2f Hz, Q2 = %.2f Hz\n', pop_fr_motion, pop_fr_motion_q(1), pop_fr_motion_q(2));

fprintf(' Increase units, FR change: %.2f Hz, Q1 = %.2f Hz, Q2 = %.2f Hz (n=%i)\n', pop_fr_increase_delta, pop_fr_increase_delta_q(1), pop_fr_increase_delta_q(2), n_increase);
fprintf(' Decrease units, FR change: %.2f Hz, Q1 = %.2f Hz, Q2 = %.2f Hz (n=%i)\n', pop_fr_decrease_delta, pop_fr_decrease_delta_q(1), pop_fr_decrease_delta_q(2), n_decrease);


p_val = signrank(x_medians, y_medians);

fprintf('Sign-rank X vs. Y; p = %.2e, n = %i\n', p_val, length(x_medians));


%% Test differences between spike classes

fprintf('\n\n\nWIDE vs. NARROW spiking\n');
fprintf('-----------------------\n');

% 1. Proportions of responsive units
narrow_idx  = strcmp(spike_class, 'narrow');
wide_idx    = strcmp(spike_class, 'wide');

n_narrow    = sum(narrow_idx);
n_wide      = sum(wide_idx);

n_responsive_narrow = sum(responsive_idx(narrow_idx));
n_responsive_wide   = sum(responsive_idx(wide_idx));

[~, p_val_responsiveness] = fishertest([n_responsive_wide,    n_wide - n_responsive_wide;
                                        n_responsive_narrow,  n_narrow - n_responsive_narrow]);

fprintf('Narrow spike responsiveness: %.2f%% (%i/%i)\n', 100*n_responsive_narrow/n_narrow, n_responsive_narrow, n_narrow);
fprintf('Wide spike responsiveness: %.2f%% (%i/%i)\n', 100*n_responsive_wide/n_wide, n_responsive_wide, n_wide);
print_significance('   Fisher exact test', p_val_responsiveness);

                                    
% 2. Firing rate distributions              
x_med_narrow    = x_medians(narrow_idx);
x_med_wide      = x_medians(wide_idx);
y_med_narrow    = y_medians(narrow_idx);
y_med_wide      = y_medians(wide_idx);
delta_narrow    = y_medians(narrow_idx) - x_medians(narrow_idx);
delta_wide      = y_medians(wide_idx) - x_medians(wide_idx);

p_val_x_med     = ranksum(x_med_narrow, x_med_wide);
p_val_y_med     = ranksum(y_med_narrow, y_med_wide);
p_val_delta     = ranksum(delta_narrow, delta_wide);

print_significance('   Rank-sum on FR, X', p_val_x_med);
print_significance('   Rank-sum on FR, Y', p_val_y_med);
print_significance('   Rank-sum on FR, delta', p_val_delta);



function print_significance(base_msg, p_val)
if p_val < 0.05
    fprintf('%s, p = %.2e, SIGNIFICANT\n', base_msg, p_val);
else
    fprintf('%s, p = %.2f, NOT SIGNIFICANT\n', base_msg, p_val);
end

