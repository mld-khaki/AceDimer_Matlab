% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $

function PredictedClasses = ACD_Predict_v16p0(Model,Input) %ClassWeights,Inputs,ClassValuesInOrder)
if isa(Model ,'ClassificationTree')
    PredictedClasses = predict(Model,Input);
elseif isnumeric(Model)
    L = [ones(size(Inputs,1),1) Inputs] * ClassWeights';
    P = exp(L) ./ repmat(sum(exp(L),2),[1 length(ClassValuesInOrder)]);
    [~,PredictedClasses] = nanmax(P');
    PredictedClasses = ClassValuesInOrder(PredictedClasses)';
else
    error
end
end


% EOF


