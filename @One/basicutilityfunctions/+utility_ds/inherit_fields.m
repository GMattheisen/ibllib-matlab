% Structure sNew inherits fields from sOld.
% [I]: 
% sOld - original structure
% sNew - new structure
% exclude - do not include these fileds in sNew
%
% orsolici, London April 2020

function [sNew] = inherit_fields(sOld, sNew, exclude)

if nargin<3
    exclude = [];
end

    % inherit rest
    fnsOld = fieldnames(sOld);
    fsNew = fieldnames(sNew);

for cF = 1:numel(fnsOld)
    if ~ismember(fnsOld{cF},fsNew)&~ismember(fnsOld{cF},exclude)
        for cT = 1:numel(sOld)
        sNew(cT).(fnsOld{cF}) = sOld(cT).(fnsOld{cF});
        end
    end
end
end