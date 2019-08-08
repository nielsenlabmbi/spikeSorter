load([fileparts(mfilename('fullpath')) '\Settings'])
experiment = inputdlg('Enter experiment name: ');
experiment = experiment{1};

PropertiesAll=[];
currentFile = [expFolder '/' experiment '/SpikeFiles/Spikes_0.mat'];
for i = 1:parts % For each of the subsets the ephys data has been split into for processing
currentFile = [expFolder '/' experiment '/SpikeFiles/Spikes_' num2str(i-1) '.mat'];

load(currentFile) % Load file containing this section of ephys data
PropertiesAll=[PropertiesAll Properties]; % Append to concatenated Properties array
delete(currentFile) % Delete the file
end
Properties = PropertiesAll;
idk = zeros(1,length(Properties(1,:)));

save([expFolder '/' experiment '/SpikeFiles/' experiment '_Spikes.mat'],'Properties','idk','PropTitles')