% =========================================================
% Load data for AnKh Temporal
%
function data = LoadAnKhTemp(alf_path, m, dataset_type, original_path)
    if isfile(alf_path + ".npy")
            data = io.read.npy(alf_path + ".npy");
    elseif isfile(alf_path + ".bin")
        if contains(dataset_type,'nidq')
            split_str = strsplit(original_path,'/')
            split_path = strjoin(split_str([1:end-1]), '/')
            binName = original_path
            path = strcat(split_path + "/")
            meta = ReadMeta(binName, path);
            [MN,MA,XA,DW] = ChannelCountsNI(meta);
            NI_sample_rate = SampRate(meta);
            nSamp =Inf;
            dataArray = ReadBin(0, nSamp, meta, binName)
            data = dataArray;
        else
            warning(['Dataset extension not supported yet: *'])
            data = [];
        end
    elseif isfile(alf_path + ".mat")
        data = load(alf_path + ".mat");
    elseif isfile(alf_path + ".json")
        fid = fopen(original_path);
        raw = fread(fid, inf);
        str = char(raw');
        data = jsondecode(str);
        fclose(fid);  
    else
        warning(['Dataset extension not supported yet: *'])
    end
end