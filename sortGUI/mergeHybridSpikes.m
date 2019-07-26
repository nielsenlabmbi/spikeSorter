load([fileparts(mfilename('fullpath')) '\Settings'])
experiment = inputdlg('Enter experiment name: ');
experiment = experiment{1};

parts=dir([expFolder filesep experiment filesep 'tomerge' filesep experiment '_*.dat']);
numToMerge=numel(parts);

mergedFID=fopen([expFolder filesep experiment filesep experiment '_amplifier.dat'],'a+');
hybridSpikesList=[];

for i=1:numToMerge
    FID=fopen([expFolder filesep experiment filesep 'tomerge' filesep experiment '_' num2str(i-1) '.dat'],'r'); % Gets individual file
    currentFileData=fread(FID,inf,'int16'); % Load data from current file
    fwrite(mergedFID,currentFileData,'int16'); % Append the data to merged file
    
    load([expFolder filesep experiment filesep 'tomerge/spikeList_' num2str(i-1) '.mat']);
    hybridSpikesList=[hybridSpikesList spikeList];
    
    fclose(FID);
    
%     delete([expFolder '/' experiment '/tomerge/' experiment '_' num2str(i-1) '.dat']) % Delete the current data file
%     delete([expFolder '/' experiment '/tomerge/spikeList_' num2str(i-1) '.mat']) % Delete the current spikeslist file
end

fclose(mergedFID);
save([expFolder filesep experiment filesep 'hybridExperiment.mat'], 'hybridSpikesList','-append');