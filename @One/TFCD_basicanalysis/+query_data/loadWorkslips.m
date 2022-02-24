function workslip = loadWorkslips(workslipspath, token, workslipformat)

% define file format
switch workslipformat
    case '_workslipB' % legacy, Batch 4 and 5
        workslipfname = fullfile(workslipspath, [token, '_workslipB.csv']);
        formatspec = '%s%s%s%s%s%s%s%s%s%f%s';
    case 'all'  % legacy, Batch 4 and 5
        workslipfname = fullfile(workslipspath, [token, '_workslip.csv']);
        formatspec = '%s%s%s%s%s%s%s%s%s%f%s';
    case 'v0.1'  % Batch 6
        workslipfname = fullfile(workslipspath, [token, '_workslip.csv']);
        disp(workslipfname)
        formatspec = '%s%s%s%s%s%s%s%s%s%s%s%f';
    otherwise
        error('Undefined workslip format')
end

if ~exist(workslipfname, 'file')
    error('Workslip does not exist.')
end

%workslip = readtable(workslipfname, 'format', formatspec);
workslip = readtable(workslipfname,'HeaderLines', 0);