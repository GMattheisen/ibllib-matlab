% =========================================================
% Load data for MoHa
%

function data = LoadMoHa(alf_path, m, dataset_type, original_path)
    if isfile(alf_path + ".npy")
        data = io.read.npy(alf_path + ".npy");
    elseif isfile(alf_path + ".txt")
        data = tdfread(original_path); 
    elseif isfile(alf_path + ".tsv") | isfile(alf_path + ".csv")
        data = importdata(original_path); 
    elseif isfile(alf_path + ".py")
        data = [];
        warning(['Dataset extension not supported: *'])
    elseif isfile(alf_path + ".mp4")
        data = [];
        warning(['Dataset extension not supported: *'])
    elseif isfile(alf_path)   
        if contains(dataset_type, 'meta') %nidq.bin, lf.bin, ap.bin
            data = importdata(original_path);
        elseif contains(dataset_type, 'bin') %nidq.bin, lf.bin, ap.bin
            %fid = fopen(original_path);
            %data = fread(fid, '*int16');
            %fclose(fid);
            data = [];
            warning(['To load binary files, contact Glynis with the appropriate loading arguments'])
            %if contains(dataset_type, 'nidq')
            %    split_str = strsplit(original_path,'/')
            %    split_path = strjoin(split_str([1:end-1]), '/')
            %    binName = original_path
            %    path = strcat(split_path + "/")
            %    meta = ReadMeta(binName, path);
            %    [MN,MA,XA,DW] = ChannelCountsNI(meta);
            %    NI_sample_rate = SampRate(meta);
            %    nSamp =Inf;
            %    dataArray = ReadBin(0, nSamp, meta, binName)
            %    data = dataArray;
            %else
            %    disp('normal bin load')
            %end
        elseif contains(dataset_type, '.mat')
            data = load(alf_path);
        end
    elseif isfile(alf_path + ".bin")
        data = [];
        warning(['Dataset extension not supported yet: *'])
    elseif isfile(alf_path + ".mat")
        data = load(alf_path + ".mat");
    elseif isfile(alf_path + ".json")
        fid = fopen(original_path);
        raw = fread(fid, inf);
        str = char(raw');
        data = jsondecode(str);
        fclose(fid);  
    else
        data = [];
        warning(['Dataset extension not supported yet: *'])
    end
end

