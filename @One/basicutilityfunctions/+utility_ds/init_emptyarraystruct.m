% initiates array of empty structures. Mostly to remove inline warning
% underscored about growing the array. Like in this script.

function  [sOUT] = init_emptyarraystruct(nStructs)
for cS = 1:nStructs
sOUT(1,cS) = struct();
end
sOUT = sOUT';
end