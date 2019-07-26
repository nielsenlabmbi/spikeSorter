% Load probe configurations data structure configs from .mat file
cd(uigetdir('C:\Users\nielsenlab\Documents\MATLAB\ephysAnalysis\ProbeSpikes','Browse to directory where configs data structure is saved.'))
load probeConfigurations.mat
% Load settings, specify probe type
load([fileparts(mfilename('fullpath')) '\Settings'])
experiment = inputdlg('Enter experiment name: ');
experiment = experiment{1};
probeType = inputdlg({'Enter probe 1 type (64F,128A,etc..): ','Enter probe 2 type (if none, leave empty):'});
% probeType = probeType{1};
isBR = 0; % BR=Black Rock

probe{1}=['probe_' probeType{1}];
if isfield(configs,probe{1})
    numerInd{1}=isstrprop(probeType{1},'digit');% Indices of nummeric characters in probeType string - the number of channels
    configs.(probe{1})=sortrows(configs.(probe{1}),{'shankNum' 'yPosition'},{'ascend' 'descend'}); % Sort by shank number and channel y position
    Ch{1}=configs.(probe{1}).channelNum';
    Bad{1} = zeros(1,str2num(probeType{1}(numerInd{1})));
    xPos{1}=configs.(probe{1}).xPosition;
    yPos{1}=configs.(probe{1}).yPosition;
    shank{1}=configs.(probe{1}).shankNum;
    if ~isempty(probeType{2}) % If a second probe was used
        numerInd{2}=isstrprop(probeType{1},'digit');% Indices of nummeric characters in probetype string
        offset=inputdlg('Enter probe 2 x offset from probe 1: ');
        probe{2}=['probe_' probeType{2}];
        if isfield(configs,probe{2}) % If there is a probe configuration for the probe type specified
            configs.(probe{2})=sortrows(configs.(probe{2}),{'shankNum' 'yPosition'},{'ascend' 'descend'}); % Sort by shank number and channel y position
            Ch{2}=configs.(probe{2}).channelNum';
            Bad{2} = zeros(1,str2num(probeType{1}(numerInd{2})));
            xPos{2}=configs.(probe{2}).xPosition+offset;
            yPos{2}=configs.(probe{2}).yPosition;
            shank{2}=configs.(probe{2}).shankNum+numel(unique(configs.(probe{1}).shankNum));
        else
            disp('Probe 2 configuration entered does not exist. Check spelling or use buildConfigStructure.m to add it to saved configurations.')
        end

        probeToSort = inputdlg('Select probe to sort: ');
        switch probeToSort{1}
                case '1'
                Bad{2} = ones(1,probeType{2}(numerInd{2}));
                case '2'
                Bad{1} = ones(1,probeType{1}(numerInd{1}));
        end
    else
        Ch{2}=[];
        Bad{2}=[];
        xPos{2}=[];
        yPos{2}=[];
        shank{2}=[];
    end
    CHs=[Ch{1} Ch{2}];
    BadCh=[Bad{1} Bad{2}];
    xPosition=[xPos{1}; xPos{2}];
    yPosition=[yPos{1}; yPos{2}];
    shankNum=[shank{1};shank{2}];
else
    disp('Probe 1 configuration entered does not exist. Check spelling or use buildConfigStructure.m to add it to saved configurations.')
end
    
sampleFrq = getSampleFreqFromInfoFile([expFolder '/' experiment '/' experiment '_info.rhd']);
File = [expFolder '/' experiment '/' experiment '_amplifier.dat']; % Path to voltage data
DataFile = fopen(File,'r'); % Opens voltage data file for reading
Data = fread(DataFile, [length(BadCh) inf], 'int16');
fclose(DataFile);
[b1, a1] = butter(3, [highPass/sampleFrq,lowPass/sampleFrq]*2, 'bandpass');
%%
hybridSet=[];
for j=0:2
    hybrid=makeHybridDataset(j);
    hybridSet=[hybridSet hybrid];
end
i=1;

Data=double(Data);
hybridSet=double(hybridSet);

Data(i,:) = filter(b1, a1, Data(i,:));
hybridSet(i,:) = filter(b1, a1, hybridSet(i,:));

figure;plot(hybridSet(i,:))

figure;plot(Data(i,:))