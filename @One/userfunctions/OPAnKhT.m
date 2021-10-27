% =========================================================
% Find Original Paths for AnKh Temporal
%
function original_path = OPAnKhT(dataset_type, str, user, m)
    starting = strfind(str, 'ORIGINAL_PATH_DICT'); ending = strfind(str, 'ALF_SUBJECT_FOLDER');
    dict = str(starting:ending);
    type_index = strfind(dict, dataset_type);
    colon_indexes = strfind(dict, '":');
    mnt_indexes = strfind(dict, '/mnt/');
    if (contains(dataset_type, 'waveforms') | contains(dataset_type, 'params') | contains(dataset_type, 'whitening')) && length(type_index) == 2
        M(dict(type_index(1)+length(dataset_type)))= type_index(1);
        M(dict(type_index(2)+length(dataset_type))) = type_index(2);
        type_index = M('.');
    end
    c_candidates = colon_indexes(colon_indexes < type_index);
    m_candidates = mnt_indexes(mnt_indexes < type_index);
    original_path_0 = dict(m_candidates(end-1):c_candidates(end)-1);
    
    split_str = strsplit(original_path_0, "/");
    str_wo_mount = strjoin(split_str([4:end]),"/");
    original_path = "/mnt/" + user + "/" + str_wo_mount;
    D.original_path{m} = original_path;
end 