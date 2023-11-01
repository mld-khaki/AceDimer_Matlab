% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function Out = ACD_AUX_CalcAllCombs_VecotrBased_v16p0(InputVector,CombCnt)
if length(InputVector) == 1
    error('This version of the program works with input vector!');
end

% if Forward1Reverse0 == 1
%     RangeValues = MinCombCnt:MaxCombCnt;
% else
%     RangeValues = length(InputVector) - (MinCombCnt:MaxCombCnt);
% end


Out = combnk(1:length(InputVector),CombCnt);
if ACD_SizeShort(Out) == 1
	Out = Out';
end
end
