
function collection = FindCollection(dataset_type)
    if contains(dataset_type, 'Settings')
        collection = '';
    elseif contains(dataset_type, 'stimLine') || contains(dataset_type, 'photodiode')
        collection = 'raw_stimulus_data/';
    elseif contains(dataset_type, 'framePulse') || contains(dataset_type, 'driverLine')
        collection = 'raw_widefieldca_data/';
    elseif contains(dataset_type, 'maskingLight') || contains(dataset_type, 'laser')
        collection = 'raw_ephys_data/';  
    else %piezo, valveLine, clocks, running, videography.frames, videography.meta, videographyBody.frames, nidq, lf, ap
        collection = 'raw_behavior_data/';
    end
end

