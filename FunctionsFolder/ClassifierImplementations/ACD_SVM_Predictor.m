% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [YTestEstmVect] = ACD_SVM_Predictor_v16p0(wTrain,bTrain,InputData,ClassValuesInOrder)
ClassCount = length(ClassValuesInOrder);
YTestVals = zeros(ClassCount,length(InputData));
YTestEstm = zeros(ClassCount,length(InputData));
YTestEstmVect = zeros(1,length(InputData));
for iCtr=1:ClassCount
	fxTest   = wTrain(:,iCtr)'*InputData  + bTrain(iCtr);
	YTestVals(iCtr,:) = fxTest;
	tmpYestm = fxTest > 0;
	YTestEstm(iCtr,:) = tmpYestm*iCtr;
end
Decisions = nansum(YTestEstm > 0);

for iCtr=1:length(Decisions)
	if Decisions(iCtr) == 1
		YTestEstmVect(iCtr) = max(YTestEstm(:,iCtr));
	else
		[~,Ind ] = max(YTestVals(:,iCtr));
		YTestEstmVect(iCtr) = Ind;
	end
	
end
end
