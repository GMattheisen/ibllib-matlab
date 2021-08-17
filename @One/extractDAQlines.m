function DAQdata = extractDAQlines(self, eid, varargin)
%Dir = '/home/mrsicflogellab/Desktop/Bit_test/';
%files_source = Dir;
%exp = '.bin';
%imaged = 2
%ret = 1;
%token = '20190902_141027_IO_103_s1_';

session_info = self.alyx_client.get_session(eid);
[Dir,file,~]=fileparts(session_info.json.ORIGINAL_PATHS{1});
files_source = append(Dir, '/');
split_str = strsplit(file, "_");
token = strjoin(split_str([1:end-1]),"_");
imaged = 2;
ret = 1;
DAQdata = IvOr_extractDAQlines(files_source, token, imaged, ret);
end