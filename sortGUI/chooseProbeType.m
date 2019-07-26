% User enters probe type
choice=inputdlg('Enter probe type (example: 64F) ','Probe selection');
probetype=['probe_' choice{1}];
load([fileparts(mfilename('fullpath')) '\Settings'])
% Load probe configurations data structure configs from .mat file
cd(uigetdir('C:\Users\nielsenlab\Documents\MATLAB\ephysAnalysis\ProbeSpikes','Browse to directory where configs data structure is saved.'))
load probeConfigurations.mat
% Select field of configs data structure corresponding to the specified
% probe type
if isfield(configs,probetype)
    % Load Properties from spikes file
    load([fileparts(mfilename('fullpath')) '\Settings'])
    [FileName,PathName,~] = uigetfile([expFolder '\*.mat']);
    load([PathName FileName])
    expCell=split(FileName,'_Spikes.mat');
    experiment=expCell{1};
    % Find xy and shank positions in configs data structure that correspond to
    % channel numbers where spikes in Properties were detected
    % Update Properties and PropTitles with xy and shank positions
    Properties(17:19,:)=NaN;
    PropTitles{17}='xPosition';
    PropTitles{18}='yPosition';
    PropTitles{19}='shankNum';
    for i=1:max(configs.(probetype).channelNum)
        Properties(17,Properties(16,:)==i)=configs.(probetype).xPosition(i);
        Properties(18,Properties(16,:)==i)=configs.(probetype).yPosition(i);
        Properties(19,Properties(16,:)==i)=configs.(probetype).shankNum(i);
    end
    
%     % Compute x and y center of mass
%     
%         [~, channelInds, ~]=unique(Properties(16,:));
%         xPosition=Properties(17,channelInds);
%         yPosition=Properties(18,channelInds);
%         Mn=
%         x_surround=xPosition(i+-4:1:4);
%         y_surround=yPosition(i+-4:1:4);
%         x_cm = [x_cm sum(Mn.*repmat(x_surround',1,length(Mn(1,:))),1)./sum(Mn,1)];
%         y_cm = [y_cm sum(Mn.*repmat(y_surround',1,length(Mn(1,:))),1)./sum(Mn,1)];
%         Properties(20,Properties(16,:)==i)=x_cm;
        
    % Save Properties and PropTitles
    save([expFolder '/' experiment '/SpikeFiles/' experiment '_Spikes.mat'],'Properties','idk','PropTitles')
else
    disp('Specified probe configuration is not saved. Check spelling or use buildConfigStructure.m to add it to saved configurations.')
end