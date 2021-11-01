function  [sIN] = distribute(sIN, varIN, fieldname)
for cS = 1:length(varIN)
sIN(cS).(fieldname) = varIN(cS);
end
end