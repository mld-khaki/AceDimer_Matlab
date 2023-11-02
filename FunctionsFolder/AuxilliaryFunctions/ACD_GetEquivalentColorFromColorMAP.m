% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $

function [EqColor,EqCompColor] = ACD_GetEquivalentColorFromColorMAP(InpColorMap,InpMat,InpVal)
MaxVal = nanmax(InpMat(:));
MinVal = nanmin(InpMat(:));

Vector = linspace(MinVal,MaxVal,size(InpColorMap,1));
[~,Mindex] = nanmin(abs(Vector-InpVal));
EqColor = InpColorMap(Mindex,:);
EqCompColor = InpColorMap(end-Mindex+1,:);
end