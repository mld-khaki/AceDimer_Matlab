% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [Out,Index] = ACD_StructMax(InStruct,FocusField)
Array = zeros(1,length(InStruct));
for iCtr=1:length(InStruct)
    Array(iCtr) = InStruct(iCtr).(FocusField);
end
[Out,Index] = nanmax(Array);
end