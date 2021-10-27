function DAQdata = p_struct(eid)
one = One();
session_info = one.alyx_client.get_session(eid);
[Dir,file,~]=fileparts(session_info.json.ORIGINAL_PATHS{1});
files_source = append(Dir, '/');
split_str = strsplit(file, "_");
token = strjoin(split_str([1:end-1]),"_");
p.sesdate = [session_info.start_time(1:4), session_info.start_time(6:7), session_info.start_time(9:10)];
p.daqtoken = token;
%p.fsmtoken = 
%p.imgtoken = 
p.protocol = session_info.task_protocol;
p.wheredata = [session_info.json.SUBJECT_FOLDER,'/', p.sesdate, '/'];
%p.wheresave = 
end