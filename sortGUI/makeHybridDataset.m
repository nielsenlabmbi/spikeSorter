function makeHybridDataset(JobID)
% clear
%% MAKEHYBRIDDATASET makes a hybrid ground truth dataset
%   MAKEHYBRIDDATASET(X) generates hybrid data using section X/200 of the
%   original data.
%% Load donor cluster information
dbg=1;

if dbg==0
    load('hybridExperiment.mat')
    load([hybridExperiment filesep 'experiment.mat'])
    load([hybridExperiment filesep donorExperiment '_Spikes']) % directory format will be changed when this function is run from the cluster
elseif dbg==1
    disp(['Starting Job ' num2str(JobID)])
    load([fileparts(mfilename('fullpath')) '\Settings'])
    load('hybridExperiment.mat')
    load([expFolder filesep donorExperiment filesep 'experiment.mat'])
    load([expFolder filesep donorExperiment filesep 'SpikeFiles' filesep donorExperiment '_Spikes']) % directory format will be changed when this function is run from the cluster
end
%% Choose new center channels for spikes
% Find the channel(s) where the shank number changes (other than channel
% 1). Do something to account for possibility of more than two shanks here
% and in spikesFunction.
numChs = numel(CHs); % Number of channels
shankShift=circshift(shankNum,1);
shankStart=find(shankNum(1:end)~=shankShift(1:end)); % Index of first channel after each shank change
shankStart(end+1)=numChs+1;

% Get new order of channels on each shank: all shifted up or down along
% their shank by shiftDist channels. Keep track of channels that are
% shifted off the probe (those channels no longer exist).
oldCenter=1:numel(CHs); % Map channel numbers to channel indices of Data

for shs=1:numel(shankStart)-1 % Mark as NaN the channels not to take any spikes from
    if spatialShift>0
        oldCenter(shankStart(shs):shankStart(shs)+3)=NaN;
    elseif spatialShift<0
        oldCenter(shankStart(shs+1)-4:shankStart(shs+1)-1)=NaN;
    end
end

newCenter=circshift(oldCenter,[0,spatialShift]); % Apply spatial shift
for nshs=1:numel(shankStart)-1
    if spatialShift>0 % If channels shifted deeper, channels shifted off the bottom of a shank (now at the top) are gone
        newCenter(shankStart(nshs):shankStart(nshs)+spatialShift-1)=NaN;
    elseif spatialShift<0 % If channels shifted shallower, channels shifted off the top of a shank (now at the bottom) are gone
        newCenter(shankStart(nshs+1)+spatialShift:shankStart(nshs+1)-1)=NaN;
    end
end

%% Load a section of the donor dataset

if dbg == 0
File = [hybridExperiment filesep donorExperiment '_amplifier.dat']; % File containing amplifier data
elseif dbg==1
File = [expFolder filesep donorExperiment filesep donorExperiment '_amplifier.dat']; % File containing amplifier data
end

fileinfo = dir(File);

samples = fileinfo.bytes/(2*length(CHs)); % Number of samples in amplifier data file
samplesPerJob = ceil(samples/200); % Number of samples to allocate to each of the 200 jobs
firstSample = samplesPerJob*JobID - 60; % Sets first sample to process

if firstSample<0
    firstSample=0;
end

DataFile = fopen(File,'r'); % Open data file
fseek(DataFile,2*length(CHs)*firstSample,'bof'); % Sets file position indicator offset from beginning of file. The 2 is #bytes/number

if JobID == 199 % If this is the last job - first JobID is 0
    samplesLeft = samples - samplesPerJob*199 + 60;
    Data = fread(DataFile, [length(CHs) samplesLeft], 'int16'); % Read all the samples left
else
    Data = fread(DataFile, [length(CHs) samplesPerJob], 'int16'); % Otherwise, read samplesPerJob samples past the file position set by fseek
end
fclose(DataFile);
lastSample=firstSample+size(Data,2)-1;

for n = 1:length(CHs) % For every channel
    Data(n,:) = filter(b1, a1, double(Data(n,:))); % Filter data for this job using filter coefficients from experiment.mat
end
Data = Data(CHs,:); % Order data by channel depth

donorSet=zeros(size(Data)); % Initialize matrix that will hold donor spike waveforms before adding them to the acceptor dataset
baseSet=zeros(size(Data));

Data=double(Data); % Convert data to double

sampleTimes=firstSample:lastSample; % Sample numbers/times (in full dataset) of all samples in subsection Data of the recording
spikeList=[]; % Will hold the final sample indices and channel numbers of the peaks of all donor spikes included in the hybrid dataset

Spikes=zeros(size(Data)); % Initialize logical matrix that will indicate whether a spike was detected at every channel-sample coordinate in Data
originalWvfrms={}; % Initialize cell array that will hold the spatiotemporal waveforms of all spikes centered on each channel

%% Get 41-time-sample, 5-to-9-channel waveforms centered on donor spike
% spatiotemporal peaks, excluding spikes that are shifted off the probe and
% spikes that don't have full-size waveform footprints.

for i = 1:length(CHs) % For every channel index in the original data
    spikeTimes{i}=Properties(15,idk==donorCluster & Properties(16,:)==i); % Get times of all spikes in the donor cluster that are centered on channel i in the original recording
    inRange=find(spikeTimes{i}>=(firstSample+15),1,'first'):find(spikeTimes{i}<=(lastSample-25),1,'last'); % Disregard spikes occuring in the first and last 30 samples, will not have full size temporal footprint
    shankInd=find(shankStart<=i,1,'last'); % Find which shank channel i is on
    
    if ~isempty(spikeTimes{i}(:,inRange)) && ~isnan(i+spatialShift) % If the donor cluster has any spikes on this channel in this range of samples that didn't get shifted off the probe...
        spikeTimes{i}=spikeTimes{i}(:,inRange); % ...Keep only those spikes
        
        sampleInd{i}=[]; % Initialize vector to hold the sample indices in the complete original dataset where spikes occur
        for s=1:size(spikeTimes{i},2) % For every currently relevant spike s...
            sampleInd{i}(s)=find(sampleTimes==spikeTimes{i}(1,s)); % ...Map the timestamps in spikesList to the timestamps in sampleTimes to find the sample index in sampleTimes (and in Data) where spike s is detected
            Spikes(i,sampleInd{i}(s))=1; % Note that a spike occurred at this time on this channel in Data
        end
        
        Times = find(Spikes(i,:)>0); % Get vector of sample indices in Data where spikes occurred on channel i
        Timestamps=Times+firstSample; % Get vector of sample indices in the full dataset (Data is only one part) where spikes occurred on channel i
        
        originalWvfrms{i}=[]; % Initialize spike waveform holder
        
        for dt = -15:25 % At 31 times surrounding times when spikes occur
            originalWvfrms{i}(:,:,dt+16) = Data(max(i-4,shankStart(shankInd)):min(shankStart(shankInd+1)-1,i+4),Times+dt); % Take the voltage data surrounding the spatiotemporal positions of the peaks of all spikes centered on channel i
        end
        originalWvfrms{i} = originalWvfrms{i} - repmat(mean(originalWvfrms{i}(:,:,1:5),3),[1 1 length(originalWvfrms{i}(1,1,:))]); % Normalize waveforms by subtracting the mean
        
        % Stitch together donor waveforms into a single matrix over all times and
        % channels, with spikes in their new positions
        spikeWaveDenoised{i}=[]; % Initialize denoised spike waveform holder
        for spikeInd=1:size(originalWvfrms{i},2) % for every spike spikeInd centered on channel i
            % Assign that spike its new center channel
            % Get waveform of single spike spikeInd out of Wvfrms
            spikeWave=squeeze(originalWvfrms{i}(:,spikeInd,:));

            % Denoise the waveforms by SVD.
            rank=7; % Keep top 7 dimensions of variability
            [U_partial, S_partial, V_partial]=svds(spikeWave,rank);
            denoised=U_partial*S_partial*V_partial';

%             chanRange=max(spikeCent-4,shankStart(shankInd)):min(shankStart(shankInd+1)-1, spikeCent+4); % Spike spatial footprint
            chanRange=max(i-4+spatialShift,shankStart(shankInd)):min(shankStart(shankInd+1)-1, i+4+spatialShift); % Spike spatial footprint
            sampRange=sampleInd{i}(spikeInd)-15:sampleInd{i}(spikeInd)+25; % Spike temporal footprint
            
            % If the spike spatial footprint is too large, trim it
            if spatialShift>0
                % Remove the end overhang
                excess=(size(chanRange,2)+1):size(denoised,1);
                denoised(excess,:)=[];
            elseif spatialShift<0
                % Remove the top overhang
                excess=1:(size(denoised,1)-size(chanRange,2));
                denoised(excess,:)=[];
            end
            
            spikeWaveDenoised{i}(:,spikeInd,:)=denoised;
            donorSet(chanRange,sampRange)=squeeze(spikeWaveDenoised{i}(:,spikeInd,:)); % Insert donor spike spikeInd into donorSet
            baseSet(chanRange,sampRange(1:5))=donorSet(chanRange,sampRange(1:5)); % Use the 5-sample period before each donor spike as baseline to simulate shot noise based on

            stLog=[sampleInd{i}(spikeInd); i+spatialShift]; % Log the timestamp in the full dataset and the new center channel where spike spikeInd occurs
            spikeList=[spikeList stLog];
        end
    else
        spikeTimes{i}=[];
    end
end

%% Generate shot noise traces for all channels in Data
baseFloor=min(baseSet);
baseSet=baseSet-repmat(baseFloor,size(baseSet,1),1);

lambda=repmat(lambda,size(donorSet,1),size(donorSet,2));
acceptorSet=noiseGain*(poissrnd(lambda)+repmat(baseFloor,size(baseSet,1),1));
%% Add donor spike waveforms to the noise traces in the acceptor dataset at 
% the chosen positions
hybridSet=acceptorSet+donorSet;
hybridSet=hybridSet(CHs,:);
%% Write final timestamps and center channels of the hybrid spikes (spikeList) to .mat file
if dbg==0
    save([hybridExperiment filesep 'tomerge' filesep 'spikeList_' num2str(JobID) '.mat'],'spikeList');
elseif dbg==1
    save([expFolder filesep hybridExperiment filesep 'tomerge' filesep 'spikeList_' num2str(JobID) '.mat'],'spikeList');
end
%% Write hybridSet as 16-bit integers to a binary file in column order
hybridSet=int16(hybridSet);
if dbg==0
    binFileID=fopen([hybridExperiment filesep 'tomerge' filesep hybridExperiment '_' num2str(JobID) '.dat'],'w');
elseif dbg==1
    binFileID=fopen([expFolder filesep hybridExperiment filesep 'tomerge' filesep  hybridExperiment '_' num2str(JobID) '.dat'],'w');
    disp(['Job ' num2str(JobID) ' complete'])
end
fwrite(binFileID,hybridSet,'int16');
fclose('all');
end