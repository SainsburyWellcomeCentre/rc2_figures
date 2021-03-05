function avg_boundaries = average_boundaries(boundaries)

r = 0;
avg_boundaries = table();
unique_boundaries = unique(boundaries.region);

for i = 1 : length(unique_boundaries)
    
    idx = strcmp(boundaries.region, unique_boundaries{i});
    
    r = r + 1;
    avg_boundaries.region{r} = unique_boundaries{i};
    avg_boundaries.upper(r) = mean(boundaries.upper(idx));
    avg_boundaries.lower(r) = mean(boundaries.lower(idx));
end
