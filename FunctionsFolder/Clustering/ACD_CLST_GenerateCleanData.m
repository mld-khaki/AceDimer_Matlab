% Internal function of AceDimer Toolbox , Classifier Module
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [Attributes,Classes,RemoveInd] = ACD_CLST_GenerateCleanData_v16p0(Attributes,Classes)


Attributes = Attributes - nanmean(Attributes,1);
Attributes = Attributes ./ nanstd(Attributes);

Recurrent = 0;
PrvValue = nan;
Threshold = 25;
RemoveIndex = nan(size(Classes));
StdChange = nan(size(Classes));
for sCtr=2:length(Classes)
	if PrvValue ~= Classes(sCtr)
		PrvValue = Classes(sCtr);
		Recurrent = 0;
	else
		Recurrent = Recurrent+1;
	end
	
	if Recurrent > Threshold
		RemoveIndex(sCtr) = Recurrent;
	end
	
	StdChange(sCtr) = nanstd(Attributes(sCtr-1,:) - Attributes(sCtr,:));
end
StdVal = nanstd(StdChange);
AvgVal = nanmean(StdChange);
StdChange(StdChange > AvgVal + StdVal*2) = nan;
StdChange(StdChange < AvgVal - StdVal*2) = nan;

RemoveInd = RemoveIndex > Threshold;
RemoveInd = RemoveInd & StdChange < (StdVal+AvgVal);
RemoveInd = RemoveInd & StdChange > (StdVal-AvgVal);

Attributes(RemoveInd',:) = [];
Classes(RemoveInd) = [];
end



