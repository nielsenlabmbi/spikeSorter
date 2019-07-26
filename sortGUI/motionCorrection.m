% function motionCorrection(nTimeBins,nSpaceBins,maxlag)
% Get matrix with times and positions of spike centers marked
nTimeBins=200;
nSpaceBins=32;
maxlag=200;
load([fileparts(mfilename('fullpath')) '\Settings']) % will already be loaded in sortGUI

[FileName,PathName,~] = uigetfile([expFolder '\*.mat']); % will also already be loaded
load([PathName FileName])

%% Cross-correlation method

% Specify spatial and temporal bin boundaries
sampleBound=linspace(min(Properties(15,:)),max(Properties(15,:)),nTimeBins); % first sample in each time bin
yBound=linspace(min(Properties(20,:)),max(Properties(20,:)),nSpaceBins); % first channel in each time bin
binArea=mean(diff(sampleBound))*mean(diff(yBound));
spikeDensity=[];

% Get matrix of spike density over space and time
for i=1:numel(sampleBound)-1 %   For every time bin
    timeBin=[];
    spaceBin=[];
    for j=1:numel(yBound)-1 %  For every channel bin
%       Count the spikes in all spatial bins
        timeBin=Properties(15,:)<sampleBound(i+1) & Properties(15,:)>=sampleBound(i);
        spaceBin=Properties(20,:)<yBound(j+1) & Properties(20,:)>=yBound(j);
        spikeCount=numel(Properties(:,spaceBin & timeBin));
%       Divide spike count by size of the bin
        if ~isempty(Properties(:,spaceBin & timeBin))
            spikeDensity(j,i)=spikeCount/binArea;
        else
            spikeDensity(j,i)=0;
        end
    end
%       Append new spike density vector to matrix
end %   Iterate and repeat

% Cross-correlation between each column (with different spatial shifts
% applied) and the one before it
%   Choose shifts to apply
shifts=1:(maxlag*2);
%   For every column of the spike density matrix
bestShift(1)=0;
for dt=2:nTimeBins-1
    lagInd=[];
    [corr, lags]=xcorr(spikeDensity(:,dt-1),spikeDensity(:,dt));
    
%   Get index of the shift that maximizes cross-correlation
%   Save this shift to apply later to all spikes in this time bin
    [~, lagInd]=max(corr);
    bestShift(dt)=lags(lagInd)*mean(diff(yBound));
%   Iterate and repeat
end

% Get corrected y positions
for time=1:numel(sampleBound)-1
    timeBin=Properties(15,:)<sampleBound(time+1) & Properties(15,:)>=sampleBound(time);
    yCorrected(timeBin)=Properties(20,timeBin)+sum(bestShift(1:time));
end

%% Preview corrected y position
x_cm=19;
y_cm=20;
val=15;
figure(1)
scatter3(Properties(val,:),Properties(x_cm,:),yCorrected,'Marker','.','SizeData',1,'CData',[0 0 0])
title('Corrected')
figure(2)
scatter3(Properties(val,:),Properties(x_cm,:),Properties(y_cm,:),'Marker','.','SizeData',1,'CData',[0 0 0])
title('Uncorrected')
%% Apply - save corrected y position as a new property to plot
% Properties(20,:)=yCorrected;
% disp('Done!')
% end