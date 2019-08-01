# spikeSorter

2/27/18

This process relays on several scripts:
makeExpermientFile.mat: This first scripts takes the binnary data file and some user input to create am experiment.mat file that contains information important to extract spikes form the recording. This information includes: Information about the probe, mainly number of channels and an order index for each channel that will arrange them in 1 dimension. This order is important in that it determines which channels neighboor each other which impacts on the effects of artifitial refractory periods (see notes on spikesFunction).

Steps:

1. Copy your data folder into your "expFolder": 
expFolder is a variable containing a path that is stored on the Settings.mat file in clusterSpikesProbe folder where several of the scripts for dealing with multichannel probes data are. Not to be confused with the Settings file under the Settings.mat file in ProbeManualSorting folder which contains settings for the sorting gui. When you install these script in a new machine you will have to change some variables in that settings file.

2. Make experiment mat file: This file is made by "makeExperimentFile.m". This script needs manual input of experiment name and probe class. It then presents the first minute of recording to the user for it to decide the threshold for spike detection and indicate which channels are bad. This file will contain information about the experiment required to process the experiment in the cluster.  It contains: 
   - a1 and b1: Bandpass filter to filter raw data. 
   - BadCh: a boolean vector indicating whether a channel is bad or not.
   - CHs: The order of the channels in the probe, it is decided based on the probe following some track starting from the base to the tip of the probe.
   - experiment: the experiment name.
   - Th: unique threshold to detect spikes on any channel that is not bad.

3. The experiment file needs to be copied into  "/home/alempel1/spikesFromProbe" replacing  any previous experiment file. Also the experiment folder (which includes the raw data) needs to be copied to the same folder. 

4. Submit the "spikesSubmitScript.submit" to the cluster: From the Terminal input:
   - ssh 'user'@'ip adress
   - cd spikesFromProbe
   - condor_submit spikesSubmitScript.submit
   - This script will run spikesFuncition in 200 instances. Each instance gets a 1/200 fraction of the file to be processed (with some overlay between fractions so that if a spike gets detected at the end of one the samples needed for the waveform are available and spike don’t get detected at the ends of the fraction if it is not the minimum in the appropriate window). This detection works exactly the same as SpikesIntan script. When the minimum is searched for across channels it will only consider channels that are +/- 4 channels (unlike the SpikesIntan script which does it across all channels).

5. Merge spikes files: The cluster will output 200 files into the 'SpikeFiles" folder in the experiment folder that you copied to the cluster. These files contain the spike information for spikes detected in each fraction of the recording. This files are merged in a unique spikes file using script "mergeSpikesFiles". The merged file will include a matrix call "Properties" a vector called "idk" and a cell called "PropTitles". The "Properties" vector includes a number of properties for each detected spike. The spike waveforms are not handled by the spike detection algorithm as the files would be to heavy and hard to work with.  The cell PropTitles indicate which property is included in the Properties matrix. These may change but at the moment they include: 
   - Amp(0): amplitude (minimum value minus baseline) at the channel of detection (the one with the minimum value).
   - Amp(-4 to 4): value at sample 16 (detected minimum of spike) for those channels neighboring the channel of detection (4 channels up to 4 channels down the order given by the probe type. When a spike is detected at the end of a probe and a channel in some direction does not exist, that amplitude is set to 0.
   - Pk2Pk Amp: Amplitude at detection channel given as minimum - post valley instead of - baseline. Energy: Energy of  the spike waveform (41 samples as described in SpikesIntan) at the channel of detection.
   - Wvf width: Width of waveform at the channel of detection, post valley position is determined as the first local maxima after sample 16 (where the minimum is).
   - CHs Width: Calculated as Amp(0) divided by sum of all Amps. Gives a metric of how wide is the spike across channels of the probe.
   - CH Pos: The position of the spike across the probe measured as the center of mass of the spike across channels -1 to 1 (detected +/- 1).
   - Timestamp: sample of detection.
   - CH detected: The channel were the spice is detected.
Finally, idk is a vector of length = number of detected spikes that is initialized as all zeros.

6. Sort your spikes using "sortGUI" which essentially makes changes to "idk".
7. Once done you need to run "makeSpikesFiles" which will ask you the experiment name. It will then use the digital input information of the experiment to get all the trial information. Then, it loads your sorted spikes file to get all the sorting information and creates the Spike structure (Like SpikesIntan but this one will leave the Waveforms part empty as there is no available waveforms). Once this is done it creates a "…_Spikes" file under the "spikesFolder" path loaded from the settings file containing this information plus the sorting information. After that it will load the experiment Analyzer file, calculate the data file (Like sorter or SortV2 but this one does not assume sampling frequency) and save it and if the user decide will also write the info in the summary file (the path and file ending of all these files being loaded and created are set by variables stored in the settings file).
