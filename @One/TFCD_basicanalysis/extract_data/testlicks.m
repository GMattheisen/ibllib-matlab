function [AllLicksON] = testlicks(eid)
one = One();
session_info = one.alyx_client.get_session(eid);

lickthresh = 0.1;

end
try
[DAQDATA] = runDAQDATA(session_info.subject)
% load([p.wheresave,'DAQDATA_',p.daqtoken,'.mat'],...
%     'Stim1ON','Stim1OFF', 'Stim2ON','Stim2OFF',...
%     'Valve','Valve2',...
%     'Lick', 'Lick2');
% load([p.wheredata,p.fsmtoken,'.mat'],'fsm','experiment_settings');
% 
% catch
% error('No DAQDATA_ and/or STIM_ files found.')    
% end
% 
% % Initiate array
% CompletedTrials = 1:size(fsm.triallog,2);
% 
% % If session end failed (trials shown more than -1 off from fsm trials),
% % include all trials saved but last.
% if numel(CompletedTrials)>numel(Stim1ON+1); CompletedTrials = 1:numel(Stim1ON)-1; end
% 
% AllLicksON = utility_ds.init_emptyarraystruct(size(CompletedTrials,2));
% 
% % Limit to completed trials
% Stim1ON = Stim1ON(CompletedTrials);
% Stim1OFF = Stim1OFF(CompletedTrials);
% 
% % Nanpadd stimulus 2 onsets to match total number of trials
% % Outcomes in which change point has been reached
% pastChangePoint = ismember(fsm.trialoutcome(CompletedTrials),'Hit')|ismember(fsm.trialoutcome(CompletedTrials),'Miss')|ismember(fsm.trialoutcome(CompletedTrials),'Ref');
% Stim2ONall = nan(size(Stim1ON));
% Stim2OFFall = nan(size(Stim1ON));
% Stim2ONall(pastChangePoint) = Stim2ON;
% Stim2OFFall(pastChangePoint) = Stim2OFF;
% 
% if numel(find(pastChangePoint)) ~= numel(find(~isnan(Stim2ON))); error('Number of changes does not match.');end
% 
% % FIND LICKS
% % Early licks
% [early_left] = hlp_findlicks(Lick.val,  lickthresh, Stim1ON, Stim1OFF);
% [early_right] = hlp_findlicks(Lick2.val,  lickthresh, Stim1ON, Stim1OFF);
% 
% % Earlier early licks: did early lick happened before an early lick that triggered the FA outcome (Stim1 ended)
% % when did earlly lick that ended the trial occured
% earlierearly_left_diff = Stim1OFF - early_left; 
% earlierearly_right_diff =   Stim1OFF - early_right;
% 
% % Lick after abort
% aborttrials = ismember(fsm.trialoutcome(CompletedTrials),'abort');
% [early_left_abort] = hlp_findlicks(Lick.val, lickthresh, Stim1OFF, Stim1OFF+200, aborttrials);
% [early_right_abort] = hlp_findlicks(Lick2.val, lickthresh, Stim1OFF, Stim1OFF+200, aborttrials);
% 
% % Hit licks
% [hit_left] = hlp_findlicks(Lick.val, lickthresh, Stim2ONall, Stim2OFFall, pastChangePoint);
% [hit_right] = hlp_findlicks(Lick2.val,  lickthresh, Stim2ONall, Stim2OFFall, pastChangePoint);
% hit_left(~ismember(fsm.trialoutcome(CompletedTrials),'Hit')) = nan;
% hit_right(~ismember(fsm.trialoutcome(CompletedTrials),'Hit')) = nan;
% 
% % Did valve opened
% [valve_left] = hlp_findlicks(Valve.val, 2, Stim1ON, Stim2OFFall, pastChangePoint);
% [valve_right] = hlp_findlicks(Valve2.val, 2, Stim1ON, Stim2OFFall, pastChangePoint);
% 
% % Drinking licks
% [drink_left] = hlp_findlicks(Lick.val, lickthresh, valve_left, valve_left+1000, ~isnan(valve_left));
% [drink_right] = hlp_findlicks(Lick2.val, lickthresh, valve_right, valve_right+1000, ~isnan(valve_right));
% 
% % Gray non-drinking licks
% stimON = Stim1ON;
% stimOFF = Stim1OFF;
% stimOFF(pastChangePoint) = Stim2OFF;
% grayON = [1; stimOFF+1];
% grayOFF = [stimON; numel(Lick.val)];
% % remove last gray
% grayON(end) = [];
% grayOFF(end) = [];
% 
% if isnan(grayOFF(1)); grayOFF(1) = 1; end % if onset outside of trace, onset of trace is begining
% 
% [gray_left, left_val] = hlp_findlicks(Lick.val, lickthresh, grayON, grayOFF, isnan(valve_left));
% [gray_right, right_val] = hlp_findlicks(Lick2.val, lickthresh, grayON, grayOFF, isnan(valve_right));
% 
% % Grooming
% grooming_left = nan(size(gray_left));
% grooming_right = nan(size(gray_right));
% 
% grooming_left(left_val>=6) = gray_left(left_val>=6);
% grooming_right(right_val>=6) = gray_right(right_val>=6);
% gray_left(left_val>=6) = nan;
% gray_right(right_val>=6) = nan;
% 
% AllLicksON = utility_ds.distribute(AllLicksON, hit_left, 'hit_left');
% AllLicksON = utility_ds.distribute(AllLicksON, hit_right, 'hit_right');
% AllLicksON = utility_ds.distribute(AllLicksON, early_left, 'early_left');
% AllLicksON = utility_ds.distribute(AllLicksON, early_right, 'early_right');
% AllLicksON = utility_ds.distribute(AllLicksON, drink_left, 'drink_left');
% AllLicksON = utility_ds.distribute(AllLicksON, drink_right, 'drink_right');
% AllLicksON = utility_ds.distribute(AllLicksON, gray_left, 'gray_left');
% AllLicksON = utility_ds.distribute(AllLicksON, gray_right, 'gray_right');
% AllLicksON = utility_ds.distribute(AllLicksON, grooming_left, 'grooming_left');
% AllLicksON = utility_ds.distribute(AllLicksON, grooming_right, 'grooming_right');
% AllLicksON = utility_ds.distribute(AllLicksON, early_left_abort, 'early_left_abort');
% AllLicksON = utility_ds.distribute(AllLicksON, early_right_abort, 'early_right_abort');
% AllLicksON = utility_ds.distribute(AllLicksON, earlierearly_left_diff, 'earlierearly_left_diff');
% AllLicksON = utility_ds.distribute(AllLicksON, earlierearly_right_diff, 'earlierearly_right_diff');
% end
% 
% 
% 
% function [licksout, licksoutval, licksallout] = hlp_findlicks(LickTrace, treshLick, startperiod, endperiod, idx)
% 
% if isnan(startperiod(1)); startperiod(1) = 1; end % if onset outside of trace, onset of trace is begining
% 
% if nargin<5
% idx = ones(size(startperiod));
% end
% 
% if numel(idx) ~= numel(startperiod); error('Numel of events and idx do not match.');end
% 
% licksout = nan(size(idx));  
% licksallout = nan(size(idx));  
% licksallout = num2cell(licksallout);
% licksoutval = nan(size(idx)); 
% activetrials = find(idx);
% 
% if ~isempty(startperiod)&&~isempty(endperiod)
% for cT = 1:numel(activetrials)   
%     sp = startperiod(activetrials(cT));
%     ep = endperiod(activetrials(cT));
%     if ep>numel(LickTrace), ep = numel(LickTrace); end    
%     trace = abs(LickTrace(sp:ep));
%     IdxON = find(diff(trace>treshLick)~=0)+1;
% if ~isempty(IdxON)
%     IdxON(isnan(IdxON))=[];
%     licksout(activetrials(cT)) = IdxON(1)+sp-1;
%     licksoutval(activetrials(cT)) = trace(IdxON(1));
%     licksallout{activetrials(cT)} = IdxON+sp-1;
% end
% end 
% end
% end