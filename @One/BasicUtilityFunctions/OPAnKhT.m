% =========================================================
% Find Original Paths for AnKh Temporal
%
function original_path = OPAnKhT(dataset_type, original_paths, user, m)
    if ~contains(dataset_type,"Settings") 
        disp('nidq bin')
        index = find(contains(original_paths, 'nidq.bin'));
    % Settings untouched
    else
        if contains(dataset_type,'_mflab_computerSettings')
            index0 = find(contains(original_paths, 'computer_settings'));
        elseif contains(dataset_type,'_mflab_sessionSettings')
            index0 = find(contains(original_paths, 'session_settings'));
        elseif contains(dataset_type,'_mflab_trialSettings')
            index0 = find(contains(original_paths, 'trials'));
        end
        for k = 1:length(index0)
            if contains(dataset_type,'1') && ~contains(original_paths(index0(k)), 'part')
                index = index0(k);
            elseif contains(dataset_type,'2') && contains(original_paths(index0(k)), 'part2')
                index = index0(k);
            elseif contains(dataset_type,'3') && contains(original_paths(index0(k)), 'part3')
                index = index0(k); 
            end
        end
    end
    path = original_paths(index)
    split_str = strsplit(path{1}, "/")
    str_wo_mount = strjoin(split_str([4:end]),"/");
    original_path = "/mnt/" + user + "/" + str_wo_mount       
end 