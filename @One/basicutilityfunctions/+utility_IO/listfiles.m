% function that gives list of files with matching token and extenstion.

function [myfiles] = listfiles(exp,token,Dir)
if nargin==2    
    Dir=uigetdir;
end    

files = dir([Dir,'**',filesep,'*',exp]);
idx = strfind({files.name}, token); %returning indices of where hr found vcExt
files = files(~cellfun(@(idx) isempty(idx),idx));
myfiles = cell(size(files));
for cF = 1:numel(files)
 myfiles{cF} = [files(cF).folder,filesep,files(cF).name];   
end
end
