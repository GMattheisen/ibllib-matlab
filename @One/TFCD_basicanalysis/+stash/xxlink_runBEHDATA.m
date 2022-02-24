function [SessionData] = link_runBEHDATA(animal, protocolfield, sessionfield, overwrite)

% RUN setttings
bOUT = query_data.switchBatchRelatedData(animal{:});
runoptions.workslipspath = bOUT.workslippath;
runoptions.protocolfield = protocolfield;
runoptions.sessionfield = sessionfield;
runoptions.overwrite = overwrite;

% loop animals:
for cA = 1:size(animal,2)
    [workslip] = query_data.loadWorkslips(runoptions.workslipspath,animal{cA},runoptions.protocolfield);
    session_list = table2struct(workslip);
    switch runoptions.sessionfield{1}
        case 'imaged'
            session_list = workslip(~strcmp({session_list.IMGtoken},'NA'),:);
        case 'allsessions'
            session_list = workslip;
        otherwise
            session_list = workslip(ismember({session_list.Protocol},runoptions.sessionfield),:);
    end
    
    %% loop sessions
    for cS = 1:size(session_list,1)
    try    
        [p] = query_data.slicePaths(session_list(cS,:));
        
        %% DAQ LINES: load or extract
        ToAnalysis = datetime('now');
        [SessionData, TrialFlags, SessionStats] = extract_data.getBEHDATA(p);        

        save([p.wheresave,'SessionData',p.daqtoken,'.mat'],'SessionData','TrialFlags','SessionStats','ToAnalysis');
        
%         log analysis stap
%         stxt.title = 'Extracting behavioural data for TFCD task.';
%         stxt.session = p.daqtoken;
%         stxt.options = runoptions;
%         utility_IO.logdiary([p.wheresave,'analysis_log_',p.daqtoken,'.txt'],stxt)

    catch
        disp(['Failed session:     ', p.daqtoken])
        catch_container =  p.daqtoken;
    end
    
    end
end


% lof runoptions
% ToAnalysis = datetime('now','Format','yyyyMMdd_HHmmss');
% ToAnalysis = datestr(ToAnalysis,'yyyyMMdd_HHmmss');
% rtxt.title = 'RUNNING extraction of behavioural data for TFCD task.';
% rtxt.options = runoptions;
% rtxt.session = session_list;
% if exist('catch_container','var')
% rtxt.options.failed = catch_container;
% end
% utility_IO.logdiary([session_list.ServerSavePath{1},session_list.DAQpath{1}(1:4),'runs/',ToAnalysis,'_RUNlog.txt'],rtxt)
end
