% Internal function of AceDimer Toolbox , ClassificationData class
%
% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Milad Khaki:
% Contact email: AceDimer.toolbox@gmail.com
% $Revision: 16.0 $  $Date: 2021/05/07  14:08 $
function PredictedClasses = ACD_LDA_Predict_v16p1(LDA_Model,Inputs)

L = [ones(size(Inputs,1),1) Inputs] * LDA_Model.Weights';

P = exp(L) ./ repmat(sum(exp(L),2),[1 length(LDA_Model.ClassLabels)]);

[~,PredictedClasses] = nanmax(P');

PredictedClasses = LDA_Model.ClassLabels(PredictedClasses);

end





