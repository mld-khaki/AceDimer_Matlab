% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 1.6.0 $  $Date: 2021/05/07  14:08 $
% $Revision: 2.0.0 $  $Date: 2021/05/20  11:05 Updated to new v.2 $
% $Revision: 3.0.0 $  $Date: 2022/04/17  NeurIPS Paper updates $

function PredictedClasses = ACD_Predict_v3p0p0(Model,Input,ClassValuesInOrder)
if isa(Model ,'ClassificationTree')
    PredictedClasses = predict(Model,Input);
elseif isnumeric(Model)
    if ~exist('ClassValuesInOrder','var')
        error('ClassValuesInOrder input argument is not provided');
    end
    L = [ones(size(Inputs,1),1) Inputs] * ClassWeights';
    P = exp(L) ./ repmat(sum(exp(L),2),[1 length(ClassValuesInOrder)]);
    [~,PredictedClasses] = nanmax(P');
    PredictedClasses = ClassValuesInOrder(PredictedClasses)';
else
    error
end
end


% function PredictedClasses = ACD_LDA_Predict_v16p1(LDA_Model,Inputs)
% 
% L = [ones(size(Inputs,1),1) Inputs] * LDA_Model.Weights';
% 
% P = exp(L) ./ repmat(sum(exp(L),2),[1 length(LDA_Model.ClassLabels)]);
% 
% [~,PredictedClasses] = nanmax(P');
% 
% PredictedClasses = LDA_Model.ClassLabels(PredictedClasses);
% 
% end
% 
% 


