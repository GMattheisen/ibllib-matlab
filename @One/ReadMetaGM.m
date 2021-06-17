function [meta] = ReadMeta(meta_file, session_path)
    fid = fopen(fullfile(session_path, meta_file), 'r');
    %raw = fread(fid,inf);
    %str = char(raw');
    %fclose(fid);
    %val = jsondecode(str);
    %meta = val.NIDQ_META;
end % ReadMeta

