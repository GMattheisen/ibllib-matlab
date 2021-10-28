function [DAQdata] = getDAQDATA(p)

ToAnalysis = datetime('now');
LineTresh = 2;

[DAQdata] = extract_data.extractDAQlines(p.wheredata, p.daqtoken, 2, 0);

% Find events

[DAQdata.frameON, DAQdata.frameOFF] = utility_ts.findCrossing(DAQdata.FramePulse.val,'up',[],[]);
[DAQdata.Stim1ON, DAQdata.Stim1OFF] = utility_ts.findCrossing(DAQdata.Stim1.val,'up',LineTresh,1000);
[DAQdata.Stim2ON, DAQdata.Stim2OFF] = utility_ts.findCrossing(DAQdata.Stim2.val,'up',LineTresh,1000);
[DAQdata.Valve1ON, DAQdata.Valve1OFF] = utility_ts.findCrossing(DAQdata.Valve.val,'up',LineTresh,1000);
[DAQdata.Valve2ON, DAQdata.Valve2OFF] = utility_ts.findCrossing(DAQdata.Valve2.val,'up',LineTresh,1000);
[DAQdata.AirpuffON, DAQdata.AirpuffOFF] = utility_ts.findCrossing(DAQdata.AirPuff.val,'up',LineTresh,1000);

DAQdata.LineTresh = LineTresh;
DAQdata.ToAnalysis = ToAnalysis;
DAQdata.sesdate = p.sesdate;
end