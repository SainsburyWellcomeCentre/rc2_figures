pd = session_obj.photodiode;
fs = session_obj.fs;
T = session_obj.probe_t;

fc = 8;
[b, a] = butter(3, fc/(fs/2));
pd_filt = filtfilt(b, a, pd);

hold on; plot(20*pd_filt)



%%
idx = find(20*pd_filt(1.2e5:1.22e5) < 3.5, 1);
starts(1) = 1.2e5 + idx - 1;
period = 0.23 * 10e3;

direction = 1;
next_search = starts(1) + period;

while ~isempty(next_search)
    
    if direction == 1
        idx = find(20*pd_filt(next_search:next_search+0.3*10e5) > 3.5, 1);
    else
        idx = find(20*pd_filt(next_search:next_search+0.3*10e5) < 3.5, 1);
    end
    starts(end+1) = next_search + idx - 1;
    next_search = starts(end) + period;
    direction = mod(direction + 1, 2);
end

starts(end) = [];

