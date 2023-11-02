% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $

function Out = ACD_ColorMapHeat(Count)

if ~exist('Count','var')
    Count = 256;
end

Out = zeros(Count,3);
Gradient = linspace(0,1,Count);
for iCtr=1:Count
    Out(iCtr,:) = [Gradient(iCtr),0,Gradient(end-iCtr+1)];
end
end