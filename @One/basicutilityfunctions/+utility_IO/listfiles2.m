% function that gives list of files with matching token and extenstion.

function [myfiles] = listfiles(exp,token,Dir)
% '.bin', token, files_source as INPUT
if nargin==2    
    Dir=uigetdir; % creates pop up to enter directory
end  
%Dir = '/home/mrsicflogellab/Desktop/Bit_test/'
%exp = '.bin'
%token = '20190902_141027_IO_103_s1_'
files = dir([Dir,'*',exp]); % returns list of all bin files in Dir
idx = strfind({files.name}, token); %returning indices of where hr found vcExt
files = files(~cellfun(@(idx) isempty(idx),idx)); % 19x1 struct (name, folder, date, bytes, isdir, datenum)
myfiles = cell(size(files));
for cF = 1:numel(files)
 myfiles{cF} = [files(cF).folder,filesep,files(cF).name];  % 19x1 cell with paths to each file 
end
end