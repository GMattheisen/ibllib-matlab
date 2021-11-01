% Finds closest event to Fixed in Moving data.
% Fixed - events that stays fixed
% Moving - events that will be seeked to match Fixed
% Retaltionship - how to select Moving: 'after' - moving happened after
% Fixed, 'before' - Moving happened before fixed, 'closest' - Moving
% closest to Fixed. If more than one closest, set giveway.
% Giveway - 'after': selects closest after if before and after same.
% 'before' selects before, if before and after in Moving same. If empty,
% If there is coocurence, that point is taken.


function [CenteredIdx, CenteredTime] = closestevent (Fixed, Moving, relationship, giveway)
CenteredIdx = nan(size(Fixed));
CenteredTime = nan(size(Fixed));

if size(relationship,2)>1 && strcmp(relationship{2},'ignore')
    ignoreZero = 1;
else
    ignoreZero = 0;
end

for cF = 1:numel(Fixed)
    cFixed = Fixed(cF);
    tempIdx = cFixed-Moving;
    
    if ignoreZero % remove 0 if ignoring
        tempIdx(tempIdx==0)=[];
    end
    
    
    seek_after = find(tempIdx<=0); % if looking for movig after fixed, look for smallest negative values
    [~, sidx_after] = max(tempIdx(seek_after));
    val_after = Moving(seek_after(sidx_after));
    idx_after = seek_after(sidx_after);
    
    seek_before = find(tempIdx>=0);
    [~, sidx_before] = min(tempIdx(seek_before));% if looking for movig before fixed, look for smallest positive values
    val_before = Moving(seek_before(sidx_before));
    idx_before = seek_before(sidx_before);
    
    
    switch relationship{1}
        case 'after'
            cIdx = idx_after;
            cVal = val_after;
        case 'before'
            cIdx = idx_before;
            cVal = val_before;
        case 'closest'
            if any(tempIdx==0) % coocuring
                cIdx = find(tempIdx==0);
                cVal = Moving(tempIdx==0);
            elseif abs(idx_after)<abs(idx_before)
                cIdx = idx_after;
                cVal = val_after;
            elseif abs(idx_after)>abs(idx_before)
                cIdx = idx_before;
                cVal = val_before;
            elseif abs(idx_after)==abs(idx_before)&&isempty(giveway) % both side equal, take giveway
                switch giveway
                    case 'before'
                        cIdx = idx_before;
                        cVal = val_before;
                    case 'after'
                        cIdx = idx_after;
                        cVal = val_after;
                end
            elseif abs(idx_after)==abs(idx_before)&&isempty(giveway)
                error ('Two events of equal distance, define giveway parameter.')
            else
                error ('Undefined behaiour.')
            end
            
    end
    % Write output
    if ~isempty(cIdx)
    CenteredIdx(cF) = cIdx;
    CenteredTime(cF) = cVal;
    end
end



end
