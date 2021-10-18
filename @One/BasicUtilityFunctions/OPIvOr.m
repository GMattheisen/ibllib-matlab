% =========================================================
% Find Original Paths for IvOr
%
function original_path = OPIvOr(dataset_type, str, user, m, session)
    starting = strfind(str, 'ORIGINAL_PATH_DICT'); ending = strfind(str, 'ALF_SUBJECT_FOLDER');
    dict = str(starting:ending);
    type_index = strfind(dict, dataset_type);
    colon_indexes = strfind(dict, '":');
    mnt_indexes = strfind(dict, '/mnt/');

    c_candidates = colon_indexes(colon_indexes < type_index);
    m_candidates = mnt_indexes(mnt_indexes < type_index);
    original_path_0 = dict(m_candidates(end-1):c_candidates(end)-1);
    
    split_str = strsplit(original_path_0, "/");
    str_wo_mount = strjoin(split_str([4:end]),"/");
    original_path = "/mnt/" + user + "/" + str_wo_mount;
    D.original_path{m} = original_path;
end 
