function benchmarkTestAnalysis
% Calculates true positive, false positive, and false negative rates for
% clustering of the hybrid ground truth dataset

% Load sorted spikes. How to keep track of true cluster assignments of
% sorted hybrid ground truth spikes? Add a row to idk? Make a ground truth
% idk and save it separately? Option 2 seems like the best way to go

% For every cluster i
% Get indices clusterSpikeInds of all spikes assigned to that cluster

% Get ground truth cluster assignment trueCluster of the majority of the
% hybrid spikes assigned to cluster i

% Count number of trueCluster spikes assigned to cluster i, number of
% trueCluster spikes not assigned to cluster i, and number of spikes not in
% trueCluster assigned to cluster i

% Calculate rates of correctly assigning trueCluster spikes to cluster i,
% incorrectly assigning non-trueCluster spikes to cluster i, and
% incorrectly assigning trueCluster spikes to clusters other than cluster i

% Calculate L-ratio and isolation distance for cluster i and trueCluster
end