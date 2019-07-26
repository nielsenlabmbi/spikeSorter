% Build probe configurations data structure

% Browse to chosen location for configs data structure and see if it
% already exists there. If it does, load it; if not, create it.
saveDir=uigetdir('C:\Users\nielsenlab\Documents\MATLAB\ephysAnalysis\ProbeSpikes','Browse to directory where configs data structure will be saved.');
cd(saveDir)
if exist('probeConfigurations.mat','file')
    load probeConfigurations.mat
else
    configs={};
end

% Load one of the probe files from 'Z:\Isis\IsisCode\UCLA Probes wiring'
[configFile,pathname,~]=uigetfile('Z:\Isis\IsisCode\UCLA Probes wiring\*.m','Select probe configuration file');
run([pathname configFile]);
% Get the probe type from the file name
[~, configName, ~]=fileparts([pathname configFile]);

% See if this probe type is already in the data structure. If it isn't,
% proceed; if it is, ask to overwrite.
if isfield(configs,configName(end))
    newfield=questdlg(['Configuration already exists; overwrite field ' configName(end) '?'], 'Overwrite','Yes','No','Yes');
else
    newfield='Yes';
end
% Build probe type's field of the configs structure
switch newfield
    case 'Yes'
        xPosition=probewiring(:,2);
        yPosition=probewiring(:,4);
        channelNum=probewiring(:,1);
        shankNum=probewiring(:,5);
        newconfig=table(channelNum,xPosition,yPosition,shankNum);
        configs.(configName(end))=newconfig;
        % Save configs structure
        save('probeConfigurations','configs')
    case 'No'
        disp('Cancelling buildConfigStructure')
end