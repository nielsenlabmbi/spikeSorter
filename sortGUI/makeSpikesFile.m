function makeSpikesFile

% Load settings

load([fileparts(mfilename('fullpath')) '\Settings'])
experiment = inputdlg('Enter experiment name: ');
experiment = experiment{1};


% Get sample rate from info file
sampleFrq = getSampleFreqFromInfoFile([expFolder '/' experiment '/' experiment '_info.rhd']);
%

% Get Events

DigiFile = fopen([expFolder '/' experiment '/' experiment '_digitalin.dat']); % Get FID for digital input file
fileinfo = dir([expFolder '/' experiment '/' experiment '_digitalin.dat']);
Digital = fread(DigiFile, (fileinfo.bytes)/2, 'uint16'); % Read first half of the digital input pulse train
dDigital = diff(Digital);
One = find(dDigital == 1); % Start period 1
Two = find(dDigital == 2); % Start period 2
Three = find(dDigital == -2); % Start period 3
if length(Two) ~= length(Three) % What's happening here?
    Two = find(dDigital == 6);
end
if length(Two) ~= length(One)
    Two = find(dDigital == 6 | dDigital == 2);
    Three = find(dDigital == -6 | dDigital == -2);
end
Fourth = find(dDigital == -1); % Start period 4
Events.Timestamp{1}=[]; % Initializes Events.Timestamp; contains sample numbers where each period of the input pulse train begins
Events.Timestamp{1}(:,1)=One;
Events.Timestamp{1}(:,2)=Two;
Events.Timestamp{1}(:,3)=Three;
Events.Timestamp{1}(:,4)=Fourth;

% Load spikes file
load([expFolder '/' experiment '/SpikeFiles/' experiment '_Spikes.mat']);

% Initialize spikes and set mapping
numCHs = max(Properties(16,:));
Spikes={};
Mapping(1,:) = 1:1:numCHs; % Indices for channel numbers
Mapping(2,:) = ones(1,numCHs); % Will contain actual channel numbers

% Add 1 to idk so that first unit number is 1 (is assumed by downstream
% code)
idk = idk+1; % Contains unit number assignments of all spikes

% Populate Spikes structure and make unti position
Post = unique(idk); % List of the units isolated

%if missing spikes at end, add them to multiunit - addresses a bug that may
%have been corrected, commented out IW 12/12/18
% if length(idk) ~= length(Properties(1,:))
%     idk(end:length(Properties(1,:))) = 0;
% end

for Unit = 1:length(Post) % For every unit, take mean of the positions of 
    % the centers of mass of all spikes assigned to that unit
    UnitPosition(Unit) = mean(Properties(14,idk==Post(Unit)));
end

UnitType{1} = ones(length(Post),1);

[Spikes{1}.TimeStamp TimeOrder] = sort(Properties(15,:)); % Sorts times when spikes occurred in ascending order; why weren't they before?
Spikes{1}.Unit = idk(TimeOrder); % Matches unit assignments to spikes sorted in time

Spikes{1}.Waveform=zeros(90,length(Mapping(1,:)),length(Post)); % Initializes spike waveforms; voltages of 13 units on 64 channels at 90 time points?

% Determine unit type by contamination below 1.2msec
samplesRefPeriod = round((sampleFrq/1000)*1.2);
for Unit = 1:length(Post)
    TSt = Spikes{1}.TimeStamp(Spikes{1}.Unit==Post(Unit)); % Times when spikes assigned to unit occur
    dTSt = diff(TSt); % Inter-spike interval
    PostCont = sum(dTSt<(samplesRefPeriod)); % Number of times ISI is less than 1.2ms
    PostSpks = length(TSt); % Number of times unit spikes
    if PostCont == 0 % ISI never less than 1.2ms
        UnitType{1}(Unit) = 1;
    else
        if PostCont/PostSpks < 0.0005 % Fraction of spikes with ISI <1.2ms is less than 0.05
            UnitType{1}(Unit) = 2;
        else
            UnitType{1}(Unit) = 3; % Fraction of spikes with ISI <1.2ms is greater than 0.05
        end
    end
end

% Save spikes file
save([spikesFolder '/' experiment '_spikes.mat'],'Spikes','UnitType','Events','Mapping','Properties','UnitPosition','sampleFrq')

% Load Analyzer file
load([analyzerFileFolder '/' experiment(1:5) '/' experiment analyzerFileEnding],'-mat'); % Loads Analyzer file
% Analyze responses
Params = Analyzer.L.param{1,1}; % Specifies parameter to vary and range of values it can take
Reps = length(Analyzer.loops.conds{1,1}.repeats); % Number of repeats
BReps =length(Analyzer.loops.conds{1,end}.repeats); % Number of repeats with blank stimulus/final condition
Conds = length(Analyzer.loops.conds); % Number of conditions
    
if isequal(Analyzer.loops.conds{1,end}.symbol{1,1}, 'blank') % If blank stimulus is given
    Conds = length(Analyzer.loops.conds)-1; % Don't count the blank in the number of conditions
    for r = 1:BReps % For every rep in which blank stimulus was given
        Trial = Analyzer.loops.conds{1,end}.repeats{1,r}.trialno; % Extract the trial number for that repeat
        TrialInfo(Trial,:) = [repmat([(zeros(length(Analyzer.loops.conds{1,end-1}.val(:,:)),1)-1).' 0],[length(Trial) 1]) double(Events.Timestamp{1}(Trial,:))];
    end
end
for i = 1:Conds % For every condition
    for r = 1:Reps % For every repetition
        Trial = Analyzer.loops.conds{1,i}.repeats{1,r}.trialno; % Extract the trial number(s?) in which that condition was given
        TrialInfo(Trial,:) = [vertcat(Analyzer.loops.conds{1,i}.val{:,:}).' i double(Events.Timestamp{1}(Trial,:))]; % What is in TrialInfo?
    end
    CondInfo(i,:)= vertcat(Analyzer.loops.conds{1,i}.val{:,:}).';
end
Parmass = Analyzer.L.param; % What is this for?
VarValDims = 1; % Initializes VarValDims
for i=1:length(Parmass(1,:)) % For every variable parameter set? Would Parmass have a cell for each set used in an experiment?
    VarValDims = VarValDims*(length(eval(Parmass{1,i}{2})));
end

for site = 1:length(Spikes) % For every recording site
    Units = unique(Spikes{site}.Unit); % Find all units spikes were assigned to
    Units = sort(Units); % Sort units in ascending order
    if Units(1) == 0 % If the first unit is the "multi-unit" unit
        Units = Units(2:end); % Disregard that unit
    end
    Units = length(Units); % Count units identified
    Data{site}.Spiking=cell(VarValDims, Units, Reps); % Makes empty #conditions by #units by #repetitions cell array
    Data{site}.BSpiking=cell(Units, BReps); % Makes empty #units by #repetitions cell array. #Conditions=1, blank condition.
    Repetition = ones(VarValDims,1); % Initializes matrix to hold number of repetitions each condition appears in?
    for T = 1:length(TrialInfo(:,1)) % For each trial
        if not(isequal(TrialInfo(T,1:length(Parmass(1,:))), (zeros(1,length(Parmass(1,:))) -1))) % When would this be true/false? When TrialInfo is empty somehow?
            for Unit=1:Units % For every unit
                VariableIndex = TrialInfo(T,length(Parmass(1,:))+1); % Gets index of the condition used in this trial
                % Input timestamps of the spikes assigned to Unit under
                % condition VariableIndex during Repetition into Data
                % structure
                Data{site}.Spiking{VariableIndex,Unit,Repetition(VariableIndex)} = double(Spikes{site}.TimeStamp(find(Spikes{site}.Unit == Unit & Spikes{site}.TimeStamp > TrialInfo(T,length(Parmass(1,:))+2) & Spikes{site}.TimeStamp < TrialInfo(T,length(Parmass(1,:))+5))))-TrialInfo(T,length(Parmass(1,:))+3);
            end
            Repetition(VariableIndex) = Repetition(VariableIndex)+1; % Increments Repetition for next layer of Data, if there is one
        end
    end
    Repetition = 1;
    for T = 1:length(TrialInfo(:,1)) % For each trial
        if TrialInfo(T,1:length(Parmass(1,:))) == zeros(1,length(Parmass(1,:))) -1 % Again, when would this be true/false? Something to do with blank vs. non-blank conditions.
            for Unit=1:Units % For every unit
                % Input timestamps of the spikes assigned to Unit under the
                % blank condition during Repetition into Data structure
                Data{site}.BSpiking{Unit,Repetition} = double(Spikes{site}.TimeStamp(find(Spikes{site}.Unit == Unit & Spikes{site}.TimeStamp > TrialInfo(T,length(Parmass(1,:))+2) & Spikes{site}.TimeStamp < TrialInfo(T,length(Parmass(1,:))+5))))-TrialInfo(T,length(Parmass(1,:))+3);
            end
            Repetition = Repetition+1; % Increments Repetition for next layer of Data, if there is one
        end
    end

    Paramss = Analyzer.L.param; % Same as Parmass - what is it for?
    FixIndx = zeros(length(Paramss(1,:)),1)-1;
    for Unit = 1:length(UnitType{site}) % For every unit
        %Calc Blank Responses
        RepVal = [];
            for rep = 1:length(Data{site}.BSpiking(1,:)) % For every repetition
                Spks = [Data{site}.BSpiking{Unit,rep}]; % Load timestamps of spikes during blank stimulus
                RepVal(rep) =((sum(Spks>0 & Spks < sampleFrq*Analyzer.P.param{1,3}{3})/(Analyzer.P.param{1,3}{3}))-((sum(Spks<0))/Analyzer.P.param{1,1}{3})); % What is this? Spikes/s during first 20s of blank stimulus?
            end
        Data{site}.BRespMean(Unit) = mean(RepVal);
        Data{site}.BRespVar(Unit) = std(RepVal)/sqrt(length(RepVal));
        Data{site}.AllBResp(:,Unit) = RepVal;

        %Calc responses for all conditions
        for i = 1:length(Data{site}.Spiking(:,1,1)) % For every condition
            RepVal = [];
                for rep = 1:length(Data{site}.Spiking(1,1,:))
                    Spks = [Data{site}.Spiking{i,Unit,rep}];
                    RepVal(rep) =((sum(Spks>0 & Spks < sampleFrq*Analyzer.P.param{1,3}{3})/(Analyzer.P.param{1,3}{3}))-((sum(Spks<0))/Analyzer.P.param{1,1}{3})); % Spikes/s for first 20s of stimulus condition i
                end
            Data{site}.RespVar(Unit,i) = std(RepVal)/sqrt(length(RepVal));
            Data{site}.RespMean(Unit,i) = mean(RepVal);
            Data{site}.AllResp(Unit,:,i) = RepVal;
        end
    end
end
RespFunc = [0 sampleFrq*Analyzer.P.param{1,3}{3} 0 -sampleFrq*Analyzer.P.param{1,1}{3}]; % What is this for?
Values = cell(length(Paramss(1,:)),1);
for i = 1:length(Paramss(1,:))
    Params = Paramss{1,i};
    Variables{i} =Params{1,1};
    Values{i} = eval(Params{1,2});
end

% Save data file
save([dataFileFolder filesep experiment dataFileEnding],'Data', 'UnitType','Variables','Values','RespFunc','CondInfo','TrialInfo','sampleFrq');

% Write table if desired
% Ask
choice = questdlg('Do you want to save this record in the summary file?', ...
        'Summary file save', ...
        'Yes','No','Yes');

switch choice
        case 'No'
            return;
end

% Write
[num,txt,raw] = xlsread(summaryFile,1); % reads summaryFile (path is in Settings)
Rows=[]; % Initialize Rows
ExperimentName = experiment;

for i = 1:length(raw(:,1)) % Check every row of table
    if isequal(raw(i,3),{ExperimentName}) % Find this experiment's row(s) of the summary table
        Rows = [Rows i]; % Contains indices of rows containing information on this experiment
    end
end
if isempty(Rows)
    errordlg('Experiment has not been added to table yet')
    return
end
if length(Rows) > 1
    warndlg('Table showing previous units, deleting old units')
    raw(Rows(2:end),:) = [];
    Rows = Rows(1);
end
for site = 1:length(Data) % For each site in this experiment
    if site~=1 % If experiment has recordings at more than one site, add a new layer to raw for each site after the first
        raw = [raw(1:Rows(1),:);raw(Rows(1),:);raw(Rows(1)+1:end,:)];
        Rows(1)=Rows(1)+1;
    end
    % Add data for each unit to raw as its own row
    raw = [raw(1:Rows(1),:);cell(length(UnitType{site})-1,length(raw(1,:)));raw(Rows(1)+1:end,:)]; % Insert #units-1 new rows into raw after Rows to fill with unit data in the following lines; content of Rows will be replaced by Unit 1
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,1) = {lower(ExperimentName(1:5))}; % First column contains ferret identifier, in lowercase
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,3) = {ExperimentName}; % Third column contains experiment name
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,11) = cell(length(UnitType{site}),1); % 11th column contains a #units by 1 cell array
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,19) = raw(Rows(1),19); % Columns 19, 2, 4, 5, 6 contain whatever was manually entered into those columns for this experiment before updating summary table
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,2) = raw(Rows(1),2);
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,4) = raw(Rows(1),4);
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,5) = raw(Rows(1),5);
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,6) = raw(Rows(1),6);
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,7) = {site}; % Column 7 contains the recording site ID
    raw(Rows(1):Rows(1)+length(UnitType{site})-1,12:15) = repmat([{3} {date} {3} {date}],length(UnitType{site}),1); % Columns 12:15 contain date this function ran and the number 3. Why the 3?
    A = min(min(Spikes{site}.Waveform,[],2),[],3); % Minimum voltages?
    % Waveform dimension 2 is the
    if isempty(Spikes{site}.Waveform)
        MxPos = zeros(1,length(Spikes{site}.TimeStamp));
    else
        for i = 1:length(A)
            MxPos(i) = find(Spikes{site}.Waveform(i,:,:) == A(i),1); % Time when the minimum voltage occurs
        end
        MxPos = ceil(MxPos/length(Spikes{site}.Waveform(1,:,1)));
    end
    if length(MxPos) == length(Spikes{site}.TimeStamp) % If spike time is counted as time of spike peak, not time of threshold crossing?
        for i = 1:length(UnitType{site}) % For every unit
            raw(Rows(1)+i-1,8) = {i}; % Column 8 contains unit number
            raw(Rows(1)+i-1,9) = {UnitType{site}(i)}; % Column 9 contains unit type
            Spks = Spikes{site}.Unit == i; % Spks contains indices of Spikes that are assigned to current unit
            TStmps = double(Spikes{site}.TimeStamp(Spks))-MxPos(Spks)'; % Corrects timestamps to be time of spike peak
            ISI = TStmps(2:end) - TStmps(1:end-1); % Inter-spike interval
            Cont = sum(ISI<samplesRefPeriod)/length(ISI); % Fraction of ISIs<1.2ms
            raw(Rows(1)+i-1,10) = {Cont}; % Column 10 contains fraction of ISIs<1.2ms
        end
    else
        for i = 1:length(UnitType{site})
            raw(Rows(1)+i-1,8) = {i};
            raw(Rows(1)+i-1,9) = {UnitType{site}(i)};
            Spks = Spikes{site}.Unit == i;
            TStmps = double(Spikes{site}.TimeStamp(Spks));
            ISI = TStmps(2:end) - TStmps(1:end-1);
            Cont = sum(ISI<samplesRefPeriod)/length(ISI);
            raw(Rows(1)+i-1,10) = {Cont};
        end
    end
    Rows(1)=Rows(1)+length(UnitType{site})-1; % Increments Rows - if there's more than one site for this experiment data for next site will be entered starting from the end of the section just edited
end
xlswrite(summaryFile,raw,1); % Update summary table