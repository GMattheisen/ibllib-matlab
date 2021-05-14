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
'_mflab_videographyBody.frames'},...
{'raw_behavior_data',...
'raw_behavior_data',......
'raw_behavior_data',...
'raw_behavior_data',...
'raw_stimulus_data',...
'raw_stimulus_data',...
'raw_stimulus_data',...
'raw_behavior_data',...
'raw_widefieldca_data',...
'raw_widefieldca_data',...
'raw_widefieldca_data',...
'raw_stimulus_data',...
'raw_widefieldca_data',...
'raw_widefieldca_data',...
'raw_behavior_data',......
'raw_behavior_data',...
'raw_behavior_data',...
'raw_behavior_data',...
'raw_behavior_data'
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
[~, ises, iargin] =  intersect(ses.dset_types, dataset_types);;
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
    url_server_side = strrep( D.url{m},  self.par.HTTP_DATA_SERVER, '');
    % create the local path while keeping ALF convention for folder structure
    if isunix
        local_path = [cache_dir url_server_side];
    else
        local_path = [cache_dir strrep(url_server_side, '/', filesep)];
    end
    if ~dry_run && (force_replace || ~exist(local_path, 'file'))
        %res =  mget(self.ftp, url_server_side, cache_dir);
        %assert(strcmp(res, local_path))
    end
    % loads the data
    if isunix()
        user = getenv('USER')
    else
        user = getenv('username')
    end
    
    local_path = "/mnt/" + user + "/winstor/swc/mrsic_flogel/public/projects/" + ses.project + "/ALF/" + ses.subject + "/" + ses.start_time(1:10) + "/" +  sprintf('%03d', ses.number) + "/" + collection_dict(D.dataset_type{m}) + "/" + D.dataset_type{m};
    disp("Downloading from " + local_path)
    D.local_path{m} = local_path;
    if download_only, continue, end
    [~, ~, ext] = fileparts(local_path);
    if isfile(local_path + ".npy")
        D.data{m} = io.read.npy(local_path + ".npy");
    elseif isfile(local_path + ".bin")
        C = fopen(local_path + ".bin");
        D.data{m} = fread(C)
    else
        warning(['Dataset extension not supported yet: *'])
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

