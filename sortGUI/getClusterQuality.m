% function [LRATIO,ISODIST]=getClusterQuality
% GETCLUSTERQUALITY calculates L-ratio and isolation distance for sorted
% spike clusters.
%   [LRATIO,ISODIST]=GETCLUSTERQUALITY returns L-ratio and
%   isolation distance for all clusters identified in the file at FILEPATH.

% Load spikes file
tic
load([fileparts(mfilename('fullpath')) '\Settings'])
[FileName,PathName,~] = uigetfile([expFolder '\*.mat']);
load([PathName FileName])

% Specify # degrees of freedom, df
prompt={'Enter number of features:','Enter number of channels:'};
title='Degrees of freedom';
dims=1;
defaults={'16','64'};
entry=inputdlg(prompt,title, dims,defaults);
nFeatures=str2num(entry{1});
nChannels=str2num(entry{2});
df=nFeatures*nChannels; % Is this even right?
% Get ID numbers of all clusters in the spikes file
clusters=unique(idk);

% For every cluster C
D_squared_exCluster=cell(length(clusters));
    for C=1:clusters(end) % Skip cluster 0, since it's the unsorted/noise cluster
        % Calculate L-ratio - see N. Schmitzer-Torbert et al., Neuroscience 131 (2005) 
        % Get number of spikes in cluster
        spikeCount=length(idk==C);
        exFeaturesCell={};
        % Get vector of features of extra-cluster spikes, feature means,
        % and precision matrix
        exClusterSpikes=find(idk~=C); % Indices of all extra-cluster spikes
        exFeatures=Properties(:,exClusterSpikes); % Waveform features of extra-cluster spikes
        inFeatures=Properties(:,idk==C); % Waveform features of in-cluster spikes
        % For every extra-cluster spike j not in C
        
        exFeaturesCell=mat2cell(exFeatures,size(exFeatures,1),ones(1,size(exFeatures,2)));
        D_squared_exCluster{C}=cell2mat(cellfun(@(x) mahal(x',inFeatures'),exFeaturesCell,'UniformOutput',false)); % Getting NaNs in this, exclude them later
        D2_chi2_cdf=chi2cdf(D_squared_exCluster{C},df);
        % Calculate L for all spikes not in cluster C
        L(C)=nansum(1-D2_chi2_cdf);
        % Calculate L-ratio
        LRATIO(C,1)=L(C)/spikeCount;

        % Calculate isolation distance
        % If the number of spikes not in C is greater than the number in C
        if length(exClusterSpikes)>spikeCount
            % Get index of numSpikes-th closest spike not in the cluster
            [~,sortOrder]=sort(D_squared_exCluster{C}(:,1));
            isolationInd=sortOrder(spikeCount);
            % Get Mahalanobis distance of that spike from the center of
            % cluster C
            ISODIST(C,1)=D_squared_exCluster{C}(isolationInd,1);
        else
            ISODIST(C,1)=NaN;
        end
    end
    disp(['Done! Elapsed time is ' num2str(toc/60) ' minutes.'])
% end