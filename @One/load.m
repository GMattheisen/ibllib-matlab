function varargout = load(self, eid, varargin)
%[d1, d2, d3] =  one.load(eid, 'data', dataset_types)
%       For session with UUID eid, Loads the datasets specified in the cell array dataset_types
% my_data = one.load(eid, 'data', dataset_types, 'dclass_output', true)
% my_data = one.load(..., 'cache_dir', '~/Documents/tmpanalysis') %
% my_data = one.load(..., 'download_only', True) % do not attempt to load data and return only structure information
% temporarly overrides the default cache dir from the parameter file
%% map data types to collection
collection_dict = containers.Map({'_mflab_lickPiezoLeft.times',...
'_mflab_lickPiezoRight.times',...
'_mflab_valveLineLeft.times',...
'_mflab_valveLineRight.times',...
'_mflab_stimLineCues.times',...
'_mflab_stimLineBaseline.times',...
'_mflab_stimLineChange.times',...
'_mflab_valveLinePuff.times',...
'_mflab_framePulse.times',...
'_mflab_driverLineLEDON.times',...
'_mflab_driverLineCAM.times',...
'_mflab_photodiode.times',...
'_mflab_driverLineLED1.times',...
'_mflab_driverLineLED2.times',...
'_mflab_clocks.times',...
'_mflab_running.times',...
'_mflab_videographyFace.frames',...
'_mflab_videographyEye.frames',...
'_mflab_videographyBody.frames',...
'_mflab_lickPiezoLeft.raw.times',...
'_mflab_lickPiezoRight.raw.times',...
'_mflab_valveLineLeft.raw.times',...
'_mflab_valveLineRight.raw.times',...
'_mflab_stimLineCues.raw.times',...
'_mflab_stimLineBaseline.raw.times',...
'_mflab_stimLineChange.raw.times',...
'_mflab_valveLinePuff.raw.times',...
'_mflab_framePulse.raw.times',...
'_mflab_driverLineLEDON.raw.times',...
'_mflab_driverLineCAM.raw.times',...
'_mflab_photodiode.raw.times',...
'_mflab_driverLineLED1.raw.times',...
'_mflab_driverLineLED2.raw.times',...
'_mflab_clocks.raw.times',...
'_mflab_running.raw.times',...
'_mflab_experimentSettings.raw',...
'_mflab_computerSettings0.raw',...
'_mflab_computerSettings1.raw',...
'_mflab_computerSettings2.raw',...
'_mflab_computerSettings3.raw',...
'_mflab_sessionSettings0.raw',...
'_mflab_sessionSettings1.raw',...
'_mflab_sessionSettings2.raw',...
'_mflab_sessionSettings3.raw',...
'_mflab_trialSettings0.raw',...
'_mflab_trialSettings1.raw',...
'_mflab_trialSettings2.raw',...
'_mflab_trialSettings3.raw',...
'_mflab_taskSettings.raw'
},...
{'raw_behavior_data/',...
'raw_behavior_data/',......
'raw_behavior_data/',...
'raw_behavior_data/',...
'raw_stimulus_data/',...
'raw_stimulus_data/',...
'raw_stimulus_data/',...
'raw_behavior_data/',...
'raw_widefieldca_data/',...
'raw_widefieldca_data/',...
'raw_widefieldca_data/',...
'raw_stimulus_data/',...
'raw_widefieldca_data/',...
'raw_widefieldca_data/',...
'raw_behavior_data/',......
'raw_behavior_data/',...
'raw_behavior_data/',...
'raw_behavior_data/',...
'raw_behavior_data/',...
'raw_behavior_data/',...
'raw_behavior_data/',......
'raw_behavior_data/',...
'raw_behavior_data/',...
'raw_stimulus_data/',...
'raw_stimulus_data/',...
'raw_stimulus_data/',...
'raw_behavior_data/',...
'raw_widefieldca_data/',...
'raw_widefieldca_data/',...
'raw_widefieldca_data/',...
'raw_stimulus_data/',...
'raw_widefieldca_data/',...
'raw_widefieldca_data/',...
'raw_behavior_data/',...
'raw_behavior_data/',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
'',...
''
});


%% handle input arguments
TYPO_PROOF = {  ...
    'data', 'dataset_types';...
    'dataset', 'dataset_types';...
    'datasets', 'dataset_types';...
    'dataset-types', 'dataset_types';...
    'dataset_types', 'dataset_types';...
    'dtypes', 'dataset_types';...
    'dtype', 'dataset_types';...
    };
% substitute eventual typo with the proper parameter name
for  ia = 1:2:length(varargin)
    it = find(strcmpi(varargin{ia}, TYPO_PROOF(:,1)),1);
    if isempty(it), continue; end
    varargin(ia) = TYPO_PROOF(it,2);
end
% parse input arguments
p = inputParser;
addOptional(p,'dataset_types', {});
addOptional(p,'dry_run',false);
addOptional(p,'force_replace',false);
addOptional(p, 'dclass_output', false);
addOptional(p, 'cache_dir', self.par.CACHE_DIR);
addOptional(p, 'download_only', false)
addOptional(p, 'einfo', [])
parse(p,varargin{:});
for fn = fieldnames(p.Results)', eval([fn{1} '= p.Results.' (fn{1}) ';']); end
if ischar(dataset_types), dataset_types = {dataset_types}; end

%% real stuff
% eid could be a full URL or just an UUID, reformat as only UUID string

if contains(eid, '/')
    eid = strsplit(eid, '/'); eid = eid{end};
end

if ~isempty(einfo)
    ses = einfo;
else
    ses = self.alyx_client.get_session(eid);
end

% if the dtypes are empty, request full download and output a dclass
if isempty(dataset_types)
    %dataset_types = ses.data_dataset_session_related.dataset_type;
    dataset_types = ses.dset_types;
    dclass_output = true;
end
% if there is only one dataset type, none of the fields of the structure will be a cell
% make sure the output is a cell

%if all(structfun(@(x) ~iscell(x), ses.data_dataset_session_related))
%if all(structfun(@(x) ~iscell(x), ses.dset_types))
%    ses.data_dataset_session_related = structfun(@(x) {x}, ses.data_dataset_session_related, 'UniformOutput', false);
%    ses.dset_types = structfun(@(x) {x}, ses.dset_types, 'UniformOutput', false);
%end

%[~, ises, iargin] = intersect(ses.data_dataset_session_related.dataset_type, dataset_types);
[~, ises, iargin] =  intersect(ses.dset_types, dataset_types);

%% Create the data structure
%    'dataset_id', ses.data_dataset_session_related.id(ises),...
%    'dataset_type', ses.data_dataset_session_related.dataset_type(ises),...
%    'url', ses.data_dataset_session_related.data_url(ises),...
%    'dataset_type', ses.data_dataset_session_related.dataset_type(ises),...

D = flatten(struct(...
    'dataset_id', repmat({eid}, length(ises),1),...
    'local_path', repmat({''}, length(ises), 1),...
    'dataset_type', ses.dset_types(ises),...
    'url', ses.url,...
    'eid', repmat({eid}, length(ises), 1 )), 'wrap_scalar', true);

D.data = cell(length(ises), 1);

% if none of the dataset exist, this will return NaN in an array that has
% to be converted to cells
if ~iscell(D.url) && all(isnan(D.url)), D.url = mat2cell(D.url, ones(length(D.url), 1) ); end
%% Loop over each dataset and read if necessary
% iargin should equal number of dset types in intersect

for m = 1:length(iargin)
    
    if isnan(D.url{m}),
        warning(['Session ' ses.subject ' Dataset is not available on server:' D.dataset_type{m}])
        continue
    end

    % loads the data
    if isunix()
        user = getenv('USER');
    else
        user = getenv('username');
    end
    
    session_path = "/mnt/" + user + "/winstor/swc/mrsic_flogel/public/projects/" + ses.project + "/ALF/" + ses.subject + "/" + ses.start_time(1:10) + "/" +  sprintf('%03d', ses.number) + "/";
    local_path = session_path + collection_dict(D.dataset_type{m});
    D.file_path{m} = local_path + D.dataset_type{m};
    D.local_path{m} = local_path;

    if download_only, continue, end
    [~, ~, ext] = fileparts(D.file_path{m});

    if contains(ses.project, 'IvOr')
        if isfile(D.file_path{m} + ".npy")
            D.data{m} = io.read.npy(D.file_path{m} + ".npy");
        elseif isfile(D.file_path{m} + ".bin")
            C = fopen(D.file_path{m} + ".bin");
            D.data{m} = fread(C);
        elseif isfile(D.file_path{m} + ".json")
            fid = fopen(D.file_path{m} + ".json");
            raw = fread(fid, inf);
            str = char(raw');
            D.data{m} = jsondecode(str);
            fclose(fid);  
        elseif isfile(D.file_path{m} + ".mat")
            D.data{m} = load(D.file_path{m} + ".mat");
        else
            warning(['Dataset extension not supported yet: *'])
        end
    end
    
    if contains(ses.project, 'AnKh')
        if isfile(D.file_path{m} + ".npy")
            D.data{m} = io.read.npy(D.file_path{m} + ".npy");
        elseif isfile(D.file_path{m} + ".bin")
            file = D.dataset_type{m} + ".bin"
            fid = fopen(fullfile(session_path, "_mflab_taskSettings.raw.json"), 'r');
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            val = jsondecode(str);
            if isfield(val, 'NIDQ_META') & contains(D.dataset_type{m}, 'raw')
                meta = val.NIDQ_META;
                nSamp = Inf;   
                samp0 = 0;
                nChan = str2double(meta.nSavedChans);
                nFileSamp = str2double(meta.fileSizeBytes) / (2 * nChan);
                samp0 = max(samp0, 0);
                nSamp = min(nSamp, nFileSamp - samp0);
                sizeA = [nChan, nSamp];
                fid = fopen(fullfile(local_path, D.dataset_type{m} + ".bin"), 'rb');
                fseek(fid, samp0 * 2 * nChan, 'bof');
                D.data{m} = fread(fid, sizeA, 'int16=>double');
                fclose(fid);
            else
                C = fopen(D.file_path{m} + ".bin","r");
                D.data{m} = fread(C)      
            end
        elseif isfile(D.file_path{m} + ".mat")
            D.data{m} = load(D.file_path{m} + ".mat");
        elseif isfile(D.file_path{m} + ".json")
            if contains(D.dataset_type{m}, 'taskSettings') | contains(D.dataset_type{m}, 'experimentSettings')
                fid = fopen(D.file_path{m} + ".json");
                raw = fread(fid, inf);
                str = char(raw');
                D.data{m} = jsondecode(str);
                fclose(fid);  
            else
                fid = fopen(D.file_path{m} + ".json");
                raw = fread(fid, inf);
                str = char(raw');
                TF = convertCharsToStrings(extractAfter(str, '/winstor'));
                original_file = "/mnt/" + user + "/winstor" + strtrim(TF);
                fid = fopen(original_file);
                raw = fread(fid, inf);
                str = char(raw');
                D.data{m} = jsondecode(str);
                fclose(fid);
            end
        else
            warning(['Dataset extension not supported yet: *'])
        end
    end
end
% sort the output structure according to the input order
id = [];
if ~isempty(D.dataset_type)
    [~, id] = ismember(dataset_types, D.dataset_type(:));
    D = structfun(@(x) x(nonzeros(id)), D, 'UniformOutput', false);
end
%% Handle the output
if dclass_output
    varargout = {D};
else
    %add dclass output = False functionality 
    varargout = {D};
    %varargout = cell(length(dataset_types), 1);
    %varargout(sort(iargin)) = D.data(sort(nonzeros(id)));
end

