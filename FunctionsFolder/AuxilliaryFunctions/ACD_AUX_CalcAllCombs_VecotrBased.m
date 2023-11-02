% Internal function of AceDimer Toolbox
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function Out = ACD_AUX_CalcAllCombs_VecotrBased_v3p0p0(InputVector,CombCnt)
if length(InputVector) == 1
    error('This version of the program works with input vector!');
end

% if Forward1Reverse0 == 1
%     RangeValues = MinCombCnt:MaxCombCnt;
% else
%     RangeValues = length(InputVector) - (MinCombCnt:MaxCombCnt);
% end


Out = nchoosek(1:length(InputVector),CombCnt);
if ACD_SizeShort(Out) == 1
	Out = Out';
end
end
