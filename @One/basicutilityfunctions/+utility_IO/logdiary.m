function logdiary(analysis_logstr,txt)
 
ToAnalysis = datetime('now');
[~,currentMachine]=system('hostname');
currentMachine = strtrim(currentMachine);

% make the analysis log in the destination folder
diary(analysis_logstr)

fprintf('%s\n\r','>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
disp(['TIMESTAMP:   ',datestr(ToAnalysis)])
fprintf('%s\n\r',[txt.title]);
fprintf('%s\n\r','Session : ');
disp(txt.session)
fprintf('%s\n\r',['Machine : ',currentMachine]);
disp(txt.options)
diary OFF         
end




