% Outputs values of timeseries tSMoving at times of clockFixed
% way - mean
% way - interpolate
% way- weightedmean



function [tsOUT] = resample(FixedON, FixedOFF, tsMoving, MovingON, way)
tsOUT =  cell(size(FixedON));

for cS = 1:numel(FixedON)
    
    cFixedON = FixedON(cS);
    cFixedOFF = FixedOFF(cS);
    seek = find(MovingON>=cFixedON&MovingON<cFixedOFF);
    
    if ~isempty(seek)
        switch way
            case 'weightedmean'
                [out] = hlp_weightedmean(seek, MovingON, tsMoving, cFixedOFF, cFixedON);
            case 'mean'
                [out] = hlp_mean(seek, tsMoving);
            case 'sum'
                [out] = hlp_sum(seek, tsMoving);
            case 'last'
                [out] = hlp_last(seek, tsMoving);
            case 'first'
                [out] = hlp_first(first, tsMoving);
            case 'diff'
                [out] = hlp_diff(first, tsMoving);
            otherwise
                error('Not defined.')
        end
    else
        out=[];
    end
    tsOUT{cS} = out;
end
end

% Helper functions
function [out] = hlp_weightedmean(seek, MovingON, tsMoving, FixedOFF, FixedON)
seek = [seek(1)-1,seek];
seek(seek==0)=[];

if numel(seek)==1
    eachdur = FixedOFF-MovingON(seek);
    allduration = sum(eachdur);
    
else
    eachdur = [MovingON(seek(2))-FixedON,... % time of ongoing
        diff(MovingON(seek(2:end))),...% time started and ended
        FixedOFF-(MovingON(seek(end)))];% time of last
    allduration = sum(eachdur);
end
out = sum((tsMoving(seek)).*eachdur)/allduration;

end


function [out] = hlp_mean(seek, MovingON)
out = mean(MovingON(seek));
end


function [out] = hlp_last(seek, MovingON)
out = MovingON(seek(end));
end

function [out] = hlp_first(seek, MovingON)
out = MovingON(seek(1));
end


function [out] = hlp_diff(seek, MovingON)
out = MovingON(seek(end))-MovingON(seek(1));
end

function [out] = hlp_sum(seek, MovingON)
out =  sum(MovingON(seek));
end