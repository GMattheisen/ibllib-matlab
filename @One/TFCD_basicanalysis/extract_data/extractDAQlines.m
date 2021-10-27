function DAQdata = extractDAQlines(eid, imaged, ret)
one = One();
session_info = one.alyx_client.get_session(eid);
[Dir,file,~]=fileparts(session_info.json.ORIGINAL_PATHS{1});
files_source = append(Dir, '/');
split_str = strsplit(file, "_");
token = strjoin(split_str([1:end-1]),"_");
DAQdata = IvOr_extractDAQlines(files_source, token, imaged, ret);
end