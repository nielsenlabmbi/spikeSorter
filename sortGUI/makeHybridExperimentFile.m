% Make hybrid experiment file
    
load([fileparts(mfilename('fullpath')) filesep 'Settings'])
inputs = inputdlg({'Enter hybrid experiment name: ','Enter donor experiment name: ','Enter donor unit number: ','Enter shift size (# channels, +/-): '},'Hybrid Dataset');
hybridExperiment = inputs{1};
donorExperiment = inputs{2};
donorCluster = str2num(inputs{3});
spatialShift = str2num(inputs{4});

noiseParams=inputdlg({'Enter shot noise lambda: ','Enter noise gain: '});

lambda=str2num(noiseParams{1});
noiseGain=str2num(noiseParams{2});

mkdir([expFolder filesep hybridExperiment])
mkdir([expFolder filesep hybridExperiment filesep 'tomerge'])
mkdir([expFolder filesep hybridExperiment filesep 'SpikeFiles'])
save([expFolder filesep hybridExperiment filesep 'hybridExperiment.mat'],'hybridExperiment','donorExperiment','donorCluster','spatialShift','lambda','noiseGain')
save([fileparts(mfilename('fullpath')) filesep 'hybridExperiment.mat'],'hybridExperiment','donorExperiment','donorCluster','spatialShift','lambda','noiseGain')

for JobID=6:10
    makeHybridDataset(JobID);
end