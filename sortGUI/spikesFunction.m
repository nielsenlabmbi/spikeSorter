function spikesFunction(JobID)
% SPIKESFUNCTION computes spike waveforms and waveform properties.

% If no isBR in experiment file then set to 0
isBR = 0;

load('experiment.mat')
Properties=[];
shankNum=shankNum(CHs);
if ~isBR
    
    fileinfo = dir([experiment '/' experiment '_amplifier.dat']);
    samples = fileinfo.bytes/(2*length(CHs)); % Number of samples in amplifier data file
    samplesPerJob = ceil(samples/200); % Number of samples to allocate to each of the 200 jobs
    firstSample = samplesPerJob*JobID - 60; % Sets first sample to process; each job has 1st 30 samples overlap with previous job and last 30 samples overlap with next job

    if firstSample<0
        firstSample=0;
    end

    File = [experiment '/' experiment '_amplifier.dat'];
    DataFile = fopen(File,'r'); % Load amplifier data
    fseek(DataFile,2*length(CHs)*firstSample,'bof'); % Offset from beginning of file
    
    if JobID == 199 % The last job - first JobID is 0
        samplesLeft = samples - samplesPerJob*199 + 60; % samplesLeft=TotalSamples-SamplesDone+Overhang
        Data = fread(DataFile, [length(CHs) samplesLeft], 'int16'); % If JobID is the last job, read all the samples left
    else
        Data = fread(DataFile, [length(CHs) samplesPerJob], 'int16'); % If JobID isn't the last job, read samplesPerJob samples past the file position set by fseek
    end

else
    addpath(genpath('NPMK'));

    Data = openNSx([experiment '/' experiment '.ns6'],'t:1:2');
    samples = Data.MetaTags.DataPoints; % Number of samples in .ns6 file
    samplesPerJob = ceil(samples/200); % Number of samples to allocate to each of the 200 jobs
    firstSample = samplesPerJob*JobID - 60; % First sample to process for job JobID
    
    if firstSample<1
        firstSample=1;
    end

    if JobID == 199 % If this is the last job
        Data = openNSx([experiment '/' experiment '.ns6'],['t:' num2str(firstSample) ':' num2str(samples)]); % Read from this job's first sample to the end of the file
    else
        Data = openNSx([experiment '/' experiment '.ns6'],['t:' num2str(firstSample) ':' num2str(firstSample+samplesPerJob-1)]); % Read from this job's first sample to samplesPerJob samples past that
    end
    Data = Data.Data;

end

% Filter and normalize to threshold
for i = 1:length(CHs) % For every channel
    Data(i,:) = filter(b1, a1, double(Data(i,:))); % Filter data for this job using filter coefficients from experiment.mat
end
Data = Data(CHs,:); % Order data by channel depth
Data = Data(~BadCh(CHs),:); % Only include data from good channels
Data=double(Data); % Convert data from int16 to double
numChs = sum(~BadCh); % Number of good channels

for i = 1:numChs
    Data(i,:) = Data(i,:)./abs(Th(i)); % Normalize each channel to threshold from experiment.mat to determine which data points are above and below threshold
end

TimeStamps = [];
Amps = [];
Width = [];
Amplitude = [];
Energy = [];
pos = [];
with = [];
Ch = [];
x_cm = [];
y_cm = [];
x_detected = [];
y_detected = [];
shank=[];
AboveTh = Data>-1; % If Data<-1 after normalization, voltage doesn't pass threshold to be counted as a spike

% After calculating AboveTh un-normalize data
for i = 1:numChs
    Data(i,:) = Data(i,:).*abs(Th(i));
end

minData = [zeros(4,length(Data(1,:)));Data;zeros(4,length(Data(1,:)))]; % Initialize minData with buffers of zeros above and below Data so top and bottom channels aren't compared to each other

% for i = [1 2 4 8 15] % Circshift sizes to use: Shift 1 away from original, then 3, 7, 15, 30
for i = [1 2 4 8 5] % Circshift sizes to use: Shift 1 away from original, then 3, 7, 15, 20
    minData = min(circshift(minData,[0 i]),minData); % Find minimum voltage in a 21 timepoint window
end
% minData = circshift(minData,[0 -15]); % Centers the 31 timepoint window on the timepoint where the minimum originally occurred
minData = circshift(minData,[0 -10]); % Centers the 21 timepoint window on the timepoint where the minimum originally occurred
for i = [1 2 4 1] % Shift 1, 3, 7, 8
    minData = min(circshift(minData,[i 0]),minData); % Find minimum voltage in a 9 channel window
end
minData = circshift(minData,[-4 0]); % Centers the 9 channel window on the channel where the minimum originally occurred
minData = minData(5:end-4,:); % Removes the buffer of zeros
CrossTh = AboveTh & circshift(~AboveTh,[0 -1]); % Matrix of threshold crossings, same size as Data
for i = [1 2 4 2] % Shift 1, 3, 7, 9
    CrossTh = CrossTh | circshift(CrossTh,[0 i]); % Find all samples that are threshold crossings or within 10 timepoints after a threshold crossing
end

% Make sure there is no repeted value of max during artificial refractory
% period (necessary for BR due to lower bit depth)
RepetedMax = zeros(length(Data(:,1)),length(Data(1,:)));

% Is the first max in 10 samples across neighbor channels
for ch = -4:4 % channel window
    for sm = -10:-1 % sample window
        RepetedMax = RepetedMax | Data == circshift(Data,[ch sm]);
    end
end

% Is the first max at that sample across neighbor channels
% Marks repeated maximum values after the first instance of that value
for ch = 1:4
    RepetedMax = RepetedMax | Data == circshift(Data,[ch 0]);
end

Spikes = CrossTh & minData==Data & ~RepetedMax; % Boolean array; spikes are counted when they are within 10 samples of a threshold crossing and are a minimum value within 21 samples and are the first instance of that minmum value
Spikes(:,1:30)=0; % Removes the 30 sample overlap at the beginning of each job
Spikes(:,end-30:end)=0; % Removes the 30 sample overlap at the end of each job

%% Find the channel(s) where the shank number changes (other than channel 1)
shankShift=circshift(shankNum,1);
shankStart=find(shankNum(1:end)~=shankShift(1:end)); % Index of first channel after each shank change
shankStart(end+1)=numChs+1;

%%
for i = 1:numChs % For every channel
    shankInd=find(shankStart<=i,1,'last'); % Find which shank channel i is on
    Wvfrms=[]; % Initializes waveform
    Times = find(Spikes(i,:)>0); % Find coordinates where spikes occurred
    TimeStamps =[TimeStamps Times+firstSample]; % Get timestamps of these spikes
    for dt = -15:25 % At timeshifts of dt from spike timestamps
        Wvfrms(:,:,dt+16) = Data(max(i-4,shankStart(shankInd)):min(shankStart(shankInd+1)-1,i+4),Times+dt);
    end
    if not(isempty(Wvfrms))
        Wvfrms = Wvfrms - repmat(mean(Wvfrms(:,:,1:5),3),[1 1 length(Wvfrms(1,1,:))]); % Normalizes waveform by subtracting baseline; takes mean across entire time window of waveform before peak, subtracts from every waveform
        En = sum(Wvfrms.^2,3); % Calculates waveform energy for the waveform on each channel of each spike; spikes are dimension 2, channels dimension 1, times dimension 3
        Mn = squeeze(Wvfrms(:,:,16)); % Normalized waveform at peak of spike, when dt=0
    else
        Wvfrms=[];
        En=[];
        Mn=[];
    end

    % Get max and max pos as first peak of waveform after min
    Mx=[];
    if ~isempty(Wvfrms)
        for TheCh = 1:length(Wvfrms(:,1,1)) % For each of the channels spanned by Wvfrms
            if ~isempty(Wvfrms)
                redWvrm = squeeze(Wvfrms(TheCh,:,16:end)); % Only need iterations of Wvfrm after the spike's negative peak; also squeeze to 2 dimensions, #samples by #timeshifts dt
                if length(Wvfrms(1,:,1))==1 % If there's only one sample, squeeze will make the third dimension of Wvfrms the first instead of the second dimension of redWvrm
                    redWvrm = redWvrm'; % Correct redWvrm's dimensions
                end
                dWvrm = redWvrm - circshift(redWvrm,[0 1]); % From each element of redWvrm, subtract the element before it in its row
                dWvrm(:,end) = []; % The end value is the difference between samples that aren't adjacent in time - remove it
                dWvrm(dWvrm==0) = dWvrm(circshift(dWvrm,[0 -1])==0); % For any sample with no difference between it (i) and the previous (i-1), substitute the difference between (i-1) and and (i-2)
                dWvrm = dWvrm./abs(dWvrm); % dWvrm only contains sign of change, not magnitude
                dWvrm = dWvrm - circshift(dWvrm,[0 1]); % dWvrm is change in sign of change
                dWvrm(:,end) = [];
                dWvrm = circshift(dWvrm,[0 -1]);
                dWvrm(:,1) = 0;
                [~, MxPos] = min(dWvrm,[],2); % MxPos contains times of spike positive peaks
                Mx(TheCh,:) = redWvrm((MxPos-1).*length(dWvrm(:,1)) + [1:1:length(dWvrm(:,1))]')'; % Mx contains the values at those peaks
            else
                Mx=[];
                MxPos = [];
            end
        end

        Mn = [zeros(max(0,shankStart(shankInd)+4-i),length(Mn(1,:)));Mn; zeros(max(0,i-(shankStart(shankInd+1)-5)),length(Mn(1,:)))];
        Mx = [zeros(max(0,shankStart(shankInd)+4-i),length(Mx(1,:)));Mx; zeros(max(0,i-(shankStart(shankInd+1)-5)),length(Mx(1,:)))];

        Pks = Mx-Mn; % Spike amplitude peak to peak
        Amps =[Amps Pks]; % Amp(-4 to +4)
        Amplitude = [Amplitude Mn(5,:)]; % Amp(0) at the channel of detection
        Width =[Width MxPos'-1]; % Waveform width
        Energy =[Energy En(5,:)]; % Waveform energy at the channel of detection
        Ch(end+1:end+length(Times)) = i; % CH detected
        Mn(Mn>0)=0;
        pos = [pos i+(sum(Mn.*(repmat([-4:1:4]',1,length(Mn(1,:)))),1)./sum(Mn,1))]; % CH Pos, center of mass
        with = [with (Mn(5,:)./sum(Mn,1))]; % CHs width
        
        x_surround=xPosition(max(i-4,shankStart(shankInd)):min(shankStart(shankInd+1)-1,i+4)); % x positions of the surrounding channels
        y_surround=yPosition(max(i-4,shankStart(shankInd)):min(shankStart(shankInd+1)-1,i+4)); % y positions of the surrounding channels

        x_detected(end+1:end+length(Times))=xPosition(CHs==i);
        y_detected(end+1:end+length(Times))=yPosition(CHs==i);

        x_cm = [x_cm sum(En.*repmat(x_surround,1,size(En,2)),1)./sum(En,1)]; % calculate x center of mass
        y_cm = [y_cm sum(En.*repmat(y_surround,1,size(En,2)),1)./sum(En,1)]; % calculate y center of mass

        shank(end+1:end+length(Times))=shankNum(i);

    end
end

Properties = [Amps;Amplitude;Energy;Width;with;pos;TimeStamps;Ch;x_detected;y_detected;x_cm;y_cm;shank];
save([experiment '/SpikeFiles/Spikes_' num2str(JobID) '.mat'],'Properties')
fclose all;