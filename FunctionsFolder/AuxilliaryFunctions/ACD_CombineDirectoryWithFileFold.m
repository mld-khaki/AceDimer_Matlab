function OutStr = ACD_CombineDirectoryWithFileFold(Folder,FileFold)
% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact Email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

OutStr = [Folder '\' FileFold];

PrvStr = '';
while(strcmpi(OutStr,PrvStr) == 0)
	PrvStr = OutStr;
	OutStr = strrep(OutStr,'\\','\');
end
end
