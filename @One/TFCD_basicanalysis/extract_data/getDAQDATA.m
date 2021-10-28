function [DAQdata] = getDAQDATA(eid)
one = One();
if class(eid) == 'cell'
    if length(eid) == 1
        eid = eid{1};
    else 
        disp('Too many eids supplied')
    end
end
ToAnalysis = datetime('now');
LineTresh = 2;

[DAQdata] = extractDAQlines(eid, 2, 0); % eid, imaged, ret

% Find events
[DAQdata.frameON, DAQdata.frameOFF] = findCrossing(DAQdata.FramePulse.val,'up',[],[]);
[DAQdata.Stim1ON, DAQdata.Stim1OFF] = findCrossing(DAQdata.Stim1.val,'up',LineTresh,1000);
[DAQdata.Stim2ON, DAQdata.Stim2OFF] = findCrossing(DAQdata.Stim2.val,'up',LineTresh,1000);
[DAQdata.Valve1ON, DAQdata.Valve1OFF] = findCrossing(DAQdata.Valve.val,'up',LineTresh,1000);
[DAQdata.Valve2ON, DAQdata.Valve2OFF] = findCrossing(DAQdata.Valve2.val,'up',LineTresh,1000);
[DAQdata.AirpuffON, DAQdata.AirpuffOFF] = findCrossing(DAQdata.AirPuff.val,'up',LineTresh,1000);

DAQdata.LineTresh = LineTresh;
DAQdata.ToAnalysis = ToAnalysis;
session_info = one.alyx_client.get_session(eid);
p.sesdate = [session_info.start_time(1:4), session_info.start_time(6:7), session_info.start_time(9:10)];
DAQdata.sesdate = p.sesdate;
end