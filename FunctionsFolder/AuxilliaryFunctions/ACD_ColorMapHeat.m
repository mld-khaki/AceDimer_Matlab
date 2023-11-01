function Out = ACD_ColorMapHeat(Count)
% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

if ~exist('Count','var')
    Count = 256;
end

Out = zeros(Count,3);
Gradient = linspace(0,1,Count);
for iCtr=1:Count
    Out(iCtr,:) = [Gradient(iCtr),0,Gradient(end-iCtr+1)];
end
end