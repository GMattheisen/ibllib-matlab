% covers all discrepancies between code rewrite from dev4 branch to new,
% protocol based version
% dev4 ended with the commit: https://bitbucket.org/orsolici/fsm-behaviour/commits/185f80c2db8682ea17268408bec8624f1e501d37

function [legacyfsm] = fsmdev4(p)
load(p, 'fsm', 'experiment_settings');
FinishedTrials = numel(fsm.triallog);

% running (support for legacy code, pre-protocols)
if isfield(fsm, 'handles') % if handles exist, this is dev4 version
    if isfield(fsm.handles,'itirunning')
        if strcmp(fsm.handles.itirunning.String(fsm.handles.itirunning.Value),'auto')
            controlRunning = repmat({'fixed'},FinishedTrials,1);
            abort = num2cell(nan(1,FinishedTrials));            
        else
            controlRunning = repmat({'stationary'},FinishedTrials,1);
            abort = {fsm.reactiontimes(1:FinishedTrials).abort};            
        end
    else
        controlRunning = repmat({'running'},FinishedTrials,1);
        abort = num2cell(nan(1,FinishedTrials));
    end
else % if handles don't exist, this is v 0.1+
    if experiment_settings.cRunning && (experiment_settings.spdrnghigh<=5&&experiment_settings.spdrnghigh<=5);
        controlRunning = 'stationary';
    else
        controlRunning = 'running';
    end
        abort = {fsm.reactiontimes(1:FinishedTrials).abort};            
end

legacyfsm.controlRunning = controlRunning;
legacyfsm.abort = abort;

% /adding fields to fsm struct\ in legacy code this field was part of the fsm.
legacyfsm.savedir = experiment_settings.savedir;
legacyfsm.handles.Trewdavailable.String =  num2str(experiment_settings.Trewdavailable);
legacyfsm.handles.Tminorientationview.String = num2str(experiment_settings.Tminorientationview);
legacyfsm.handles.itirunning.String = num2str(experiment_settings.itirunning);
legacyfsm.handles.itirunning.Value = 1;

% % defining oribe or main trial
% baselinetimes = ceil(fsm.stimT);
% hazardtype = fsm.hazardblock;
% 
% for cT = 1:numel(baselinetimes)
%     if baselinetimes(cT)>9 & strcmp(hazardtype{cT},'early')
%         hazardtype{cT} = 'earlyprobe';
%     elseif baselinetimes(cT)<9 & strcmp(hazardtype{cT},'late')
%         hazardtype{cT} = 'lateprobe';
%     end
% end

end