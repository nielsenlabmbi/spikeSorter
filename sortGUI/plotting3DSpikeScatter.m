% Load Properties, PropTitle, and idk
clearvars -except Properties idk PropTitles
% Choose property to plot in addition to 2D position; in sortGui, would do
% this with GUI controls
prop1=19; % x_cm (or handles.propOneMenu.Value)
prop2=20; % y_cm
prop3=7; % any other property; in this case, spike amplitude at detection channel handles.propTwoMenu.Value

% Choose cluster to plot; in sortGui, would do this with GUI controls
unitSelected=0;
clusterSpikes=find(idk==unitSelected); % (idk==units(handles.unitsMenu.Value))

% 3D scatter of spikes in cluster
AX=gca; % can change later; handles.theOnlyAxes
xData=Properties(prop1,clusterSpikes);
yData=Properties(prop2,clusterSpikes);
zData=Properties(prop3,clusterSpikes);
figure(1)
scatter3(xData,yData,zData,'Marker','.','SizeData',1,'CData',[0 0 0])

% if either property 1 or property 2 is 2D position
%     make a 3D scatterplot of the x and y values of the centers of mass of the
%     spikes versus the values of the other property
% else
%     make a 2D scatterplot of properties 1 and 2
% end
%%

u=[];
A=[];
B=[];
C=[];

% Get azimuthal angle az of current perspective
[az,~]=view;
az=az*(pi/180); % in radians, and changing the default direction
% Get azimuthal angle theta of each point xy
theta=atan(yData./xData); % in radians
% Get sign of 1D point
signC=sign(az-theta);

% Get matrix A of xy values for all points to project
A=[yData' xData'];
% Get unit normal u to projection plane for current view
[u(1),u(2)]=pol2cart(az,1);

u=repmat(u,size(A,1),1);
compu_A=dot(u,A,2); % Component of A in the u direction
B=compu_A.*u; % Vector projection of A in the u direction
C=A-B;
newCoord=signC'.*sqrt(sum(C.^2,2));
figure;scatter(newCoord,zData,'Marker','.','SizeData',1,'CData',[0 0 0])