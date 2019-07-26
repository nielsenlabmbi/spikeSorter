function makeExperimentFile
% Makes an experiment file for the selected experiment based on
% customizable probe configurations

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
                xPos{2}=configs.(probe{2}).xPosition+str2num(offset{1});
                yPos{2}=configs.(probe{2}).yPosition;
                shank{2}=configs.(probe{2}).shankNum+numel(unique(configs.(probe{1}).shankNum));
            else
                disp('Probe 2 configuration entered does not exist. Check spelling or use buildConfigStructure.m to add it to saved configurations.')
            end

            probeToSort = inputdlg('Select probe to sort: ');
            switch probeToSort{1}
                    case '1'
                    Bad{2} = ones(1,str2num(probeType{2}(numerInd{2})));
                    case '2'
                    Bad{1} = ones(1,str2num(probeType{1}(numerInd{1})));
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

    mkdir([expFolder '/' experiment '/'],'SpikeFiles')
    % If is not BR get smaple rate from info file and load .dat
    if ~(isBR)
        sampleFrq = getSampleFreqFromInfoFile([expFolder '/' experiment '/' experiment '_info.rhd']);
        File = [expFolder '/' experiment '/' experiment '_amplifier.dat']; % Path to voltage data
        DataFile = fopen(File,'r'); % Opens voltage data file for reading
        Data = fread(DataFile, [length(BadCh) sampleFrq*30], 'int16'); % reads first 30 seconds of voltage data for all channels

    % If it is BR then open NSx
    else
        sampleFrq = 30000;
        disp([expFolder '/' experiment '/' experiment '.ns6'])
        Data = openNSx([expFolder '/' experiment '/' experiment '.ns6'],['t:1:' num2str(sampleFrq*30)]); % loads first 30 seconds of voltage data for all channels    
        Data = Data.Data;
    end

    [b1, a1] = butter(3, [highPass/sampleFrq,lowPass/sampleFrq]*2, 'bandpass'); % calculates filter coefficients to bandpass filter voltage data according to highPass and lowPass frequencies in which file?

    dataWindow = figure('pos',[60 450 750 500]); % initializes figure to do thresholding in
    Th = ones(length(BadCh),1).*(-200); % default threshold value

    for i = 1:length(CHs) % For every channel
        Done = BadCh(i); % Logic vector stating whether evaluation of each channel is done
        while not(Done)
            Data(i,:) = filter(b1, a1, double(Data(i,:))); % applies previously calculated bandpass filter to voltage data
            figure(dataWindow)
            plot(Data(i,:))%1:sampleFrq*2)) % Displays data
            set(gca,'YLim',[Th(i)*2 -Th(i)*2])
            hold on; 
%             hold on; plot([0 sampleFrq*2],[Th(i) Th(i)],'r');hold off; % Displays line showing where threshold is
            hold on; plot([0 size(Data,2)],[Th(i) Th(i)],'r');hold off; % Displays line showing where threshold is
            option = questdlg('',['Ch: ' num2str(i)],'Good','Bad','Change Th','Good');
            switch option
                case 'Good'
                    Done = 1; % If good, mark channel as done
                case 'Bad'
                    BadCh(i) = 1; % Mark this channel as bad
                    Done = 1; % If bad, mark channel as done
                case 'Change Th'
                    thInp = inputdlg('Enter new threshold: '); % If threshold needs to be changed, ask user for new threshold
                    Th(i) = eval(thInp{1}); % Update threshold for this channel to value entered by user
            end
            Th(i+1)=Th(i); % For next channel, initial threshold = last threshold used for current channel
        end % Repeat until threshold is satisfactory
    end
    Th=Th(~BadCh); % Remove threshold values for bad channels
    
    save([expFolder '/' experiment '/experiment.mat'],'experiment','Th','BadCh','CHs','b1','a1','isBR','xPosition','yPosition','shankNum');
end