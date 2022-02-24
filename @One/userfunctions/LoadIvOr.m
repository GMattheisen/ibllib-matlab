% =========================================================
% Load data for IvOr
%
function data = LoadIvOr(alf_path, m, dataset_type, original_path)
    if isfile(alf_path + ".npy")
        data = io.read.npy(original_path);
    elseif isfile(alf_path + ".bin") | isfile(alf_path + ".ini") 
        disp(original_path)
        C = fopen(original_path);
        data = fread(C);
    elseif isfile(alf_path + ".json")
        fid = fopen(original_path);
        raw = fread(fid, inf);
        str = char(raw');
        data = jsondecode(str);
        fclose(fid);  
    elseif isfile(alf_path + ".mat")
        try
            data = load(original_path);
        catch
            fid = fopen(original_path, 'r');
            text_out = fscanf(fid, '%s');
            fclose(fid);
            split_str = strsplit(text_out,'/');
            split_path = strjoin(split_str([4:end]), '/');
            join_str = strcat("/mnt/", user, "/" + split_path);
            data = load(join_str);
        end
    else
        warning(['Dataset extension not supported yet: *'])
    end
end