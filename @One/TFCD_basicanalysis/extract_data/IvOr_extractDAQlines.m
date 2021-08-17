function [DAQdata] = IvOr_extractDAQlines(files_source, token, imaged, ret)
exp = '.bin';

[myfiles] = listfiles(exp, token, files_source);

if ~isempty (myfiles)
    [p,f,~]=fileparts(myfiles{1});
if ret == 0
    Fname = f(1:end-8);
else
    Fname = f(1:25);
end

file_path = strcat(p,filesep,Fname);

switch imaged
case 0
    % Possible channels
fname0 = char(strcat(file_path, '_achn0.bin')); % piezo1
fname1 = strcat(file_path, '_achn1.bin'); % lever
fname2 = strcat(file_path, '_achn2.bin'); % valve
fname3 = strcat(file_path, '_achn3.bin'); % valve2
fname4 = strcat(file_path, '_achn4.bin'); % StimON
fname5 = strcat(file_path, '_achn5.bin'); % Change
fname6 = strcat(file_path, '_achn6.bin'); % Freeze
fnameTime = strcat(file_path, '_ts.bin'); % Clocks
fnameXraw = strcat(file_path, '_xraw.bin'); % Running

case 1; % no led drivers
% Possible channels
fname0 = char(strcat(file_path, '_achn0.bin')); % piezo1
fname1 = strcat(file_path, '_achn1.bin'); % lever
fname2 = strcat(file_path, '_achn2.bin'); % valve
fname3 = strcat(file_path, '_achn3.bin'); % Cue1
fname4 = strcat(file_path, '_achn4.bin'); % Cue2
fname5 = strcat(file_path, '_achn5.bin'); % Stim1
fname6 = strcat(file_path, '_achn6.bin'); % Change
fname7 = strcat(file_path, '_achn7.bin'); % Freeze
fname8 = strcat(file_path, '_achn8.bin'); % FramePulse
fname9 = strcat(file_path, '_achn9.bin'); % LED driver
fname10 = strcat(file_path, '_achn10.bin'); % CAM driver
fname11 = strcat(file_path, '_achn11.bin'); % Photodiode
fnameTime = strcat(file_path, '_ts.bin'); % Clocks
fnameXraw = strcat(file_path, '_xraw.bin'); % Running

case 2
% Possible channels
fname0 = char(strcat(file_path, '_achn0.bin')); % piezoLeft
fname1 = strcat(file_path, '_achn1.bin'); % piezoRight
fname2 = strcat(file_path, '_achn2.bin'); % valve1
fname3 = strcat(file_path, '_achn3.bin'); % valve2
fname4 = strcat(file_path, '_achn4.bin'); % Cue2
fname5 = strcat(file_path, '_achn5.bin'); % Stim1
fname6 = strcat(file_path, '_achn6.bin'); % Change
fname7 = strcat(file_path, '_achn7.bin'); % Airpuff
fname8 = strcat(file_path, '_achn8.bin'); % FramePulse
fname9 = strcat(file_path, '_achn9.bin'); % LED driver
fname10 = strcat(file_path, '_achn10.bin'); % CAM driver
fname11 = strcat(file_path, '_achn11.bin'); % Photodiode
fname12 = strcat(file_path, '_achn12.bin'); % led1
fname13 = strcat(file_path, '_achn13.bin'); % led2
fnameTime = strcat(file_path, '_ts.bin'); % Clocks
fnameXraw = strcat(file_path, '_xraw.bin'); % Running 
%disp(fname0) /home/mrsicflogellab/Desktop/Bit_test/20190902_141027_IO_103_s1_achn0.bin
otherwise  
    error ('Not sure how to read channels.')
end

INISTM.fname = [files_source, Fname,'_log.ini'];
%inifile downloaded from mathworks
[INISTM.keys,INISTM.sections,INISTM.subsections] = inifile (INISTM.fname,'readall');
%disp(INISTM)
%fname: '/home/mrsicflogellab/Desktop/Bit_test/20190902_141027_IO_103_s1_log.ini'
%           keys: {25×4 cell}
%       sections: {9×1 cell}
%    subsections: {0×2 cell}

%disp(INISTM.keys) % list of {'ai'} {'binnary'} {'facecam'} etc


% checking for acquisition parameters:
NChn=str2double(INISTM.keys {ismember(INISTM.keys(:,1),'ai') & ismember(INISTM.keys(:,3),'nch'),4} );
Rate=str2double(INISTM.keys {ismember(INISTM.keys(:,1),'ai') & ismember(INISTM.keys(:,3),'rate'),4} );
Nsmp=str2double(INISTM.keys {ismember(INISTM.keys(:,1),'ai') & ismember(INISTM.keys(:,3),'nsmp'),4} );

% Analog channels details
AchnNch=str2double(INISTM.keys {ismember(INISTM.keys(:,1),'_achn') & ismember(INISTM.keys(:,3),'nch'),4} );
AchnNchPrec=str2double(INISTM.keys{ismember(INISTM.keys(:,1),'_achn') & ismember(INISTM.keys(:,3),'size [bit]'),4} );

% Raw running details
XrawNch=str2double(INISTM.keys {ismember(INISTM.keys(:,1),'_xraw') & ismember(INISTM.keys(:,3),'nch'),4} );
XrawNchPrec=str2double(INISTM.keys{ismember(INISTM.keys(:,1),'_xraw') & ismember(INISTM.keys(:,3),'size [bit]'),4} );

% Clocks - details
TsNch=str2double(INISTM.keys {ismember(INISTM.keys(:,1),'_ts') & ismember(INISTM.keys(:,3),'nch'),4} );
TsPrec=str2double(INISTM.keys{ismember(INISTM.keys(:,1),'_ts') & ismember(INISTM.keys(:,3),'size [bit]'),4} );

clear TIME;

TIME.fname = fnameTime;
fsize = dir(TIME.fname);  % File information
TIME.fsize = fsize.bytes;  % Files size in bytes

TIME.frmsiz = TsNch*TsPrec/8; %strct of BIN file (1=64 (Date-in sec since the 1.1.1904-\time), 2=32 (msec timer), 3=32 (sample index=FrameID)
TIME.nfrm   = TIME.fsize./TIME.frmsiz;

fid = fopen(TIME.fname);
TIME.ts1 = fread(fid,TIME.nfrm,'int64',TIME.frmsiz-TsPrec/8,'ieee-be'); % (i64) seconds since the epoch 01/01/1904 00:00:00.00 UTC (using the Gregorian calendar and ignoring leap seconds)
fseek(fid,TsPrec/8,'bof');
TIME.ts2 = fread(fid,TIME.nfrm,'uint64',TIME.frmsiz-TsPrec/8,'ieee-be'); % (u64) positive fractions of myfiles second
fseek(fid,TsPrec/8+TsPrec/8,'bof');
TIME.ts = fread(fid,TIME.nfrm,'double',TIME.frmsiz-TsPrec/8,'ieee-be'); % millisecond timer u32
fseek(fid,3*TsPrec/8,'bof');
TIME.i = fread(fid,TIME.nfrm,'double',TIME.frmsiz-TsPrec/8,'ieee-be'); % ite number
fseek(fid,3*TsPrec/8+TsPrec/8,'bof');

%  compute timestamps & dates, in LabView time and in
%  Matlab time
    % compute timestamps & dates
    
numseconds = TIME.ts1';
frcseconds = (TIME.ts2')./(2^64);
ts = (numseconds+frcseconds);

TIME.taxlb = ts; % labview time [s]
TIME.lb=TIME.taxlb-TIME.taxlb(1); %starts from 0



%dt = datestr(ts(1)/(60*60*24)+Ln,'dd/mm/yyyy HH:MM:SS.FFF');% check the date and time. There is myfiles constant 2h difference.Due to daylight-time regime?


Ln = datenum('01/01/1904 00:00:00.000','dd/mm/yyyy HH:MM:SS.FFF'); % labview beginning of time
TIME.taxmat = ts./(60*60*24) + Ln; % convert to MAtalb time in DAYS
TIME.matD=TIME.taxmat-TIME.taxmat(1); % start from 0
TIME.mat=TIME.matD * 24 * 60 * 60; % sMatlab time in SECONDS
TIME.dt = datestr(ts,'dd/mm/yyyy HH:MM:SS.FFF'); % matalb datestr for each datapoint



clear AUXPOS;

 
    AUXPOS.rate = Rate;
    AUXPOS.nsmp = Nsmp;
    AUXPOS.fname = fnameXraw;
    fsize = dir(AUXPOS.fname);  % File information
     AUXPOS.fsize = fsize.bytes; % Files size in bytes
              
     AUXPOS.frmsiz = (AUXPOS.nsmp*64/8); % size of single frame
     AUXPOS.frminf = 0;     % size of info for single frame
     AUXPOS.nfrm   = AUXPOS.fsize./(AUXPOS.frmsiz+AUXPOS.frminf);
     
        % read all data (myfiles = fread(fileID,sizeA,precision,skip,machinefmt))
        frmrng  = 1:AUXPOS.nfrm;
        frm     = frmrng(1);
        skip    = (frm-1)*(AUXPOS.frmsiz+AUXPOS.frminf) + AUXPOS.frminf;
        fid = fopen(AUXPOS.fname);
        fseek(fid,skip,'bof');
        AUXPOS.val = fread(fid,length(frmrng)*AUXPOS.nsmp,'double',AUXPOS.frminf,'ieee-be'); % (u64) positive fractions of myfiles second
        AUXPOS.frmrng = frmrng;
        fclose(fid);
        
        
        
        % remove peaks (usually at the beginning)
        if sum(AUXPOS.val>4*10^9)
            AUXPOS.val(AUXPOS.val>4*10^9) = AUXPOS.val(AUXPOS.val>4*10^9)-((2^32)-1);
        end
        
        % account for non roundness of the wheel        
        inputs.ticks = AUXPOS.val;
        inputs.nticksperrotation = 4000;
        inputs.wheeldiameter = 20;
        inputs.wheelfactor = 2*pi*(inputs.wheeldiameter/2)/inputs.nticksperrotation;
        inputs.plot = 0;        

        
        [ticksCorrected, ticks] = correctPotato(inputs);
        
        
        AUXPOS.speedDePotatoe = (ticksCorrected*inputs.wheelfactor)/(100/1000);  % difference from previous tick count, times wheel dimensions(2Pi*r/nticks (r=10,nticks=4000), ends up in [m/s]
        AUXPOS.speed = (ticks*inputs.wheelfactor)/(100/1000);  % difference from previous tick count, times wheel dimensions(2Pi*r/nticks (r=10,nticks=4000), ends up in [m/s]

        binTime = 20; % average every n values
        AUXPOS.speedbinned = arrayfun(@(i) mean(AUXPOS.speed(i:i+binTime-1)),1:binTime:length(AUXPOS.speed)-binTime+1)'; % the averaged vector
        AUXPOS.binnedDePotato = arrayfun(@(i) mean(AUXPOS.speedDePotatoe(i:i+binTime-1)),1:binTime:length(AUXPOS.speedDePotatoe)-binTime+1)'; % the averaged vector

%         AUXPOS.speed = [0; (diff (AUXPOS.val)*0.0157)/(100/1000)];  % difference from previous tick count, times wheel dimensions, ends up in [m/s]
%        binTime = 20; % average every n values
%        AUXPOS.speedbinned = arrayfun(@(i) mean(AUXPOS.speed(i:i+binTime-1)),1:binTime:length(AUXPOS.speed)-binTime+1)'; % the averaged vector
%   

for chn=1:NChn,
    
    clear ADAT;
    
    ADAT.rate = Rate;
    ADAT.nsmp = Nsmp;
    
    %sprintf buggy, repeats the -achn part
    ADAT.fname = eval(sprintf('fname%d', chn-1));
    
    if exist(ADAT.fname, 'file'),
        fsize = dir(ADAT.fname);  % File information
        ADAT.fsize = fsize.bytes; % Files size in bytes
        
        %             fid = fopen(ADAT.fname);
        
        ADAT.frmsiz = (ADAT.nsmp*AchnNchPrec/8); % size of single frame
        ADAT.frminf = 0;     % size of info for single frame
        ADAT.nfrm   = ADAT.fsize./(ADAT.frmsiz+ADAT.frminf);
        
        % read all data
        frmrng  = 1:ADAT.nfrm;
        frm     = frmrng(1);
        skip    = (frm-1)*(ADAT.frmsiz+ADAT.frminf) + ADAT.frminf;
        fid = fopen(ADAT.fname);
        fseek(fid,skip,'bof');
        ADAT.val = fread(fid,length(frmrng)*ADAT.nsmp,sprintf('%d*single',ADAT.nsmp),ADAT.frminf,'ieee-be'); % (u64) positive fractions of myfiles second
        ADAT.frmrng = frmrng;
        fclose(fid);
        
        eval(sprintf('ADAT%d=ADAT;',chn-1));
        %             save(sprintf('%sADAT%d',savedir_plots,chn-1),sprintf('ADAT%d',chn-1));
    end % if exist(ADAT.fname),
end
switch imaged
    case 0
    
    DAQdata.Time=TIME;
    DAQdata.Running=AUXPOS;
    DAQdata.Lick=ADAT0;
    DAQdata.Valve=ADAT2;
    DAQdata.Stim1=ADAT4;
    DAQdata.Stim2=ADAT5;
    DAQdata.Freeze=ADAT6;
  
case 1
    
    DAQdata.Time=TIME;
    DAQdata.Running=AUXPOS;
    DAQdata.Lick=ADAT0;
    DAQdata.Lever=ADAT1;
    DAQdata.Valve=ADAT2;
    DAQdata.Cue1=ADAT3;
    DAQdata.Cue2=ADAT4;
    DAQdata.Stim1=ADAT5;
    DAQdata.Stim2=ADAT6;
    DAQdata.Freeze=ADAT7;
    DAQdata.FramePulse=ADAT8;
    DAQdata.LEDdriver=ADAT9;
    DAQdata.CAMdriver=ADAT10;
    DAQdata.Photodioder=ADAT11;

    case 2
       
     
    DAQdata.Time=TIME;
    DAQdata.Running=AUXPOS;
    DAQdata.Lick=ADAT0;
    DAQdata.Lick2=ADAT1;
    DAQdata.Valve=ADAT2;
    DAQdata.Valve2=ADAT3;
    DAQdata.Cue2=ADAT4;
    DAQdata.Stim1=ADAT5;
    DAQdata.Stim2=ADAT6;
    DAQdata.AirPuff=ADAT7;
    DAQdata.FramePulse=ADAT8;
    DAQdata.LEDdriver=ADAT9;
    DAQdata.CAMdriver=ADAT10;
    DAQdata.Photodiode=ADAT11;
    DAQdata.led1=ADAT12;
    DAQdata.led2=ADAT13;
end
else
    DAQdata = [];
    error ('Files not found')
end

end