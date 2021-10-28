function [SessionOut, FlagsOut, SesFlag] = test(eid)
one = One();
session_info = one.alyx_client.get_session(eid);
disp(session_info)
disp(session_info.json.ALF_EXPERIMENT_SETTINGS)
%% FSM frames
load([session_info.json.ALF_EXPERIMENT_SETTINGS],'fsm','experiment_settings');
[LICKdata] = extract_data.extractlicks(p);
%[fsmdata] = CDDAB_getfsmdata(fsm);
%[legacyfsm] = legacysupport.fsmdev4([p.wheredata,p.fsmtoken,'.mat']);
end



% function [SessionOut, FlagsOut, SesFlag] = getBEHDATA(p)
% 
% %% FSM frames
% load([p.wheredata,p.fsmtoken,'.mat'],'fsm','experiment_settings');
% [LICKdata] = extract_data.extractlicks(p);
% [fsmdata] = CDDAB_getfsmdata(fsm);
% [legacyfsm] = legacysupport.fsmdev4([p.wheredata,p.fsmtoken,'.mat']);
% 
% %% stim start based on stim line
% 
% SessionOut = LICKdata; % copy lick data
% 
% for cT = 1:numel(SessionOut)
%     SessionOut(cT).change = fsm.Stim2TF(cT);
%     SessionOut(cT).hazard = fsmdata.hazard{cT};
%     SessionOut(cT).noiseSD = fsmdata.tiNoise(cT);
%     SessionOut(cT).outcome = fsm.trialoutcome{cT};
%     SessionOut(cT).stim1mTF = fsm.Stim1TF(cT);
%     SessionOut(cT).stim2mTF = fsm.Stim2TF(cT);
%     SessionOut(cT).t_stimT = fsm.stimT(cT);
%     SessionOut(cT).t_stimD = fsm.stimD(cT);
%     SessionOut(cT).changeblock = fsm.hazardblock{cT};
%     SessionOut(cT).direction = fsm.Stim1Ori(cT);
%     SessionOut(cT).t_lkRT = fsm.reactiontimes(cT).RT;
%     SessionOut(cT).t_lkFA = fsm.reactiontimes(cT).FA;
%     SessionOut(cT).t_lkRef = fsm.reactiontimes(cT).Ref;
%     SessionOut(cT).t_abort = fsm.reactiontimes(cT).abort;
%     SessionOut(cT).earlierearly = SessionOut(cT).earlierearly_left_diff>5 | SessionOut(cT).earlierearly_right_diff>5;
%     SessionOut(cT).unconfirmedhit = ismember({SessionOut(cT).outcome},'Hit')&&isnan(SessionOut(cT).hit_left)&&isnan(SessionOut(cT).hit_right);
%     SessionOut(cT).undetectedearly = ~ismember(SessionOut(cT).outcome,{'FA'})&&(~isnan(SessionOut(cT).early_left)||~isnan(SessionOut(cT).early_right));
%     SessionOut(cT).FAabort = ~isnan(SessionOut(cT).early_left_abort)||~isnan(SessionOut(cT).early_right_abort);
%     SessionOut(cT).protocol = p.protocol;
%     SessionOut(cT).controlRunning = legacyfsm.controlRunning;
%     SessionOut(cT).RwdOmmited = fsmdata.WasHit(cT)~=0 && fsm.rewd(cT)==0 && (fsm.Stim2TF(cT)>fsm.Stim1TF(cT)); % animal licked in change trial but no reward given
%     SessionOut(cT).mouse = experiment_settings.token;
%     SessionOut(cT).sesdate = p.sesdate;
%     SessionOut(cT).session = p.fsmtoken;
% end
% 
% % Parameters for Flags
% op.afterblockChange = 2;
% op.afterProbe = 1;
% op.abortTresh = 0.7;
% op.FATresh = 0.7;
% op.highH0miss = 5;
% op.minNtrial = 50;
% op.minHit = 20;
% 
% [FlagsOut, SesFlag] = CDDAB_FlagTrials(SessionOut, op);
% 
% % Transpose:
% FlagsOut = FlagsOut';
% end
% 
% % trialOUTCOME -> outcome