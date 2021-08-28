% =========================================================
% Find Original Paths for AnKh Temporal
%
function original_path = OPAnKhT(dataset_type, original_paths, user, m)
    if ~contains(dataset_type,"Settings") 
        if contains(dataset_type, 'videography')
            vid_i = find(contains(original_paths, 'Cameras')); 
            Eye_i = find(contains(original_paths, 'Eye'));
            Eye_vid_i = intersect(vid_i, Eye_i);  % all eye indexes
            Front_i = find(contains(original_paths, 'Front'));
            Front_vid_i = intersect(vid_i, Front_i); % all front indexes
            meta_i = find(contains(original_paths, 'metadata'));
            meta_vid_i = intersect(vid_i, meta_i); % all meta cam indexes
            frames_i = find(contains(original_paths, 'mp4'));
            frames_vid_i = intersect(vid_i, frames_i); % all mp4 indexes
            if contains(dataset_type, 'meta') && contains(dataset_type, 'Eye')
                index0 = intersect(meta_vid_i, Eye_vid_i);
            elseif  contains(dataset_type, 'meta') && contains(dataset_type, 'Front')
                index0 = intersect(meta_vid_i, Front_vid_i);
            elseif contains(dataset_type, 'frames') && contains(dataset_type, 'Eye')
                index0 = intersect(frames_vid_i, Eye_vid_i);
            elseif contains(dataset_type, 'frames') && contains(dataset_type, 'Front')
                index0 = intersect(frames_vid_i, Front_vid_i);
            end
            for k = 1:length(index0)
                for k = 1:length(index0)
                    if contains(dataset_type,'2') && contains(original_paths(index0(k)), '_2_')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'3') && contains(original_paths(index0(k)), '_3_')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'4') && contains(original_paths(index0(k)), '_4_')
                        index = index0(k);
                        break
                    else contains(dataset_type,'1')
                        index = index0(k);
                    end
                end
            end
            path = original_paths{index};
            split_str = strsplit(path, "/");
            str_wo_mount = strjoin(split_str([4:end]),"/");
            original_path = "/mnt/" + user + "/" + str_wo_mount;      
        else
            if contains(dataset_type,'nidq') && contains(dataset_type,'bin')
                nidqbin_i = find(contains(original_paths, 'nidq.bin')); 
                path = original_paths{nidqbin_i};
                split_str = strsplit(path, "/");
                str_wo_mount = strjoin(split_str([4:end]),"/");
                original_path = "/mnt/" + user + "/" + str_wo_mount;
            elseif contains(dataset_type,'nidq') && contains(dataset_type,'meta')
                nidqmeta_i = find(contains(original_paths, 'nidq.meta')); 
                path = original_paths{nidqmeta_i};
                split_str = strsplit(path, "/");
                str_wo_mount = strjoin(split_str([4:end]),"/");
                original_path = "/mnt/" + user + "/" + str_wo_mount;
            elseif contains(dataset_type,'lf') || contains(dataset_type,'ap')
                if contains(dataset_type,'lf') && contains(dataset_type,'bin')
                    index0 = find(contains(original_paths, 'lf.bin'));
                elseif contains(dataset_type,'lf') && contains(dataset_type,'meta')
                    index0 = find(contains(original_paths, 'lf.meta'));
                elseif contains(dataset_type,'ap') && contains(dataset_type,'bin')
                    index0 = find(contains(original_paths, 'ap.bin')); 
                elseif contains(dataset_type,'ap') && contains(dataset_type,'meta')
                    index0 = find(contains(original_paths, 'ap.meta')); 
                end
                for k = 1:length(index0)
                    if contains(dataset_type,'ap0.bin') && contains(original_paths(index0(k)), 'imec0')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'ap1.bin') && contains(original_paths(index0(k)), 'imec1')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'ap2.bin') && contains(original_paths(index0(k)), 'imec2')
                        index = index0(k);
                        break   
                    elseif contains(dataset_type,'ap0.meta') && contains(original_paths(index0(k)), 'imec0')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'ap1.meta') && contains(original_paths(index0(k)), 'imec1')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'ap2.meta') && contains(original_paths(index0(k)), 'imec2')
                        index = index0(k);
                        break  
                    elseif contains(dataset_type,'lf0.bin') && contains(original_paths(index0(k)), 'imec0')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'lf1.bin') && contains(original_paths(index0(k)), 'imec1')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'lf2.bin') && contains(original_paths(index0(k)), 'imec2')
                        index = index0(k);
                        break   
                    elseif contains(dataset_type,'lf0.meta') && contains(original_paths(index0(k)), 'imec0')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'lf1.meta') && contains(original_paths(index0(k)), 'imec1')
                        index = index0(k);
                        break
                    elseif contains(dataset_type,'lf2.meta') && contains(original_paths(index0(k)), 'imec2')
                        index = index0(k);
                        break
                    end
                end
                path = original_paths{index}
                split_str = strsplit(path, "/");
                str_wo_mount = strjoin(split_str([4:end]),"/");
                original_path = "/mnt/" + user + "/" + str_wo_mount;
            end
        end
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
        path = original_paths(index)
        split_str = strsplit(path{1}, "/")
        str_wo_mount = strjoin(split_str([4:end]),"/");
        original_path = "/mnt/" + user + "/" + str_wo_mount     
    end
end 