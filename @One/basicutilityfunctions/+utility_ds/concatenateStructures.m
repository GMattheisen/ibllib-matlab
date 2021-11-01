% concatenates structures (IN) acros same name fields (sf), then summs across
% concatenation dimension (d) to give out one structure OUT with fields sf

function [OUT] = concatenateStructures(IN, d)

sf = fieldnames(IN);
for csf = 1:numel(sf)
OUT.(sf{csf}) = cat(d,IN.(sf{csf}));
end

end