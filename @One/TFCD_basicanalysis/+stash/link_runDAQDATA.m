function [DAQdata] = link_runDAQDATA(animal)
one = One();
if class(animal) == 'char'
    animal = {animal};
end
runoptions.protocolfield = 'v0.1';
runoptions.sessionfield = 'allsessions';
runoptions.overwrite = false;
for cA = 1:size(animal,2)
    eids = one.search('subject', animal(cA));
    session_list = cell2table({0 0 0 0 0 0 0 0 0 0 0 0 0}, 'VariableNames', {'eid', 'SessionToken', 'IMGtoken', 'DAQtoken', 'FSMtoken','ServerMountPoint', 'DAQpath', 'IMGpath', 'ServerSavePath', 'SesID', 'OnServer', 'Protocol', 'Depth'});
    for eid = 1:size(eids)
        session_info = one.alyx_client.get_session(eids{eid});
        [Dir,file,~]=fileparts(session_info.json.ORIGINAL_PATHS{1});
        files_source = append(Dir, '/');
        split_str = strsplit(file, "_");
        token = strjoin(split_str([1:end-1]),"_");
        subject_folder = session_info.json.SUBJECT_FOLDER;
        folder_split = strsplit(subject_folder, '/');
        if isunix()
            user = getenv('USER');
        else
            user = getenv('username');
        end

        SessionToken = convertCharsToStrings([session_info.start_time(1:4), session_info.start_time(6:7), session_info.start_time(9:10)]);
        IMGtoken = 'NA';
        DAQtoken = token;
        FSMtoken = 'NA';
        ServerMountPoint = strrep([strjoin(folder_split([1:10]), '/'), '/'], 'mrsicflogellab', user);
        DAQpath = [strjoin(folder_split([11:end]), '/'), '/'];
        IMGpath = 'NA';
        ServerSavePath = strrep([session_info.json.ALF_SESSION_FOLDER, '/analysis_data/'], 'mrsicflogellab', user);
        SesID = split_str([end-1]);
        OnServer = 'NA';
        Protocol = session_info.task_protocol;
        Depth = 'NA';
        Session = 'NA';
        data = {eids{eid}, SessionToken, IMGtoken, DAQtoken, FSMtoken, ServerMountPoint, DAQpath, IMGpath, ServerSavePath, SesID, OnServer ,Protocol, Depth};
        session_table = cell2table(data, 'VariableNames', {'eid', 'SessionToken', 'IMGtoken', 'DAQtoken', 'FSMtoken','ServerMountPoint', 'DAQpath', 'IMGpath', 'ServerSavePath', 'SesID', 'OnServer', 'Protocol', 'Depth'});
        session_list = [session_list;session_table];
    end
    %% loop sessions
    session_list([1],:) = [];
    for cS = 1:size(session_list,1) 

        try   
            if ~exist([ServerSavePath,'DAQDATA_',DAQtoken,'.mat'],'file')||runoptions.overwrite
                [DAQdata] = extract_data.link_getDAQDATA(session_list(cS,:).eid);
                if ~exist(ServerSavePath,'dir'),mkdir(ServerSavePath),end
                    save([ServerSavePath,'DAQDATA_',DAQtoken,'.mat'],'-struct','DAQdata');
            end
            % log analysis stap
        stxt.title = 'Extracting DAQ data for TFCD task.';
        stxt.session = DAQtoken;
        stxt.options = runoptions;
        utility_IO.logdiary([ServerSavePath,'analysis_log_',p.daqtoken,'.txt'],stxt)
            disp(['Successful session:     ', DAQtoken])
        catch
            disp(['Failed session:     ', DAQtoken])
            catch_container =  DAQtoken;
        end
    end
    %%This function does not save or log
end
% lof runoptions
ToAnalysis = datetime('now','Format','yyyyMMdd_HHmmss');
ToAnalysis = datestr(ToAnalysis,'yyyyMMdd_HHmmss');
rtxt.title = 'RUNNING extraction of DAQ data for TFCD task.';
rtxt.options = runoptions;
rtxt.session = session_list;
if exist('catch_container','var')
    rtxt.options.failed = catch_container;
end
disp([session_list.ServerSavePath{1},session_list.DAQpath{1}(1:4),'runs/',ToAnalysis,'_RUNlog.txt'])
%utility_IO.logdiary([session_list.ServerSavePath{1},session_list.DAQpath{1}(1:4),'runs/',ToAnalysis,'_RUNlog.txt'],rtxt)
end


    