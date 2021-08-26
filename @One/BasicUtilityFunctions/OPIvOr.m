% =========================================================
% Find Original Paths for IvOr
%
function original_path = OPIvOr(dataset_type, original_paths, user, m)
    for k = 1:length(original_paths)
        if dataset_type == "_mflab_experimentSettings.raw"
            str_to = original_paths(k);
            split_str = strsplit(str_to{1}, "/");
            end_val = split_str{end};
            expression = '[A-Z]+_[0-9]+_s[0-9]+_[0-9]+_[0-9]+.mat';
            if regexp(end_val, expression) == 1
                path = original_paths(k);
            end
        elseif contains(original_paths(k), file_conversion(dataset_type)) 
            path = original_paths(k);
        end
    end  
split_str = strsplit(path{1}, "/")
str_wo_mount = strjoin(split_str([4:end]),"/");
original_path = "/mnt/" + user + "/" + str_wo_mount  
end 