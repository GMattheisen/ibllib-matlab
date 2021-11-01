% Function: extract event window in timeseries
% [i]:
% isIN: timeseries in
% eventsIN: index of event in that timeseries
% window: (1) baseline prior to event, (3) - end of event)

function [tsOUT, infoOUT] =  eventwindow (tsIN, eventsIN, window)

info.win_center = abs(window(1))+1;
info.win_start = window(1);
info.win_end = window(2);
info.win_range = info.win_start:info.win_end-1;

tsOUT = nan(numel(info.win_range), numel(eventsIN));

for cE = 1:numel(eventsIN)
    posALL = eventsIN(cE)+info.win_range; % negative idx don't exist in trial, padd
    posExist = posALL(posALL>0 & posALL<=numel(tsIN));
    posPadd = posALL(posALL<=0 | posALL>numel(tsIN));
    cEventTrace = tsIN(posExist);
    tsOUT(find(posALL>0 & posALL<=numel(tsIN)), cE) = cEventTrace;
end

infoOUT.win_range = info.win_range;
infoOUT.win_center = info.win_center;

end



