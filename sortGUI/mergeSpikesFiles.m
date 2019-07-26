load([fileparts(mfilename('fullpath')) '\Settings'])
experiment = inputdlg('Enter experiment name: ');
experiment = experiment{1};

PropertiesAll=[];
for i = 1:200 % For each of the 200 subsets the ephys data has been split into for processing
currentFile = [expFolder '/' experiment '/SpikeFiles/Spikes_' num2str(i-1) '.mat'];

load(currentFile) % Load file containing this section of ephys data
PropertiesAll=[PropertiesAll Properties]; % Append to concatenated Properties array
delete(currentFile) % Delete the file
end
Properties = PropertiesAll;
idk = zeros(1,length(Properties(1,:)));
PropTitles{1} = 'Amp (-4)';
PropTitles{2} = 'Amp (-3)';
PropTitles{3} = 'Amp (-2)';
PropTitles{4} = 'Amp (-1)';
PropTitles{5} = 'Amp (0)';
PropTitles{6} = 'Amp (1)';
PropTitles{7} = 'Amp (2)';
PropTitles{8} = 'Amp (3)';
PropTitles{9} = 'Amp (4)';
PropTitles{10} = 'Pk2Pk Amp';
PropTitles{11} = 'Energy';
PropTitles{12} = 'Wvf width';
PropTitles{13} = 'CHs width';
PropTitles{14} = 'CHs pos';
PropTitles{15} = 'Time(samples)';
PropTitles{16} = 'Ch detected';
PropTitles{17} = 'x pos detected';
PropTitles{18} = 'y pos detected';
PropTitles{19} = 'x_{cm}';
PropTitles{20} = 'y_{cm}';
PropTitles{21} = 'shankNum';

save([expFolder '/' experiment '/SpikeFiles/' experiment '_Spikes.mat'],'Properties','idk','PropTitles')