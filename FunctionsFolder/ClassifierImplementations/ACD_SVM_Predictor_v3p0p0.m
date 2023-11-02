% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function [YTestEstmVect] = ACD_SVM_Predictor_v3p0p0(wTrain,bTrain,InputData,ClassValuesInOrder)
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
