% =========================================================
% Load data for IvOr
%
function data = LoadIvOr(alf_path, m, dataset_type, original_path)
    if isfile(alf_path + ".npy")
        data = io.read.npy(alf_path + ".npy");
    elseif isfile(alf_path + ".bin")
        C = fopen(alf_path + ".bin");
        data = fread(C);
    elseif isfile(alf_path + ".json")
        fid = fopen(alf_path + ".json");
        raw = fread(fid, inf);
        str = char(raw');
        data = jsondecode(str);
        fclose(fid);  
    elseif isfile(alf_path + ".mat")
        try
            data = load(alf_path + ".mat");
        catch
            fid = fopen(alf_path + ".mat", 'r');
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