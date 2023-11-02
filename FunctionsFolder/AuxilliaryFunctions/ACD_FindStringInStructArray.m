% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $

function [res,Index] = ACD_FindStringInStructArray(StructArray,StringField,InputString)
Index = [];
res = 0;
for iCtr=1:length(StructArray)
   if strcmpi(StructArray(iCtr).(StringField),InputString) == 1
       Index(end+1) = iCtr;
       res = 1;
   end
end
end