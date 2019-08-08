function idk = sortTheUnits(Properties,idk,CHsPos)
% Sort all units except unit 0 according to the mean position of the spikes
% along the probe channels

Units = sort(unique(idk));

if length(Units)>1
for unit = 2:length(Units)
    position(unit-1) = mean(Properties(CHsPos,idk==Units(unit))); % Takes mean of the channel positions of all spikes assigned to each unit (except unit 0)
end
[SortedPosition Order] = sort(position); % sort units by position
newidk(idk==0)=0;
for unit = 1:length(Units)-1
    newidk(idk==Units(Order(unit)+1))=unit;
end
idk = newidk;
end