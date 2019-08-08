function sample_rate = getSampleFreqFromInfoFile(filename)

% read_Intan_RHD2000_file

% Add filename end
filename = [filename '_info.rhd'];
tic;
fid2 = fopen(filename, 'r');

% Check 'magic number' at beginning of file to make sure this is an Intan
% Technologies RHD2000 data file.

magic_number = fread(fid2, 1, 'uint32');
if magic_number ~= hex2dec('c6912702')
    error('Unrecognized file type.');
end

% Read version number.
data_file_main_version_number = fread(fid2, 1, 'int16');
data_file_secondary_version_number = fread(fid2, 1, 'int16');

% Read information of sampling rate and amplifier frequency settings.
sample_rate = fread(fid2, 1, 'single');


