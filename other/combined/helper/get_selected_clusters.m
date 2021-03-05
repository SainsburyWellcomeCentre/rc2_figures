function [selected_clusters, fr] = get_selected_clusters(data)

selected_clusters = data.clusters;
idx = ismember([data.clusters(:).id], data.selected_clusters);
selected_clusters(~idx) = [];
