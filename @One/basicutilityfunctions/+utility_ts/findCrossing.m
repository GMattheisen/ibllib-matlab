% INPUTS:
% tsIN - timeseries in
% threshold


function [idxON, idxOFF] = findCrossing(tsIN, direction, threshold, minduration)

% if treshold is not provided, normalize trace and use half-max
if isempty(threshold)
    t = max(tsIN)/2;
else
    t = threshold(1);
end

switch direction
    case 'up'
        % output index and value
        idxON=find(diff(tsIN>t)==1)+1;
        idxOFF=find(diff(tsIN>t)==-1)+1;        
       
    case 'down'
        % output index and value
        idxON=find(diff(tsIN>t)==-1)+1;
        idxOFF=find(diff(tsIN>t)==1)+1;
        
        
    case 'any'
        idxON=find(diff(tsIN>t)~=0)+1;
        
    case 'twothreshold'
        if isempty(threshold)
            t1 = 2;
            t2 = -2;
        else
            t1 = threshold(1);
            t2 = threshold(2);
        end
        
        idxU=find(diff(tsIN>t1)==1)+1;
        idxD=find(diff(tsIN<t2)==1)+1;
        idxON = sort([idxU; idxD]);
        idxU=find(diff(tsIN>t1)==-1)+1;
        idxD=find(diff(tsIN<t2)==-1)+1;
        idxOFF = sort([idxU; idxD]);
        
    case 'twothreshold-localextrema'
        if isempty(threshold)
            t1 = 2;
            t2 = -2;
        else
            t1 = threshold(1);
            t2 = threshold(2);
        end
        
        [idxOUT]=hlp_findlocalextrema(tsIN,t1,t2);
        idxON = idxOUT.ON;
        idxOFF = idxOUT.OFF;
        
    case 'findstart'
        t1 = threshold(1);
        [idxOUT] = hlp_findstart(tsIN,t1);
        idxON = idxOUT;
        idxOFF = [];
        
end

% Did crossing happened outside recording, padd onsets or offsets
if numel(idxON)~=numel(idxOFF)
    switch direction
        case 'twothreshold'
            if tsIN(1)>t1|tsIN(1)<t2 % crossing outside of recording
                idxON = [nan;idxON];
            elseif tsIN(end)>t1|tsIN(end)<t2
                idxOFF = [idxOFF;nan];
            end
        case 'findstart'
            idxON = idxOFF;
        otherwise
            if tsIN(1)>t % crossing outside of recording
                idxON = [nan;idxON];
            elseif tsIN(end)>t
                idxOFF = [idxOFF;nan];
            end
    end
    
end

% Glue events too close

if ~isempty(minduration)
    % onsets too close
    BrakeIdx1 = find(diff(idxON) < minduration);
    % onset and offsest too close
    BrakeIdx2 = find(idxON(2:end)-idxOFF(1:end-1)<minduration);
    
    BrakeIdx = unique([BrakeIdx1;BrakeIdx2]);
    if ~isempty(BrakeIdx)
    warning('Minimum distance exceeded, joining ends. Make sure to know what you are doing.')
    % Keep onset of the first and offset of the second event
    idxON(BrakeIdx+1) = [];
    idxOFF(BrakeIdx) = [];
    end
end
end


function [idxOUT]=hlp_findlocalextrema(tsIN,thresh1,thresh2)
smoothwindow = 20;
fullseekrange = -20:20;
% finds all the crossing ONSETS of the upper treshold
cidxUon=find(diff(tsIN>thresh1)==1)+1;

% finds extreme
for ciu=1:numel(cidxUon)
        if ~isempty(find(cidxUon(ciu)+fullseekrange>numel(tsIN),1,'first'))
            seekwindow=-10:numel(cidxUon(ciu):numel(tsIN)-1);
        elseif ~isempty(find(cidxUon(ciu)+fullseekrange<=0,1,'first'))
            seekwindow=-(cidxUon(ciu))+1:20;
        else
            seekwindow = fullseekrange; % reestablish the seekwindow
        end    
    
    activetrace = smooth(tsIN(cidxUon(ciu)+seekwindow),smoothwindow);
%     activetrace = tsIN(cidxUon(ciu)+seekwindow);
    if sum(activetrace>thresh1)==0 % leave non corrected
        % correct the index of current UP onset crossing
        correct_idx(ciu).up = cidxUon(ciu);
    else
        [~,ni,~]=findpeaks(activetrace,'MinPeakHeight',thresh1);        
        ni=max(ni);
        % correct the index of current UP onset crossing
        correct_idx(ciu).up = cidxUon(ciu)+seekwindow(ni);
    end   

end

% finds all the crossing ONSETS of the lower treshold
cidxDon=find(diff(tsIN<thresh2)==1)+1;
% finds extreme
for ciu=1:numel(cidxDon)
    if ~isempty(find(cidxDon(ciu)+fullseekrange>numel(tsIN),1,'first'))
        seekwindow=-10:numel(cidxDon(ciu):numel(tsIN)-1);
        
    elseif ~isempty(find(cidxDon(ciu)+fullseekrange<=0,1,'first'))
        seekwindow=-(cidxDon(ciu))+1:20;
    else
            seekwindow = fullseekrange; % reestablish the seekwindow
    end
    iactivetrace = smooth(tsIN(cidxDon(ciu)+seekwindow),smoothwindow);
%     iactivetrace = tsIN(cidxDoff(ciu)+seekwindow);
    iactivetrace = max(iactivetrace)-iactivetrace; % flip the trace
    if sum(iactivetrace>(thresh2*-1))==0 % leave non corrected
        correct_idx(ciu).down = cidxDon(ciu);
    else
        [~,ni,~]=findpeaks(iactivetrace,'MinPeakHeight',(thresh2*-1));
        ni=max(ni);
        % correct the index of current DOWN onset crossing
        correct_idx(ciu).down = cidxDon(ciu)+seekwindow(ni);
    end

end

if isempty(cidxUon)|isempty(cidxDon);
    idxOUT.ON =[];
    idxOUT.OFF =[];

else
% combine all onsets
idxOUT.ON = sort([[correct_idx.up],[correct_idx.down]]);

% find onset of the first one, the onset is where the sign changes
% seekwindow=-10:0;
% firsttrace = smooth(tsIN(idxOUT.ON(1)+seekwindow),smoothwindow);
% firstON = idxOUT.ON(1)+seekwindow(find(diff(sign(firsttrace)),1,'first')-1);
% ind offset of the last one, the offset is where the sign changes or nan
% idxOUT.OFF = [idxOUT.ON(2:end)]; % onset of next one is offset of previous one
% seekwindow=0:numel(idxOUT.ON(end):numel(tsIN)-1); % seek till the end
% lasttrace = smooth(tsIN(idxOUT.ON(end)+seekwindow),smoothwindow);
% if ~isempty(find(diff(sign(lasttrace)),1,'first'))
% idxOUT.OFF(end+1) = idxOUT.ON(end)+seekwindow(find(diff(sign(lasttrace)),1,'first')+1);
% else
%   idxOUT.OFF(end+1) = nan;
% end


% calculate onset of the first and last one based on width of others
width = round(mean(diff(idxOUT.ON)));
idxOUT.ON = [idxOUT.ON(1)-width, idxOUT.ON];
idxOUT.OFF = idxOUT.ON(2:end);
idxOUT.OFF(end+1) = idxOUT.ON(end)+width;
end
end


function [idxOUT] = hlp_findstart(tsIN, thresh1)
fullseekrange = -50:0;
% finds all the crossing ONSETS of the upper treshold
cidxUon=find(diff(tsIN>thresh1)==1)+1;
correct_idx.up = [];
% finds extreme
for ciu = 1:numel(cidxUon)
        if ~isempty(find(cidxUon(ciu)+fullseekrange>numel(tsIN),1,'first'))
            seekwindow=-10:numel(cidxUon(ciu):numel(tsIN)-1);
        elseif ~isempty(find(cidxUon(ciu)+fullseekrange<=0,1,'first'))
            seekwindow=-(cidxUon(ciu))+1:20;
        else
            seekwindow = fullseekrange; % reestablish the seekwindow
        end    
    trace = tsIN(cidxUon(ciu)+seekwindow);
    if sum(tsIN>thresh1)==0 % leave non corrected
        % correct the index of current UP onset crossing
        correct_idx(ciu).up = cidxUon(ciu);
    else
        inflection_idx = find(diff(sign(diff(trace)))) + 1;
        ni=max(inflection_idx);
        % correct the index of current UP onset crossing
        correct_idx(ciu).up = cidxUon(ciu)+seekwindow(ni);
    end  
end
idxOUT = [correct_idx.up];
end

% VISUALISE
% figure, plot(tsIN)
% hold on
% for cl = 1:numel(idxOUT.ON)
% line([idxOUT.ON(cl) idxOUT.ON(cl)],[-2 2],'color','r')
% end
