function varargout = load(self, eid, varargin)
%[d1, d2, d3] =  one.load(eid, 'data', dataset_types)
%       For session with UUID eid, Loads the datasets specified in the cell array dataset_types
% my_data = one.load(eid, 'data', dataset_types, 'dclass_output', true)
% my_data = one.load(..., 'cache_dir', '~/Documents/tmpanalysis') %
% my_data = one.load(..., 'download', false) % do not attempt to load data and return only structure information
% temporarly overrides the default cache dir from the parameter file

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
addOptional(p, 'download', true);
addOptional(p, 'einfo', []);
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
    'winstor_session', ses.winstor_session,...
    'dataset_type', ses.dset_types(ises),...
    'url', ses.url,...
    'eid', repmat({eid}, length(ises), 1 )), 'wrap_scalar', true);

D.data = cell(length(ises), 1);

% if none of the dataset exist, this will return NaN in an array that has
% to be converted to cells
if ~iscell(D.url) && all(isnan(D.url)), D.url = mat2cell(D.url, ones(length(D.url), 1) ); end
if isunix()
    user = getenv('USER');
else
    user = getenv('username');
end
%% Loop over each dataset and read if necessary
for m = 1:length(iargin)
    if isnan(D.url{m})
        warning(['Session ' ses.subject ' Dataset is not available on server:' D.dataset_type{m}])
        continue
    end

    % loads the data
    session_path = "/mnt/" + user + "/winstor/swc/mrsic_flogel/public/projects/" + ses.project + "/ALF/" + ses.subject + "/" + ses.start_time(1:10) + "/" +  sprintf('%03d', ses.number) + "/";
    if contains(ses.project, 'SaMe') | contains(ses.project, 'MiLo')
        local_path = session_path;
    else
        local_path = session_path + utility_IO.FindCollection(D.dataset_type{m});
    end
    D.alf_path{m} = local_path + D.dataset_type{m};
    D.local_path{m} = local_path;
    
    session = sprintf('%03d', ses.number);     
    %populate original paths
    if ~contains(D.dataset_type{m}, '_mflab_taskSettings.raw') && ~isempty(D.dataset_type{m}) && isfile(session_path + "_mflab_taskSettings.raw.json")
        fid = fopen(session_path + "_mflab_taskSettings.raw.json");
        raw = fread(fid, inf);
        str = char(raw');
        meta_content = jsondecode(str);
        fclose(fid);
        if contains(ses.project, 'IvOr') | contains(ses.subproject, 'All')
            D.original_path{m} = OPIvOr(D.dataset_type{m}, str, user, m, session);
        elseif contains(ses.subproject, 'Temporal')
            D.original_path{m} = OPAnKhT(D.dataset_type{m}, str, user, m);
        elseif contains(ses.project, 'MoHa')
            D.original_path{m} = OPMoHa(D.dataset_type{m}, str, user, m);
        elseif contains(ses.project, 'SaMe')
            D.original_path{m} = OPSaMe(D.dataset_type{m}, str, user, m);
        elseif contains(ses.project, 'MiLo')
            D.original_path{m} = OPMiLo(D.dataset_type{m}, str, user, m);        end
    end
    
    [~, ~, ext] = fileparts(D.alf_path{m});
    if download 
        %Data load
        if contains(D.dataset_type{m}, 'task')
            fid = fopen(D.alf_path{m} + ".json");
            raw = fread(fid, inf);
            str = char(raw');
            data = jsondecode(str);
            fclose(fid);  
            D.data{m} = data;
        elseif contains(ses.project, 'MoHa')
            D.data{m} = LoadMoHa(D.alf_path{m}, m, D.dataset_type{m}, D.original_path{m});
        elseif contains(ses.project, 'AnKh') && contains(ses.subproject, 'Temporal')
            D.data{m} = LoadAnKhTemp(D.alf_path{m}, m, D.dataset_type{m}, D.original_path{m});
        elseif contains(ses.project, 'IvOr') | contains(ses.subproject, 'All')
            D.data{m} = LoadIvOr(D.alf_path{m}, m, D.dataset_type{m}, D.original_path{m});
        elseif contains(ses.project, 'SaMe')
            D.data{m} = LoadSaMe(D.alf_path{m}, m, D.dataset_type{m}, D.original_path{m});
        elseif contains(ses.project, 'MiLo')
            D.data{m} = LoadMiLo(D.alf_path{m}, m, D.dataset_type{m}, D.original_path{m});        end    
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

