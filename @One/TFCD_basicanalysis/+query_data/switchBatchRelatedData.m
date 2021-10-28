function [out] =  switchBatchRelatedData(animal)
switch animal
    case {'IO_118','IO_117','IO_116','IO_115','IO_114','IO_113',...
          'IO_112','IO_111','IO_110','IO_109','IO_108','IO_107','IO_106',...
          'IO_105','IO_104','IO_103','IO_102','IO_101','IO_100','IO_099',...
          'IO_098','IO_097','IO_096','IO_095','IO_094','IO_093','IO_092','IO_091','IO_090'}
      
      out.Batch = 'Batch6';
      out.workslippath = '/home/mrsicflogellab/Desktop/Bit/Batch6/';
end