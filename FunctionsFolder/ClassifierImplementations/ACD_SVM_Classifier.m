% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function [wTrain,bTrain,D] = ACD_SVM_Classifier_v16p0(InputData,InputClasses,ClassValuesInOrder)
options.c                          = 1;
options.lambda                     = 1/(options.c*size(InputData,2));
options.B                          = 1;
options.l1loss                     = 0;
options.max_ite                    = 1000;
options.wp                         = 1;
options.wn                         = 1;
options.eps                        = 0.1;
options.tolPG                      = 1.0e-12;
% options.nbite                      = 30*Ntrain;
options.reguperiod                 = 10;
options.seed                       = randi(1e6);
options.num_threads                = 16;

InputClasses = double(InputClasses);

[D , N] = size(InputData);
ClassesVals = unique(InputClasses);
ClassCount = length(ClassValuesInOrder);
wTrain = zeros(D,ClassCount);
bTrain = zeros(1,ClassCount);
for iCtr=1:ClassCount
	Index = InputClasses == ClassesVals(iCtr);
	tmpInputClass = InputClasses;
	tmpInputClass(Index) = 1;
	tmpInputClass(~Index) = -1;
	
	tmpWtrain(:,iCtr) = ACD_SVM_pegasos_train(InputData,tmpInputClass,options);
	bTrain(iCtr) = tmpWtrain(D+1,iCtr);
	wTrain(:,iCtr) = tmpWtrain(1:D,iCtr);
end

end
