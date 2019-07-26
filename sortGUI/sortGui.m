function varargout = sortGui(varargin)
% SORTGUI MATLAB code for sortGui.fig
%      SORTGUI, by itself, creates a new SORTGUI or raises the existing
%      singleton*.
%
%      H = SORTGUI returns the handle to a new SORTGUI or the handle to
%      the existing singleton*.
%
%      SORTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SORTGUI.M with the given input arguments.
%
%      SORTGUI('Property','Value',...) creates a new SORTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sortGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sortGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sortGui

% Last Modified by GUIDE v2.5 28-Jan-2019 17:26:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sortGui_OpeningFcn, ...
                   'gui_OutputFcn',  @sortGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before sortGui is made visible.
function sortGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sortGui (see VARARGIN)

% Choose default command line output for sortGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sortGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sortGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function unitsMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unitsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function propOneMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to propOneMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function propTwoMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to propTwoMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function compUnitMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compUnitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function shankSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shankSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in loadFile.
function loadFile_Callback(hObject, eventdata, handles)
global Properties PropTitles idk Time CHsPos PathName FileName x_cm y_cm shankNum projectionCount pos2D
load([fileparts(mfilename('fullpath')) '\Settings'])
[FileName,PathName,FilterIndex] = uigetfile([expFolder '\*.mat']);
load([PathName FileName])

projectionCount=0;
CHsPos = 14;
Amp0 = 5;
Time = 15;
for i = 1:length(PropTitles) % Find the rows of Properties that contain ChsPos, Amp0, and Time if they aren't in default order
  switch PropTitles{i}
      case 'CHs pos'
          CHsPos=i;
      case 'Amp (0)'
          Amp0=i;
      case 'Time'
          Time = i;
      case 'x_{cm}'
          x_cm=i;
      case 'y_{cm}'
          y_cm=i;
      case 'shankNum'
          shankNum=i;
  end
end
idk = sortTheUnits(Properties,idk,CHsPos); % sort spikes by mean position along probe

handles.propOneMenu.String = PropTitles; % Properties to choose from as property 1
handles.propOneMenu.String{end+1} = '2D Position';
pos2D=length(handles.propOneMenu.String);
handles.propOneMenu.Value = CHsPos;
handles.fileTxt.String = FileName; % Name of the SpikesFile
handles.propTwoMenu.String = handles.propOneMenu.String; % Properties to choose from as property 2
handles.propTwoMenu.Value = Amp0;
units = sort(unique(idk));
handles.unitsMenu.String = units; % Units to choose from
handles.unitsMenu.Value = 1; % Initially select first unit on list
handles.compUnitMenu.String = units; % Unit to compare to main selected unit
handles.compUnitMenu.Value = 1;
shanksPresent=unique(Properties(shankNum,:))';
handles.shankSelection.String=num2str(shanksPresent);
handles.shankSelection.Value=1;

meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000; % Mean firing rate for selected unit
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(1))); % All timestamps in ascending order when spikes assigned to unit 0 (multi-unit/unsorted) occurred
dTst = diff(Tst); % Inter-spike interval
cont = sum(dTst<36)./sum(idk==units(1)); % Fraction of ISIs under 36 frames (1.2ms with 30kHz sampling rate)
handles.ISIContAns.String = num2str(cont);

scatter(handles.theOnlyAxes,Properties(CHsPos,(idk==units(1)&Properties(shankNum,:)==1)),Properties(Amp0,(idk==units(1)&Properties(shankNum,:)==1)),'SizeData',1,'CData',[0 0 0],'Marker','.') % Generates scatter plot of Amp0 vs CHsPos for unsorted spikes
handles.project.Enable='off';
handles.cleanUnit.Enable='on';
handles.sortUnit.Enable='on';
% hObject    handle to loadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in prevUnit.
function prevUnit_Callback(hObject, eventdata, handles)
global Properties idk Time x_cm y_cm pos2D
units = sort(unique(idk)); % All units
currVal = handles.unitsMenu.Value; % Currently selected unit
currVal = currVal-1; % Chooses previous unit in ascending order
if currVal<1
    currVal = length(handles.unitsMenu.String); % If originally selected unit was the first on the list, new selection is the last unit on the list
end
handles.unitsMenu.Value = currVal; % Updates currently selected unit

% Rest of function updates displayed mean firing rate, ISI, and scatter
% plot for newly selected unit
meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000;
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));

plotFunction(units,handles)
% hObject    handle to prevUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in nextUnit.
function nextUnit_Callback(hObject, eventdata, handles)
global Properties idk Time x_cm y_cm pos2D
units = sort(unique(idk)); % All units
currVal = handles.unitsMenu.Value; % Currently selected unit
currVal = currVal+1; % Chooses next unit in ascending numerical order
if currVal>length(handles.unitsMenu.String)
    currVal = 1; % If originally selected unit was last on the list, new selection is first on the list
end
handles.unitsMenu.Value = currVal; % Updates unit selection

% Rest of function updates displayed mean firing rate, ISI, and scatter
% plot for newly selected unit
meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000;
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));

plotFunction(units,handles)
% hObject    handle to nextUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in unitsMenu.
function unitsMenu_Callback(hObject, eventdata, handles)
global Properties idk Time x_cm y_cm pos2D shankNum
units = sort(unique(idk)); % All units

% Updates mean firing rate, ISI and scatter plot for newly selected unit
meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000;
handles.meanFRAns.String = num2str(meanFR);
handles.shankSelection.Value=mode(Properties(shankNum,idk==units(handles.unitsMenu.Value)));

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));

plotFunction(units,handles)
% hObject    handle to unitsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unitsMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unitsMenu


% --- Executes on button press in nextPropOne.
function nextPropOne_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
currVal = handles.propOneMenu.Value; % Gets current selection for property 1
currVal = currVal+1; % Chooses next selection in ascending numerical order
if currVal>length(handles.propOneMenu.String)
    currVal = 1; % If end of list is reached, return to beginning
end
handles.propOneMenu.Value = currVal; % Updates property selection

plotFunction(units,handles)
% hObject    handle to nextPropOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in prevPropOne.
function prevPropOne_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
currVal = handles.propOneMenu.Value; % Gets current selection for property 1
currVal = currVal-1; % Chooses previous selection in ascending numerical order
if currVal<1
    currVal = length(handles.propOneMenu.String); % If original selection was beginning of list, go to end
end
handles.propOneMenu.Value = currVal; % Update property 1 selection

plotFunction(units,handles)
% hObject    handle to prevPropOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in propOneMenu.
function propOneMenu_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
plotFunction(units,handles)
% hObject    handle to propOneMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns propOneMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from propOneMenu


% --- Executes on button press in nextPropTwo.
function nextPropTwo_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
currVal = handles.propTwoMenu.Value; % Gets current selection
currVal = currVal+1; % Chooses next selection
if currVal>length(handles.propTwoMenu.String)
    currVal = 1; % If end of list was reached, return to beginning
end
handles.propTwoMenu.Value = currVal; % Update selection
plotFunction(units,handles)
% hObject    handle to nextPropTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in prevPropTwo.
function prevPropTwo_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
currVal = handles.propTwoMenu.Value; % Get current selection
currVal = currVal-1; % Choose next selection
if currVal<1
    currVal = length(handles.propTwoMenu.String); % If original selection was first of list, go to end
end
handles.propTwoMenu.Value = currVal;
plotFunction(units,handles)
% hObject    handle to prevPropTwo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in propTwoMenu.
function propTwoMenu_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
plotFunction(units,handles)
% hObject    handle to propTwoMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns propTwoMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from propTwoMenu


% --- Executes on button press in uinitISI.
function uinitISI_Callback(hObject, eventdata, handles)
global Properties idk Time
units = sort(unique(idk));
Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value))); % Spike times in order for selected unit
dTst = diff(Tst); % Inter-spike interval
hist(handles.theOnlyAxes,(dTst(dTst<120))./30,24); % Plot histogram of ISIs for this unit
hold on
plot(handles.theOnlyAxes,[1.2 1.2],[0 max(hist((dTst(dTst<120))./30,24))]); % Plot boundary at 1.2ms
hold off
set(handles.theOnlyAxes,'XLim',[0 4])
% hObject    handle to uinitISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in cleanUnit.
function cleanUnit_Callback(hObject, eventdata, handles)
global Properties idk Time
units = sort(unique(idk));
scatter(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(handles.unitsMenu.Value))),Properties(handles.propTwoMenu.Value,(idk==units(handles.unitsMenu.Value))),'SizeData',1,'CData',[0 0 0],'Marker','.')    
handles.project.Enable='off';
handles.cleanUnit.Enable='on';
handles.sortUnit.Enable='on';
BW = impoly; % Draw polygonal ROI on scatter plot
nodes=getPosition(BW); % X and Y positions of nodes of the ROI
selected = (inpolygon(Properties(handles.propOneMenu.Value,idk==units(handles.unitsMenu.Value)),Properties(handles.propTwoMenu.Value,idk==units(handles.unitsMenu.Value)),nodes(:,1),nodes(:,2))); % Returns true for points in the scatterplot that are in the polygon defined by nodes
Ploted = find(idk==units(handles.unitsMenu.Value)); % Find all spikes belonging to the selected unit
idk(Ploted(~selected))=0; % Assign spikes that belong to the selected unit but are not in the ROI to unit 0

if sum(idk==units(handles.unitsMenu.Value)) == 0 % If the selected unit doesn't have any spikes assigned to it
    for unit2move = units(handles.unitsMenu.Value)+1:max(idk) % For every unit number higher than the selected unit
        idk(idk==unit2move) = unit2move-1; % Move all the spikes assigned to that unit down by one unit
    end
end

meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000; % Mean firing rate over the entire time period
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));
plotFunction(units,handles)
% end
% hObject    handle to cleanUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in sortUnit.
function sortUnit_Callback(hObject, eventdata, handles)
global Properties idk CHsPos Time
units = sort(unique(idk));
plotFunction(units,handles)
BW = impoly; % Draw polygonal ROI on scatterplot
nodes=getPosition(BW); % X and Y positions of nodes defining boundaries of ROI
selected = (inpolygon(Properties(handles.propOneMenu.Value,idk==units(handles.unitsMenu.Value)),Properties(handles.propTwoMenu.Value,idk==units(handles.unitsMenu.Value)),nodes(:,1),nodes(:,2))); % Returns true for points in the scatterplot that are in the polygon defined by nodes
Ploted = find(idk==units(handles.unitsMenu.Value)); % Find all spikes belonging to selected unit
idk(Ploted(selected))=max(idk)+1; % All spikes that belong to selected unit and are in the ROI are assigned to new highest unit number

if sum(idk==units(handles.unitsMenu.Value)) == 0 % If currently selected unit has no spikes assigned to it
    for unit2move = units(handles.unitsMenu.Value)+1:max(idk) % For every unit number higher than the selected unit
        idk(idk==unit2move) = unit2move-1; % Move those units' spikes down by one unit
    end
end

newunit = max(idk); % New unit number
idkpos = find(idk==newunit,1); % Find the first spike assigned to the new unit - why?
idk = sortTheUnits(Properties,idk,CHsPos); % Redo sorting with new unit included
newunit = idk(idkpos); % Why?

% Update controls to include new unit
units = sort(unique(idk));
handles.unitsMenu.String = units;
handles.compUnitMenu.String = units;
handles.unitsMenu.Value = newunit+1; % Change currently selected unit to the new unit

meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000;
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));
plotFunction(units,handles)
% end
% hObject    handle to sortUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in delteUnit.
function delteUnit_Callback(hObject, eventdata, handles)
global Properties idk CHsPos Time x_cm y_cm pos2D

units = sort(unique(idk));
idk(idk==units(handles.unitsMenu.Value))=0; % Move all spikes assigned to the selected (deleted) unit to unit 0

for unit2move = units(handles.unitsMenu.Value)+1:max(idk) 
    idk(idk==unit2move) = unit2move-1; % Move all units numbered higher than the deleted unit down by one unit
end

% Update controls to remove deleted unit
units = sort(unique(idk));
handles.unitsMenu.String = units; 
handles.unitsMenu.Value = 1; % Change current unit selection to unit 0
handles.compUnitMenu.String = units;
handles.compUnitMenu.Value = 1; % Change current unit selection to unit 0

meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000;
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));
plotFunction(units,handles)
% hObject    handle to delteUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextCompUnit.
function nextCompUnit_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
currVal = handles.compUnitMenu.Value; % Gets current selection
currVal = currVal+1; % Chooses next unit
if currVal>length(handles.compUnitMenu.String)
    currVal = 1; % If current selection is end of the list, go back to beginning
end
handles.compUnitMenu.Value = currVal; % Changes unit selection to next

units = sort(unique(idk));
plotFunctionCompare(units,handles)
% hObject    handle to nextCompUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in prevCompUnit.
function prevCompUnit_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
currVal = handles.compUnitMenu.Value; % Gets current selection
currVal = currVal-1; % Chooses next selection
if currVal<1
    currVal = length(handles.compUnitMenu.String);
end
handles.compUnitMenu.Value = currVal; % Changes selection

units = sort(unique(idk));
plotFunctionCompare(units,handles)
% hObject    handle to prevCompUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in compUnitMenu.
function compUnitMenu_Callback(hObject, eventdata, handles)
global Properties idk x_cm y_cm pos2D
units = sort(unique(idk));
plotFunctionCompare(units,handles)
% hObject    handle to compUnitMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns compUnitMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from compUnitMenu


% --- Executes on button press in compUnitPlot.
function compUnitPlot_Callback(hObject, eventdata, handles)
global Properties idk CHsPos Time x_cm y_cm pos2D
units = sort(unique(idk));
plotFunctionCompare(units,handles)
% hObject    handle to compUnitPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in compUnitCrossISI.
function compUnitCrossISI_Callback(hObject, eventdata, handles)
global Properties idk CHsPos Time
units = sort(unique(idk));
unit1 = units(handles.unitsMenu.Value); % Primary unit
unit2 = units(handles.compUnitMenu.Value); % Comparison unit
unit1Tst = sort(Properties(Time,idk==unit1)); % Get timestamps for spikes assigned to unit 1
unit2Tst = sort(Properties(Time,idk==unit2)); % Get timestamps for spikes assigned to unit 2
Tst = [unit1Tst unit2Tst];
Source = [zeros(1,length(unit1Tst)) ones(1,length(unit2Tst),1)]; % For keeping track of spikes belonging to unit 1 and unit 2
[Tst Order] = sort(Tst); % Sort spikes from unit 1 and unit 2 in ascending order; output the new order
Source = Source(Order); % Put Source in the new order, tracks which spikes originate from which unit now that they are sorted by time instead of unit number
dTst = diff(Tst); % Inter-spike interval
dSource = diff(Source); % Finds spikes that are temporally adjacent and from the same source
dTst(dSource == 0)=[]; % Remove ISIs between spikes with the same source
hist(handles.theOnlyAxes,(dTst(dTst<240))./30,24); % Plot cross-unit ISIs
hold on
plot(handles.theOnlyAxes,[1.2 1.2],[0 max(hist((dTst(dTst<120))./30,24))]); % Plot threshold at 1.2 ms ISI
hold off
% hObject    handle to compUnitCrossISI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 

% --- Executes on button press in compUnitMerge.
function compUnitMerge_Callback(hObject, eventdata, handles)
global Properties idk CHsPos Time x_cm y_cm pos2D

units = sort(unique(idk));
idk(idk==units(handles.unitsMenu.Value))=units(handles.compUnitMenu.Value); % Change number of primary unit to number of comparison unit

for unit2move = units(handles.unitsMenu.Value)+1:max(idk) % For all units with a higher unit number than the primary unit
    idk(idk==unit2move) = unit2move-1; % Move down by one unit number
end

units = sort(unique(idk));
handles.unitsMenu.String = units; % Update units menu to reflect merge
handles.unitsMenu.Value = 1; % Change unit selection to unit 0
handles.compUnitMenu.String = units; % Update comparison unit menu to reflect merge
if handles.compUnitMenu.Value<handles.unitsMenu.Value % If currently selected comparison unit has a lower number than currently selected primary unit (unit 0)
    handles.unitsMenu.Value = handles.compUnitMenu.Value; % Select the comparison unit as the primary unit
else
    handles.unitsMenu.Value = handles.compUnitMenu.Value; % Select the comparison unit as the primary unit
end

meanFR = (sum(idk==units(handles.unitsMenu.Value))./max(Properties(Time,:)))*30000;
handles.meanFRAns.String = num2str(meanFR);

Tst = sort(Properties(Time,idk==units(handles.unitsMenu.Value)));
dTst = diff(Tst);
cont = sum(dTst<36)./sum(idk==units(handles.unitsMenu.Value));
handles.ISIContAns.String = num2str(round(cont,3,'significant'));
plotFunction(units,handles)
% hObject    handle to compUnitMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveFile.
function saveFile_Callback(hObject, eventdata, handles)
global Properties PropTitles idk Time CHsPos PathName FileName
save([PathName FileName],'idk','Properties','PropTitles','-append')
% hObject    handle to saveFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function allUnitRadio_Callback(hObject, eventdata, handles, varargin)


% --- Executes on button press in project.
function project_Callback(hObject, eventdata, handles)
global Properties PropTitles idk PathName FileName y_cm x_cm shankNum projectionCount pos2D
projectionCount=projectionCount+1;
units = sort(unique(idk));
% Get azimuthal angle rho of current perspective
[rho,~]=view;
rho=rho*(pi/180); % Convert to radians
% Get azimuthal angle theta of vector from origin to each data point
theta=atan(Properties(x_cm,:)./Properties(y_cm,:)); % in radians
% Get sign of 1D point
signC=sign(rho-theta);

% Get matrix of xy values for all points
twoDimCoord=[Properties(y_cm,:)' Properties(x_cm,:)'];
% Get unit normal vector to projection plane
[unorm(1),unorm(2)]=pol2cart(rho,1);

unorm=repmat(unorm,size(twoDimCoord,1),1);
compu_twoDim=dot(unorm,twoDimCoord,2); % Scalar projection in the unorm direction
parProj=compu_twoDim.*unorm; % Vector projection in the unorm direction
perProj=twoDimCoord-parProj; % Vector projection perpendicular to unorm
oneDimCoord=signC'.*sqrt(sum(perProj.^2,2)); % Projection of spike centers of mass into the view plane

% Add the new 1D projection to Properties and PropTitles
Properties(end+1,:)=oneDimCoord;
PropTitles{end+1}=['Azimuth' num2str(rho*(180/pi)) 'deg'];
handles.propOneMenu.String ={handles.propOneMenu.String{1:end-1} ['Azimuth' num2str(rho*(180/pi)) 'deg'] handles.propOneMenu.String{end}};
handles.propTwoMenu.String = {handles.propTwoMenu.String{1:end-1} ['Azimuth' num2str(rho*(180/pi)) 'deg'] handles.propTwoMenu.String{end}};
pos2D=pos2D+1;
handles.project.Enable='off';
handles.cleanUnit.Enable='on';
handles.sortUnit.Enable='on';
if handles.propOneMenu.Value==pos2D
    handles.propOneMenu.Value=length(handles.propOneMenu.String)-1;
elseif handles.propTwoMenu.Value==pos2D
    handles.propTwoMenu.Value=length(handles.propTwoMenu.String)-1;
end
plotFunction(units,handles)
% hObject    handle to project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in shankSelection.
function shankSelection_Callback(hObject, eventdata, handles)
global idk
units = sort(unique(idk));
plotFunction(units,handles)
% hObject    handle to shankSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns shankSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from shankSelection

function plotFunction(units,handles)
global Properties idk CHsPos Time x_cm y_cm pos2D shankNum

if handles.propOneMenu.Value==pos2D & handles.propTwoMenu.Value~=pos2D
    scatter3(handles.theOnlyAxes,Properties(x_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(handles.propTwoMenu.Value,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1,'CData',[0 0 0])
    handles.project.Enable='on';
    handles.cleanUnit.Enable='off';
    handles.sortUnit.Enable='off';
    xlabel('x_{cm}')
    ylabel('y_{cm}')
    zlabel(handles.propTwoMenu.String{handles.propTwoMenu.Value})
elseif handles.propTwoMenu.Value==pos2D & handles.propOneMenu.Value~=pos2D
    scatter3(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(x_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1,'CData',[0 0 0])
    handles.project.Enable='on';
    handles.cleanUnit.Enable='off';
    handles.sortUnit.Enable='off';
    ylabel('x_{cm}')
    zlabel('y_{cm}')
    xlabel(handles.propOneMenu.String{handles.propOneMenu.Value})
elseif handles.propTwoMenu.Value==pos2D & handles.propOneMenu.Value==pos2D
    scatter3(handles.theOnlyAxes,Properties(x_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(x_cm,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1,'CData',[0 0 0])
    handles.project.Enable='on';
    handles.cleanUnit.Enable='off';
    handles.sortUnit.Enable='off';
    xlabel('x_{cm}')
    ylabel('y_{cm}')
    zlabel('x_{cm}')
else
    scatter(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(handles.propTwoMenu.Value,(idk==units(handles.unitsMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'SizeData',1,'CData',[0 0 0],'Marker','.')    
    handles.project.Enable='off';
    handles.cleanUnit.Enable='on';
    handles.sortUnit.Enable='on';
    xlabel(handles.propOneMenu.String{handles.propOneMenu.Value})
    ylabel(handles.propTwoMenu.String{handles.propTwoMenu.Value})
end

function plotFunctionCompare(units,handles)
global Properties idk x_cm y_cm pos2D shankNum
if handles.allUnitRadio.Value % If user has chosen to plot all units 
    hold on
    for unit = 1:length(units) % For all units
        if unit ~= handles.unitsMenu.Value % Except for the current main selected unit
            if handles.propOneMenu.Value==pos2D & handles.propTwoMenu.Value~=pos2D
                scatter3(handles.theOnlyAxes,Properties(x_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(handles.propTwoMenu.Value,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1)
                handles.project.Enable='on';
                handles.cleanUnit.Enable='off';
                handles.sortUnit.Enable='off';
                xlabel('x_{cm}')
                ylabel('y_{cm}')
                zlabel(handles.propTwoMenu.String{handles.propTwoMenu.Value})
            elseif handles.propTwoMenu.Value==pos2D & handles.propOneMenu.Value~=pos2D
                scatter3(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(x_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1)
                handles.project.Enable='on';
                handles.cleanUnit.Enable='off';
                handles.sortUnit.Enable='off';
                ylabel('x_{cm}')
                zlabel('y_{cm}')
                xlabel(handles.propOneMenu.String{handles.propOneMenu.Value})
            elseif handles.propTwoMenu.Value==pos2D & handles.propOneMenu.Value==pos2D
                scatter3(handles.theOnlyAxes,Properties(x_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(x_cm,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1)
                handles.project.Enable='on';
                handles.cleanUnit.Enable='off';
                handles.sortUnit.Enable='off';
                xlabel('x_{cm}')
                ylabel('y_{cm}')
                zlabel('x_{cm}')
            else
                scatter(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(handles.propTwoMenu.Value,(idk==units(unit)&Properties(shankNum,:)==handles.shankSelection.Value)),'SizeData',1,'Marker','.')    
                handles.project.Enable='off';
                handles.cleanUnit.Enable='on';
                handles.sortUnit.Enable='on';
                xlabel(handles.propOneMenu.String{handles.propOneMenu.Value})
                ylabel(handles.propTwoMenu.String{handles.propTwoMenu.Value})
            end
        end
    end
    hold off
else
    hold on
    if handles.propOneMenu.Value==pos2D
        scatter3(handles.theOnlyAxes,Properties(x_cm,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(handles.propTwoMenu.Value,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1,'CData',[1 0 0])
        handles.project.Enable='on';
        handles.cleanUnit.Enable='off';
        handles.sortUnit.Enable='off';
        xlabel('x_{cm}')
        ylabel('y_{cm}')
        zlabel(handles.propTwoMenu.String{handles.propTwoMenu.Value})
    elseif handles.propTwoMenu.Value==pos2D
        scatter3(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(x_cm,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(y_cm,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'Marker','.','SizeData',1,'CData',[1 0 0])
        handles.project.Enable='on';
        handles.cleanUnit.Enable='off';
        handles.sortUnit.Enable='off';
        ylabel('x_{cm}')
        zlabel('y_{cm}')
        xlabel(handles.propOneMenu.String{handles.propOneMenu.Value})
    else
        scatter(handles.theOnlyAxes,Properties(handles.propOneMenu.Value,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),Properties(handles.propTwoMenu.Value,(idk==units(handles.compUnitMenu.Value)&Properties(shankNum,:)==handles.shankSelection.Value)),'SizeData',1,'CData',[1 0 0],'Marker','.')    
        handles.project.Enable='off';
        handles.cleanUnit.Enable='on';
        handles.sortUnit.Enable='on';
        xlabel(handles.propOneMenu.String{handles.propOneMenu.Value})
        ylabel(handles.propTwoMenu.String{handles.propTwoMenu.Value})
    end
    hold off
end


% --- Executes on button press in nextShank.
function nextShank_Callback(hObject, eventdata, handles)
% hObject    handle to nextShank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global idk
currVal = handles.shankSelection.Value; % Gets current selection
currVal = currVal+1; % Chooses next selection
if currVal>length(handles.shankSelection.String)
    currVal = 1;
end
handles.shankSelection.Value = currVal; % Changes selection

units = sort(unique(idk));
plotFunction(units,handles)


% --- Executes on button press in prevShank.
function prevShank_Callback(hObject, eventdata, handles)
% hObject    handle to prevShank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global idk
currVal = handles.shankSelection.Value; % Gets current selection
currVal = currVal-1; % Chooses next selection
if currVal<1
    currVal = length(handles.shankSelection.String);
end
handles.shankSelection.Value = currVal; % Changes selection

units = sort(unique(idk));
plotFunction(units,handles)

% --- Executes during object creation, after setting all properties.
function theOnlyAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theOnlyAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate theOnlyAxes
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
