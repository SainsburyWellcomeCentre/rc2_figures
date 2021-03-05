function start_t = match_value_in_trace(trace, window_size, val, err)
% list of indices in trace for which average of 'trace' in window:
%   idx + (0:window_size-1)
% matches val +/- err
% windows will not overlap

% can do using smooth?

start_t = [];
curr_idx = 1;

for i = 1 : (length(trace) - window_size + 1)
    
    curr_val = mean(trace(curr_idx + (0:window_size-1)));
    
    if (curr_val > val - err) && (curr_val < val + err)
        start_t(end+1) = curr_idx;
        curr_idx = curr_idx + window_size;
    else
        curr_idx = curr_idx + 1;
    end
    
    if curr_idx > length(trace) - window_size + 1
        break
    end
end
