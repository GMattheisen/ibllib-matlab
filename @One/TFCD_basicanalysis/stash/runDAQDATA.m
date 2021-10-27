function [DAQdata] = runDAQDATA(animal)
one = One();
protocolfield = 'v0.1';
sessionfield = 'allsessions';
overwrite = false;
for cA = 1:size(animal,2)
    eids = search(self, 'subject', animal(cA));
    session_list = cell2table({0 0 0 0 0 0 0 0 0 0 0 0 0}, 'VariableNames', {'eid', 'SessionToken', 'IMGtoken', 'DAQtoken', 'FSMtoken','ServerMountPoint', 'DAQpath', 'IMGpath', 'ServerSavePath', 'SesID', 'OnServer', 'Protocol', 'Depth'});
    for eid = 1:size(eids)
        disp(eids{eid})
        session_info = one.alyx_client.get_session(eids{eid});
        [Dir,file,~]=fileparts(session_info.json.ORIGINAL_PATHS{1});
        files_source = append(Dir, '/');
        split_str = strsplit(file, "_");
        token = strjoin(split_str([1:end-1]),"_");
        subject_folder = session_info.json.SUBJECT_FOLDER;
        folder_split = strsplit(subject_folder, '/');
    
        SessionToken = convertCharsToStrings([session_info.start_time(1:4), session_info.start_time(6:7), session_info.start_time(9:10)]);
        IMGtoken = 'NA';
        DAQtoken = token;
        FSMtoken = 'NA';
        ServerMountPoint = [strjoin(folder_split([1:10]), '/'), '/'];
        DAQpath = [strjoin(folder_split([11:end]), '/'), '/'];
        IMGpath = 'NA';
        ServerSavePath = 'path to analysis folder';
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
    for cS = 1:size(session_list,1)     
        try    
            [DAQdata] = extract_data.getDAQDATA(self, session_list(cS,:).eid);
        catch
            disp('Failed session')
        end
    end
    %%This function does not save or log
end
end