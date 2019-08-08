function Data = getRawDataFromFile(filename,BadCh,sampleFrq)
filename = [filename '_amplifier.dat'];
DataFile = fopen(filename,'r'); % Opens voltage data file for reading
Data = fread(DataFile, [length(BadCh) sampleFrq*30], 'int16'); % reads first 30 seconds of voltage data for all channels
end